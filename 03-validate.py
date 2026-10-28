"""Valida o site congelado: links locais, thumbnails, índice de busca e estrutura."""

import json
import sys
from html.parser import HTMLParser
from pathlib import Path
from urllib.parse import unquote, urlsplit

BASE_DIR = Path(__file__).resolve().parent
INDEX_FILE = BASE_DIR / "index.html"
SEARCH_INDEX = BASE_DIR / "static" / "search-index.json"


class SiteParser(HTMLParser):
    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.ids = []
        self.assets = []
        self.articles = []
        self.headings = {}
        self._in_slide_card = False

    def handle_starttag(self, tag, attrs):
        attributes = dict(attrs)
        element_id = attributes.get("id")
        if element_id:
            self.ids.append(element_id)

        for name in ("href", "src"):
            value = attributes.get(name)
            if value:
                self.assets.append(value)

        if tag in {"h1", "h2", "h3"}:
            self.headings[tag] = self.headings.get(tag, 0) + 1

        if tag == "article" and "slide-card" in (attributes.get("class") or ""):
            self._in_slide_card = True
            self.articles.append(
                {
                    "index_key": attributes.get("data-index-key"),
                    "class": attributes.get("data-class"),
                    "chapter": attributes.get("data-chapter"),
                }
            )

    def handle_endtag(self, tag):
        if tag == "article":
            self._in_slide_card = False


def local_path(reference):
    if reference.startswith(("http://", "https://", "mailto:", "tel:", "#", "data:")):
        return None
    path = unquote(urlsplit(reference).path)
    if not path:
        return None
    if path.startswith("/site-slides/"):
        path = path[len("/site-slides/") :]
    return (BASE_DIR / path).resolve()


def main():
    errors = []
    warnings = []

    if not INDEX_FILE.exists():
        print("ERRO: index.html não encontrado. Rode 02-freeze.py primeiro.")
        return 1

    parser = SiteParser()
    parser.feed(INDEX_FILE.read_text(encoding="utf-8"))

    duplicated = {element_id for element_id in parser.ids if parser.ids.count(element_id) > 1}
    if duplicated:
        errors.append(f"IDs duplicados: {', '.join(sorted(duplicated))}")

    missing_assets = []
    for reference in sorted(set(parser.assets)):
        path = local_path(reference)
        if path and not path.exists():
            missing_assets.append(reference)
    if missing_assets:
        errors.extend(f"Arquivo ausente: {reference}" for reference in missing_assets)

    deck_files = sorted(
        path
        for path in (BASE_DIR / "slides").rglob("*.html")
        if not any(fragment in str(path) for fragment in ("_files", "libs", "backup", "resources"))
        and len(path.relative_to(BASE_DIR / "slides").parts) >= 2
    )

    for deck in deck_files:
        if not deck.with_suffix(".png").exists():
            errors.append(f"Thumbnail ausente: {deck.relative_to(BASE_DIR)}")
        if not deck.with_suffix(".pdf").exists():
            warnings.append(f"PDF ausente: {deck.relative_to(BASE_DIR)}")

    if not SEARCH_INDEX.exists():
        errors.append("static/search-index.json ausente")
        search_index = {}
    else:
        try:
            search_index = json.loads(SEARCH_INDEX.read_text(encoding="utf-8"))
        except json.JSONDecodeError as exc:
            errors.append(f"search-index.json inválido: {exc}")
            search_index = {}

    expected_keys = {f"slides/{deck.relative_to(BASE_DIR / 'slides').as_posix()}" for deck in deck_files}
    for key in sorted(expected_keys - set(search_index)):
        errors.append(f"Deck fora do índice de busca: {key}")

    if len(parser.articles) != len(deck_files):
        errors.append(
            f"index.html tem {len(parser.articles)} cards, mas existem {len(deck_files)} decks"
        )

    for article in parser.articles:
        key = article.get("index_key")
        if key not in search_index:
            errors.append(f"Card sem entrada no índice de busca: {key}")
        if not article.get("class") or not article.get("chapter"):
            errors.append(f"Card sem data-class/data-chapter: {key}")

    required = [
        "static/site.css",
        "static/slides.js",
        "static/theme.js",
        "static/favicon.png",
        "sitemap.xml",
        "robots.txt",
        "404.html",
    ]
    for relative in required:
        if not (BASE_DIR / relative).exists():
            errors.append(f"Artefato ausente: {relative}")

    sitemap = BASE_DIR / "sitemap.xml"
    if sitemap.exists():
        locs = sitemap.read_text(encoding="utf-8").count("<loc>")
        if locs != len(deck_files) + 1:
            warnings.append(f"sitemap.xml tem {locs} URLs (esperado {len(deck_files) + 1})")

    print(f"Decks: {len(deck_files)} | Cards: {len(parser.articles)} | Índice: {len(search_index)}")
    print(f"IDs: {len(parser.ids)} | H1/H2/H3: {parser.headings}")

    for warning in warnings:
        print(f"AVISO: {warning}")
    for error in errors:
        print(f"ERRO: {error}")

    if errors:
        print(f"\nFalha: {len(errors)} erro(s), {len(warnings)} aviso(s).")
        return 1

    print(f"\nOK: nenhum erro ({len(warnings)} aviso[s]).")
    return 0


if __name__ == "__main__":
    sys.exit(main())
