import os
from pathlib import Path
import subprocess

def generate_all_thumbnails():
    base_dir = Path("slides")
    if not base_dir.exists():
        print("No slides directory found.")
        return

    # Find all html files
    print("Finding slides to generate thumbnails...")
    html_files = list(base_dir.rglob("*.html"))
    
    count = 0
    for path in html_files:
        path_str = str(path)
        # Skip support files and libs
        if "_files" in path_str or "libs" in path_str or "backup" in path_str or "resources" in path_str:
            continue
        
        thumbnail_path = path.with_suffix('.png')
        if not thumbnail_path.exists():
            print(f"Generating thumbnail for {path}...")
            try:
                subprocess.run([
                    "google-chrome",
                    "--headless",
                    "--disable-gpu",
                    f"--screenshot={thumbnail_path}",
                    "--window-size=1280,720",
                    str(path)
                ], check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
                count += 1
            except Exception as e:
                print(f"Failed to generate for {path}: {e}")
        else:
            print(f"Thumbnail already exists for {path}, skipping.")
            
    print(f"Done. Generated {count} new thumbnails.")

if __name__ == '__main__':
    generate_all_thumbnails()
