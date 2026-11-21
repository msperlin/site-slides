import os
from pathlib import Path
import shutil
import subprocess
import sys
import threading
from http.server import SimpleHTTPRequestHandler, HTTPServer
import socket
from urllib.parse import quote


def get_free_port():
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.bind(('', 0))
    port = s.getsockname()[1]
    s.close()
    return port


class SilentHTTPHandler(SimpleHTTPRequestHandler):
    def log_message(self, format, *args):
        # Suppress server logs to keep terminal output clean
        pass


def compress_pdf(pdf_path):
    """Compress a PDF in place using Ghostscript (/ebook) if smaller."""
    if not shutil.which("gs") or not pdf_path.exists():
        return 0

    original_size = pdf_path.stat().st_size
    tmp_pdf = pdf_path.with_name(f".compressed-{pdf_path.name}")
    try:
        subprocess.run(
            [
                "gs",
                "-sDEVICE=pdfwrite",
                "-dCompatibilityLevel=1.4",
                "-dPDFSETTINGS=/ebook",
                "-dNOPAUSE",
                "-dQUIET",
                "-dBATCH",
                f"-sOutputFile={tmp_pdf}",
                str(pdf_path),
            ],
            check=True,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
        new_size = tmp_pdf.stat().st_size
        if 0 < new_size < original_size:
            tmp_pdf.replace(pdf_path)
            return original_size - new_size
        tmp_pdf.unlink(missing_ok=True)
        return 0
    except Exception as exc:
        tmp_pdf.unlink(missing_ok=True)
        print(f"  Compression skipped for {pdf_path}: {exc}")
        return 0


def iter_html_decks(base_dir):
    for path in sorted(base_dir.rglob("*.html")):
        path_str = str(path)
        if "_files" in path_str or "libs" in path_str or "backup" in path_str or "resources" in path_str:
            continue
        yield path


def compress_existing_pdfs():
    base_dir = Path("slides")
    if not base_dir.exists():
        print("No slides directory found.")
        return

    total_saved = 0
    count = 0
    for html_path in iter_html_decks(base_dir):
        pdf_path = html_path.with_suffix(".pdf")
        if pdf_path.exists():
            saved = compress_pdf(pdf_path)
            if saved > 0:
                count += 1
                total_saved += saved
                print(f"Compressed {pdf_path} (-{saved / 1024 / 1024:.2f} MB)")

    print(f"Done. Compressed {count} PDF(s), saved {total_saved / 1024 / 1024:.1f} MB.")


def generate_all_pdfs():
    base_dir = Path("slides")
    if not base_dir.exists():
        print("No slides directory found.")
        return

    print("Finding slides to generate PDFs...")
    html_files = list(iter_html_decks(base_dir))

    # Start local HTTP server to handle reveal.js query parameters (?print-pdf)
    port = get_free_port()
    server = HTTPServer(('localhost', port), SilentHTTPHandler)
    server_thread = threading.Thread(target=server.serve_forever)
    server_thread.daemon = True
    server_thread.start()

    print(f"Started local server on port {port} to serve reveal.js presentation files.")

    count = 0
    try:
        for path in html_files:
            path_str = str(path)
            pdf_path = path.with_suffix('.pdf')
            # Check if PDF doesn't exist OR if HTML was modified after PDF was generated
            if not pdf_path.exists() or path.stat().st_mtime > pdf_path.stat().st_mtime:
                if pdf_path.exists():
                    print(f"Updating outdated PDF for {path}...")
                else:
                    print(f"Generating PDF for {path}...")

                quoted_path = quote(path_str)
                url = f"http://localhost:{port}/{quoted_path}?print-pdf"

                try:
                    subprocess.run(
                        [
                            "google-chrome-stable",
                            "--headless=new",
                            "--disable-gpu",
                            "--no-sandbox",
                            "--virtual-time-budget=20000",
                            "--run-all-compositor-stages-before-draw",
                            "--no-pdf-header-footer",
                            f"--print-to-pdf={pdf_path}",
                            url,
                        ],
                        check=True,
                        stdout=subprocess.DEVNULL,
                        stderr=subprocess.DEVNULL,
                    )
                    compress_pdf(pdf_path)
                    count += 1
                except Exception as e:
                    print(f"Failed to generate PDF for {path}: {e}")
    finally:
        server.shutdown()
        server.server_close()
        print("Stopped local server.")

    print(f"Done. Generated {count} new or updated PDFs.")


if __name__ == '__main__':
    if "--compress-existing" in sys.argv[1:]:
        compress_existing_pdfs()
    else:
        generate_all_pdfs()
