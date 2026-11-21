"""Gera/atualiza o WebP de capa de cada apresentação.

Cada thumbnail é um screenshot do primeiro slide do HTML em 1280x720,
redimensionado para 640x360 em WebP (via ImageMagick ``magick``) para
manter o repositório leve e o carregamento da página rápido.
O screenshot é feito a partir de uma cópia temporária do HTML com um
pequeno ajuste de CSS: o tema da AF usa ``width: 100%`` + padding no
``#title-slide``, o que faz o card ultrapassar a janela e cortar a borda
direita. O ajuste vale apenas para a captura; o HTML original não muda.
O relógio sobreposto (``#global-clock``) também é escondido na captura.
"""

from pathlib import Path
import subprocess
import sys

BASE_DIR = Path("slides")
SKIP_PARTS = {"_files", "libs", "backup", "resources"}
CAPTURE_WIDTH = 1280
CAPTURE_HEIGHT = 720
THUMB_WIDTH = 640
THUMB_HEIGHT = 360
WEBP_QUALITY = 82

THUMBNAIL_FIX = (
    "<style>"
    "#title-slide{box-sizing:border-box !important;"
    "width:100% !important;max-width:100% !important;}"
    "#global-clock{display:none !important;}"
    "</style></head>"
)


def presentations():
    """Lista os HTMLs de apresentação, ignorando pastas de apoio."""
    for path in sorted(BASE_DIR.rglob("*.html")):
        if SKIP_PARTS.intersection(path.parts):
            continue
        yield path


def is_outdated(html_path, thumbnail_path):
    """Indica se o thumbnail está mais antigo que o HTML."""
    if not thumbnail_path.exists():
        return True
    return thumbnail_path.stat().st_mtime < html_path.stat().st_mtime


def convert_png_to_webp(png_path, webp_path):
    """Redimensiona e converte um PNG para WebP 640x360."""
    subprocess.run(
        [
            "magick",
            str(png_path),
            "-resize",
            f"{THUMB_WIDTH}x{THUMB_HEIGHT}!",
            "-quality",
            str(WEBP_QUALITY),
            str(webp_path),
        ],
        check=True,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )


def generate_thumbnail(html_path, thumbnail_path):
    """Captura o primeiro slide do HTML e salva como WebP 640x360."""
    html = html_path.read_text(encoding="utf-8")
    if "</head>" in html:
        html = html.replace("</head>", THUMBNAIL_FIX, 1)

    tmp_html = html_path.with_name(f".thumb-{html_path.stem}.html")
    tmp_png = html_path.with_name(f".thumb-{html_path.stem}.png")
    tmp_html.write_text(html, encoding="utf-8")

    try:
        subprocess.run(
            [
                "google-chrome-stable",
                "--headless=new",
                "--disable-gpu",
                "--no-sandbox",
                "--hide-scrollbars",
                "--virtual-time-budget=10000",
                "--run-all-compositor-stages-before-draw",
                f"--window-size={CAPTURE_WIDTH},{CAPTURE_HEIGHT}",
                f"--screenshot={tmp_png}",
                tmp_html.resolve().as_uri(),
            ],
            check=True,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
        convert_png_to_webp(tmp_png, thumbnail_path)
    finally:
        tmp_html.unlink(missing_ok=True)
        tmp_png.unlink(missing_ok=True)


def generate_all_thumbnails(force=False):
    if not BASE_DIR.exists():
        print("No slides directory found.")
        return 1

    print("Gerando thumbnails WebP das apresentações...")
    updated = 0
    skipped = 0
    failed = 0

    for html_path in presentations():
        thumbnail_path = html_path.with_suffix(".webp")
        legacy_png = html_path.with_suffix(".png")

        if not force and not is_outdated(html_path, thumbnail_path):
            skipped += 1
            continue

        print(f"Atualizando capa: {html_path}")
        try:
            if not force and legacy_png.exists() and not is_outdated(html_path, legacy_png):
                convert_png_to_webp(legacy_png, thumbnail_path)
            else:
                generate_thumbnail(html_path, thumbnail_path)
            legacy_png.unlink(missing_ok=True)
            updated += 1
        except Exception as exc:
            print(f"  Falhou: {exc}")
            failed += 1

    print(
        f"Pronto. {updated} thumbnail(s) gerado(s), "
        f"{skipped} sem alteração, {failed} falha(s)."
    )
    return 1 if failed else 0


if __name__ == "__main__":
    force = "--force" in sys.argv[1:]
    raise SystemExit(generate_all_thumbnails(force=force))
