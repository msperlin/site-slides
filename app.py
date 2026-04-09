import os
import re
from pathlib import Path
from flask import Flask, render_template

app = Flask(__name__)

def prettify_title(filename):
    """Attempt to clear out common prefixes and make the title readable."""
    name = Path(filename).stem
    # Remove common prefixes like AF_Cap01a_SLIDES_
    if "_SLIDES_" in name:
        name = name.split("_SLIDES_")[-1]
    
    # Replace dashes and underscores with spaces
    name = name.replace("-", " ").replace("_", " ")
    
    # Capitalize the first letter and keep the rest as provided, or title case
    # Taking a safe route to title case for aesthetics
    return name.title()

def extract_qmd_title(qmd_path):
    """Extract the title from the YAML front matter of a .qmd file."""
    if not qmd_path.exists():
        return None
    try:
        content = qmd_path.read_text(encoding='utf-8')
        # Simple regex to find title in YAML front matter
        # It looks for 'title:' followed by optional quotes and the title text
        match = re.search(r'^title:\s*["\']?(.*?)["\']?$', content, re.MULTILINE)
        if match:
            return match.group(1).strip()
    except Exception as e:
        print(f"Error reading {qmd_path}: {e}")
    return None

@app.route('/')
def index():
    slides_data = []
    base_dir = Path("slides")
    
    # If slides directory doesn't exist, just return empty
    if not base_dir.exists():
        return render_template('index.html', classes=[], slides=[])
    
    classes_set = set()
    chapters_set = set()
    
    # Recursively find all html files
    for path in base_dir.rglob("*.html"):
        path_str = str(path)
        
        # Skip support files and libraries usually created by presentation generators like Quarto/reveal.js
        if "_files" in path_str or "libs" in path_str or "backup" in path_str or "resources" in path_str:
            continue
            
        parts = path.relative_to(base_dir).parts
        if len(parts) >= 2:
            class_name = parts[0]
            chapter_name = parts[1] if len(parts) >= 3 else "General"
            
            classes_set.add(class_name)
            chapters_set.add(chapter_name)
            
            # The URL should be relative path from the root
            url = f"slides/{'/'.join(parts)}"
            thumbnail_url = url.replace('.html', '.png')
            
            # Try to get title from .qmd file, fallback to filename
            qmd_path = path.with_suffix(".qmd")
            title = extract_qmd_title(qmd_path)
            if not title:
                title = prettify_title(path.name)
            
            # Get modification date
            mtime = os.path.getmtime(path)
            from datetime import datetime
            dt = datetime.fromtimestamp(mtime)
            formatted_date = dt.strftime("%B %d, %Y")
            
            slides_data.append({
                "class_name": class_name,
                "chapter_name": chapter_name,
                "title": title,
                "url": url,
                "thumbnail_url": thumbnail_url,
                "filename": path.name,
                "date": formatted_date
            })
            
    # Sort classes and chapters alphabetically
    classes = sorted(list(classes_set))
    chapters = sorted(list(chapters_set))
    
    # Sort slides by class, chapter, then by filename
    slides_data = sorted(slides_data, key=lambda x: (x['class_name'], x['chapter_name'], x['filename']))

    return render_template('index.html', classes=classes, chapters=chapters, slides=slides_data)

if __name__ == '__main__':
    app.run(debug=True)
