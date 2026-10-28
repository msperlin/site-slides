"""Congela o Flask em index.html e gera os artefatos estáticos do site."""

from pathlib import Path

from app import app
from site_outputs import write_404, write_robots, write_sitemap
from site_search import build_search_index

BASE_DIR = Path(__file__).resolve().parent
OUTPUT_FILE = BASE_DIR / "index.html"

print("Gerando índice de busca...")
build_search_index()

print("Congelando a aplicação Flask em index.html...")
with app.app_context():
    client = app.test_client()
    response = client.get("/")

    if response.status_code != 200:
        print(f"Falha ao gerar o site. Status code: {response.status_code}")
        raise SystemExit(1)

    OUTPUT_FILE.write_text(response.data.decode("utf-8"), encoding="utf-8")
    print(f"index.html gerado em {OUTPUT_FILE}")

write_sitemap()
write_robots()
write_404()

print("Pronto. Commit dos arquivos gerados e push para publicar no GitHub Pages.")
