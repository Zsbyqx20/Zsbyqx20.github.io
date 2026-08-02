#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
draft_output="$(mktemp -d "${TMPDIR:-/tmp}/zacharite-regression.XXXXXX")"

cleanup() {
  if [[ -n "${draft_output:-}" && -d "$draft_output" ]]; then
    rm -rf -- "$draft_output"
  fi
}
trap cleanup EXIT

assert_contains() {
  local needle="$1"
  local file="$2"

  if ! grep -Fq -- "$needle" "$file"; then
    echo "Expected '$needle' in $file" >&2
    exit 1
  fi
}

assert_not_contains() {
  local needle="$1"
  local file="$2"

  if grep -Fq -- "$needle" "$file"; then
    echo "Unexpected '$needle' in $file" >&2
    exit 1
  fi
}

node "$repo_root/scripts/check-cjk-punctuation.mjs"

hugo --source "$repo_root" --gc --minify "$@"

for relative_path in index.html about/index.html posts/index.html search/index.html search-index.json; do
  if [[ ! -f "$repo_root/public/$relative_path" ]]; then
    echo "Missing generated file: public/$relative_path" >&2
    exit 1
  fi
done

assert_contains 'href=#main-content' "$repo_root/public/index.html"
assert_contains 'id=main-content' "$repo_root/public/index.html"
assert_contains 'tabindex=-1' "$repo_root/public/index.html"
assert_contains '/posts/2025_twilight_and_dream/' "$repo_root/public/search-index.json"
assert_contains 'lang=zh-CN' "$repo_root/public/posts/2025_twilight_and_dream/index.html"

if ! grep -RFq -- 'text-spacing-trim:normal' "$repo_root/public/css"; then
  echo "Missing CJK punctuation spacing rule in generated CSS" >&2
  exit 1
fi

if ! grep -RFq -- 'font-feature-settings:"halt"' "$repo_root/public/css"; then
  echo "Missing CJK half-width punctuation rule in generated CSS" >&2
  exit 1
fi

if ! grep -RFq -- 'text-spacing-trim:space-all' "$repo_root/public/css"; then
  echo "Missing native-spacing isolation for manually trimmed punctuation" >&2
  exit 1
fi

if ! grep -RFq -- 'cjk-punctuation-halfwidth' "$repo_root/public/js"; then
  echo "Missing CJK punctuation compression helper in generated JavaScript" >&2
  exit 1
fi

hugo \
  --source "$repo_root" \
  --destination "$draft_output" \
  --buildDrafts \
  --environment development \
  --quiet

for generated_file in "$draft_output/index.html" "$draft_output/posts/index.html" "$draft_output/search-index.json"; do
  assert_not_contains '/posts/post-1/' "$generated_file"
  assert_not_contains '/posts/post-2/' "$generated_file"
  assert_not_contains '/posts/post-3/' "$generated_file"
done

echo "Site regression checks passed."
