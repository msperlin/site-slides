"""Gera o índice de busca no conteúdo das apresentações.

O índice é gravado em ``static/search-index.json`` e carregado sob demanda
pelo JavaScript da listagem. Cada chave é a URL relativa do deck (a mesma
usada no atributo ``data-index-key`` dos cards).
"""

import json
import re
import unicodedata
from html.parser import HTMLParser
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent
SLIDES_DIR = BASE_DIR / "slides"
OUTPUT_PATH = BASE_DIR / "static" / "search-index.json"

SKIP_FRAGMENTS = ("_files", "libs", "backup", "resources")
BLOCK_TAGS = {
    "p", "li", "h1", "h2", "h3", "h4", "h5", "h6", "td", "th",
    "div", "section", "article", "header", "footer", "blockquote",
    "figcaption", "tr", "br", "hr", "dt", "dd", "summary",
}
SKIP_TAGS = {"script", "style", "head", "svg", "template", "noscript"}

MAX_CHARS = 12000


def iter_decks():
    """Percorre os decks HTML válidos, na mesma regra usada por app.py."""
    for path in sorted(SLIDES_DIR.rglob("*.html")):
        path_str = str(path)
        if any(fragment in path_str for fragment in SKIP_FRAGMENTS):
            continue
        if len(path.relative_to(SLIDES_DIR).parts) < 2:
            continue
        yield path


def normalize(text):
    """Minúsculas, sem acentos e sem pontuação — mesmo formato usado no JS."""
    text = unicodedata.normalize("NFKD", text)
    text = "".join(char for char in text if not unicodedata.combining(char))
    return re.sub(r"[^a-z0-9]+", " ", text.lower()).strip()


class _TextExtractor(HTMLParser):
    def __init__(self, limit=MAX_CHARS):
        super().__init__(convert_charrefs=True)
        self.limit = limit
        self.parts = []
        self.size = 0
        self.skip_depth = 0

    def handle_starttag(self, tag, attrs):
        if tag in SKIP_TAGS:
            self.skip_depth += 1
        elif tag in BLOCK_TAGS:
            self.parts.append(" ")

    def handle_startendtag(self, tag, attrs):
        if tag in BLOCK_TAGS:
            self.parts.append(" ")

    def handle_endtag(self, tag):
        if tag in SKIP_TAGS:
            if self.skip_depth:
                self.skip_depth -= 1
        elif tag in BLOCK_TAGS:
            self.parts.append(" ")

    def handle_data(self, data):
        if self.skip_depth or self.size >= self.limit:
            return
        text = " ".join(data.split())
        if text:
            self.parts.append(text)
            self.size += len(text) + 1

    def text(self):
        return " ".join(" ".join(self.parts).split())


def deck_text(path, limit=MAX_CHARS):
    html = path.read_text(encoding="utf-8", errors="ignore")
    # Remove blocos pesados e imagens embutidas antes de interpretar o HTML
    html = re.sub(r"<script\b.*?</script>", " ", html, flags=re.S | re.I)
    html = re.sub(r"<style\b.*?</style>", " ", html, flags=re.S | re.I)
    html = re.sub(r"data:[^\"']{200,}", "", html)

    extractor = _TextExtractor(limit=limit)
    extractor.feed(html)
    return extractor.text()[:limit]


def build_search_index(output_path=OUTPUT_PATH):
    index = {}
    for path in iter_decks():
        url = f"slides/{path.relative_to(SLIDES_DIR).as_posix()}"
        index[url] = normalize(deck_text(path))

    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(
        json.dumps(index, ensure_ascii=False, sort_keys=True, separators=(",", ":")),
        encoding="utf-8",
    )

    size_kb = output_path.stat().st_size / 1024
    print(f"Índice de busca: {len(index)} apresentações, {size_kb:.1f} KB -> {output_path}")
    return index


if __name__ == "__main__":
    build_search_index()
