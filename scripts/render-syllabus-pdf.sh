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

chrome_profile="$(mktemp -d)"
chrome_log="$(mktemp)"
chrome_status=0
current_size=0
previous_size=0
stable_checks=0
trap 'rm -rf "$chrome_profile" "$chrome_log"' EXIT

rm -f "$pdf_path"
"$chrome" \
  --headless=new \
  --disable-gpu \
  --disable-background-networking \
  --disable-breakpad \
  --disable-component-update \
  --disable-crash-reporter \
  --disable-default-apps \
  --log-level=3 \
  --no-first-run \
  --no-pdf-header-footer \
  --run-all-compositor-stages-before-draw \
  --user-data-dir="$chrome_profile" \
  --virtual-time-budget=5000 \
  --print-to-pdf="$pdf_path" \
  "file://$html_path" \
  >"$chrome_log" 2>&1 &
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
  cat "$chrome_log" >&2
  echo "Chrome did not create $pdf_path" >&2
  exit 1
fi

echo "Created $pdf_path"
