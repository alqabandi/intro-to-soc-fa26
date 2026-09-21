#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
slides_source_dir="$repo_root/slides/source/chapter-01"
slides_source="$slides_source_dir/ch01_understanding_sociology.qmd"
slides_html="$repo_root/slides/ch01-understanding-sociology.html"
slides_pdf="$repo_root/slides/ch01-understanding-sociology.pdf"
partial_slides_source="$slides_source_dir/ch01_understanding_sociology_part_1.qmd"
partial_slides_html="$repo_root/slides/ch01-understanding-sociology-part-1.html"
partial_slides_pdf="$repo_root/slides/ch01-understanding-sociology-part-1.pdf"
instructor_dir="$repo_root/instructor/chapter-01"
instructor_output_dir="$instructor_dir/rendered"
notes_source="$instructor_dir/ch01_understanding_sociology_notes.qmd"
notes_html="$instructor_output_dir/ch01_understanding_sociology_notes.html"
notes_pdf="$instructor_output_dir/ch01_understanding_sociology_notes.pdf"
quiz_source="$instructor_dir/ch01_quiz.qmd"
quiz_pdf="$instructor_output_dir/ch01-understanding-sociology-quiz.pdf"

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

for source in "$slides_source" "$partial_slides_source" "$notes_source" "$quiz_source"; do
  if [[ ! -f "$source" ]]; then
    echo "Missing source file: $source" >&2
    exit 1
  fi
done

render_root="$(mktemp -d)"
trap 'rm -rf "$render_root"' EXIT

mkdir -p "$instructor_output_dir"
mkdir -p \
  "$render_root/slides/source/chapter-01" \
  "$render_root/assets" \
  "$render_root/instructor/chapter-01"

cp "$slides_source" "$partial_slides_source" "$slides_source_dir/ch01_ku_sociology_style.scss" "$render_root/slides/source/chapter-01/"
cp -R "$repo_root/assets/chapter_01_assets" "$render_root/assets/"
cp "$notes_source" "$instructor_dir/ch01_notes_print.css" "$render_root/instructor/chapter-01/"
cp "$quiz_source" "$render_root/instructor/chapter-01/"

print_to_pdf() {
  local html_path="$1"
  local pdf_path="$2"
  local url="$3"
  local chrome_profile
  local chrome_pid
  local chrome_status=0
  local current_size=0
  local previous_size=0
  local stable_checks=0

  if [[ ! -s "$html_path" ]]; then
    echo "Missing HTML input: $html_path" >&2
    exit 1
  fi

  chrome_profile="$(mktemp -d "$render_root/chrome-profile.XXXXXX")"
  rm -f "$pdf_path"
  "$chrome" \
    --headless=new \
    --disable-gpu \
    --disable-background-networking \
    --disable-breakpad \
    --disable-component-update \
    --disable-crash-reporter \
    --disable-default-apps \
    --allow-file-access-from-files \
    --log-level=3 \
    --no-first-run \
    --no-pdf-header-footer \
    --run-all-compositor-stages-before-draw \
    --user-data-dir="$chrome_profile" \
    --virtual-time-budget=5000 \
    --print-to-pdf="$pdf_path" \
    "$url" \
    >"$render_root/chrome.log" 2>&1 &
  chrome_pid=$!

  for _ in {1..60}; do
    if ! kill -0 "$chrome_pid" 2>/dev/null; then
      wait "$chrome_pid" || chrome_status=$?
      break
    fi
    if [[ -s "$pdf_path" ]]; then
      current_size="$(wc -c < "$pdf_path")"
      if [[ "$current_size" -gt 10000 && "$current_size" -eq "$previous_size" ]]; then
        stable_checks=$((stable_checks + 1))
      else
        stable_checks=0
      fi
      previous_size="$current_size"

      if [[ "$stable_checks" -ge 2 ]]; then
        kill "$chrome_pid" 2>/dev/null || true
        wait "$chrome_pid" 2>/dev/null || true
        chrome_status=0
        break
      fi
    fi
    sleep 1
  done

  if kill -0 "$chrome_pid" 2>/dev/null; then
    kill "$chrome_pid" 2>/dev/null || true
    wait "$chrome_pid" 2>/dev/null || true
    chrome_status=1
  fi

  if [[ "$chrome_status" -ne 0 || ! -s "$pdf_path" ]]; then
    cat "$render_root/chrome.log" >&2
    echo "Chrome did not create a PDF from $html_path" >&2
    exit 1
  fi
}

(
  cd "$render_root/slides/source/chapter-01"
  quarto render ch01_understanding_sociology.qmd --to revealjs
)
cp "$render_root/slides/source/chapter-01/ch01-understanding-sociology.html" "$slides_html"
print_to_pdf "$slides_html" "$slides_pdf" "file://$slides_html?print-pdf"

(
  cd "$render_root/slides/source/chapter-01"
  quarto render ch01_understanding_sociology_part_1.qmd --to revealjs
)
cp "$render_root/slides/source/chapter-01/ch01-understanding-sociology-part-1.html" "$partial_slides_html"
print_to_pdf "$partial_slides_html" "$partial_slides_pdf" "file://$partial_slides_html?print-pdf"

(
  cd "$render_root/instructor/chapter-01"
  quarto render ch01_understanding_sociology_notes.qmd --to html
)
cp "$render_root/instructor/chapter-01/ch01_understanding_sociology_notes.html" "$notes_html"
print_to_pdf "$notes_html" "$notes_pdf" "file://$notes_html"

(
  cd "$render_root/instructor/chapter-01"
  quarto render ch01_quiz.qmd --to pdf --output ch01-understanding-sociology-quiz.pdf
)
cp "$render_root/instructor/chapter-01/ch01-understanding-sociology-quiz.pdf" "$quiz_pdf"

for output in "$slides_html" "$slides_pdf" "$partial_slides_html" "$partial_slides_pdf" "$notes_html" "$notes_pdf" "$quiz_pdf"; do
  if [[ ! -s "$output" ]]; then
    echo "Expected output was not created: $output" >&2
    exit 1
  fi
done

echo "Created student deck HTML: $slides_html"
echo "Created student deck PDF:  $slides_pdf"
echo "Created partial deck HTML: $partial_slides_html"
echo "Created partial deck PDF:  $partial_slides_pdf"
echo "Created private notes HTML: $notes_html"
echo "Created private notes PDF:  $notes_pdf"
echo "Created private quiz PDF:   $quiz_pdf"
