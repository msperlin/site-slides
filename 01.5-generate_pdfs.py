import os
from pathlib import Path
import subprocess
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

def generate_all_pdfs():
    base_dir = Path("slides")
    if not base_dir.exists():
        print("No slides directory found.")
        return

    # Find all html files
    print("Finding slides to generate PDFs...")
    html_files = list(base_dir.rglob("*.html"))
    
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
            # Skip support files, libs, backups, and resources
            if "_files" in path_str or "libs" in path_str or "backup" in path_str or "resources" in path_str:
                continue
            
            pdf_path = path.with_suffix('.pdf')
            # Check if PDF doesn't exist OR if HTML was modified after PDF was generated
            if not pdf_path.exists() or path.stat().st_mtime > pdf_path.stat().st_mtime:
                if pdf_path.exists():
                    print(f"Updating outdated PDF for {path}...")
                else:
                    print(f"Generating PDF for {path}...")
                
                # Construct HTTP URL with urlencoded path and ?print-pdf query parameter
                quoted_path = quote(path_str)
                url = f"http://localhost:{port}/{quoted_path}?print-pdf"
                
                try:
                    subprocess.run([
                        "google-chrome-stable",
                        "--headless=new",
                        "--disable-gpu",
                        "--no-sandbox",
                        "--virtual-time-budget=20000",
                        "--run-all-compositor-stages-before-draw",
                        "--no-pdf-header-footer",
                        f"--print-to-pdf={pdf_path}",
                        url
                    ], check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
                    count += 1
                except Exception as e:
                    print(f"Failed to generate PDF for {path}: {e}")
            else:
                pass
                
    finally:
        server.shutdown()
        server.server_close()
        print("Stopped local server.")
        
    print(f"Done. Generated {count} new or updated PDFs.")

if __name__ == '__main__':
    generate_all_pdfs()
