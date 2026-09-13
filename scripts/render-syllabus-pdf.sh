#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
html_path="$repo_root/_site/syllabus.html"
pdf_path="$repo_root/downloads/introduction-to-sociology-syllabus-fall-2026.pdf"

if [[ -n "${CHROME_BIN:-}" ]]; then
  chrome="$CHROME_BIN"
elif [[ -x "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" ]]; then
  chrome="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
elif command -v google-chrome >/dev/null 2>&1; then
  chrome="$(command -v google-chrome)"
elif command -v chromium >/dev/null 2>&1; then
  chrome="$(command -v chromium)"
else
  echo "Chrome or Chromium is required. Set CHROME_BIN to its executable." >&2
  exit 1
fi

mkdir -p "$repo_root/downloads"

(
  cd "$repo_root"
  quarto render syllabus.qmd
)

"$chrome" \
  --headless \
  --disable-gpu \
  --log-level=3 \
  --no-pdf-header-footer \
  --run-all-compositor-stages-before-draw \
  --print-to-pdf="$pdf_path" \
  "file://$html_path"

echo "Created $pdf_path"
