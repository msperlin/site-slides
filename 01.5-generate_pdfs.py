import os
from pathlib import Path
import subprocess

def generate_all_pdfs():
    base_dir = Path("slides")
    if not base_dir.exists():
        print("No slides directory found.")
        return

    # Find all html files
    print("Finding slides to generate PDFs...")
    html_files = list(base_dir.rglob("*.html"))
    
    count = 0
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
            try:
                subprocess.run([
                    "google-chrome-stable",
                    "--headless",
                    "--disable-gpu",
                    "--no-pdf-header-footer",
                    f"--print-to-pdf={pdf_path}",
                    str(path)
                ], check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
                count += 1
            except Exception as e:
                print(f"Failed to generate PDF for {path}: {e}")
        else:
            print(f"PDF is up-to-date for {path}, skipping.")
            
    print(f"Done. Generated {count} new PDFs.")

if __name__ == '__main__':
    generate_all_pdfs()
