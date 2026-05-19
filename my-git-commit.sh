commit_msg="Commit on $(date '+%Y-%m-%d %H:%M:%S')"

git pull

uv sync
uv run 01-generate_thumbnails.py
uv run 02-freeze.py

git add .
git commit -m "$commit_msg"
git push
