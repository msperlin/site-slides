"""Gera artefatos auxiliares do site: sitemap, robots e página 404."""

from datetime import datetime
from html import escape
from pathlib import Path
from urllib.parse import quote
from xml.sax.saxutils import escape as xml_escape

from app import SITE_URL, last_commit_timestamp
from site_search import iter_decks

BASE_DIR = Path(__file__).resolve().parent


def _deck_urls(site_url):
    for path in iter_decks():
        relative = path.relative_to(BASE_DIR).as_posix()
        timestamp = last_commit_timestamp(path) or path.stat().st_mtime
        yield site_url + quote(relative), datetime.fromtimestamp(timestamp).date().isoformat()


def write_sitemap(site_url=SITE_URL, output_path=BASE_DIR / "sitemap.xml"):
    base = site_url.rstrip("/") + "/"
    today = datetime.now().date().isoformat()
    lines = [
        '<?xml version="1.0" encoding="UTF-8"?>',
        '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">',
        "  <url>",
        f"    <loc>{xml_escape(base)}</loc>",
        f"    <lastmod>{today}</lastmod>",
        "    <changefreq>weekly</changefreq>",
        "    <priority>1.0</priority>",
        "  </url>",
    ]

    for url, lastmod in _deck_urls(base):
        lines.extend(
            [
                "  <url>",
                f"    <loc>{xml_escape(url)}</loc>",
                f"    <lastmod>{lastmod}</lastmod>",
                "    <changefreq>monthly</changefreq>",
                "    <priority>0.8</priority>",
                "  </url>",
            ]
        )

    lines.append("</urlset>")
    output_path.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(f"Sitemap: {len(lines) - 1} linhas -> {output_path}")


def write_robots(site_url=SITE_URL, output_path=BASE_DIR / "robots.txt"):
    base = site_url.rstrip("/") + "/"
    content = f"User-agent: *\nAllow: /\n\nSitemap: {base}sitemap.xml\n"
    output_path.write_text(content, encoding="utf-8")
    print(f"Robots -> {output_path}")


def write_404(site_url=SITE_URL, output_path=BASE_DIR / "404.html"):
    base = escape(site_url.rstrip("/") + "/")
    html = f"""<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Página não encontrada — Slides</title>
    <meta name="robots" content="noindex">
    <link rel="icon" type="image/png" sizes="96x96" href="{base}static/favicon.png">
    <link rel="stylesheet" href="{base}static/site.css">
    <script>
        (function () {{
            var saved = null;
            try {{ saved = localStorage.getItem('theme'); }} catch (error) {{}}
            var prefersDark = window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches;
            document.documentElement.setAttribute('data-theme', saved || (prefersDark ? 'dark' : 'light'));
        }})();
    </script>
</head>
<body>
    <div class="container">
        <header>
            <h1>Página não encontrada</h1>
            <p class="subtitle">O endereço acessado não existe (ou foi movido).</p>
        </header>
        <main id="conteudo" tabindex="-1" style="text-align:center">
            <p style="color:var(--muted);margin:0 0 22px">Volte para a lista de apresentações:</p>
            <a class="button-link" href="{base}">Ir para o início</a>
        </main>
    </div>
</body>
</html>
"""
    output_path.write_text(html, encoding="utf-8")
    print(f"404 -> {output_path}")


if __name__ == "__main__":
    write_sitemap()
    write_robots()
    write_404()
