#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z "$repo_root" ]]; then
  echo "memory-lint: not inside a git repository" >&2
  exit 1
fi

cd "$repo_root"

fail=0
staged_files=$(git diff --cached --name-only --diff-filter=ACMR)

check_required_sections() {
  local file="$1"
  local missing=0
  local -a headers=("## Objective" "## Actions" "## Decisions" "## Outcome" "## Next Step" "## Improvement Radar")
  for h in "${headers[@]}"; do
    if ! git show ":$file" | rg -q "^${h}$"; then
      echo "memory-lint: missing section '$h' in $file" >&2
      missing=1
    fi
  done
  return $missing
}

check_weekly_review_sections() {
  local file="$1"
  local missing=0
  local -a headers=("## Repeated Friction Patterns" "## Suggested Improvements" "## Follow-ups")
  for h in "${headers[@]}"; do
    if ! git show ":$file" | rg -q "^${h}$"; then
      echo "memory-lint: missing section '$h' in $file" >&2
      missing=1
    fi
  done
  return $missing
}

check_sensitive_patterns() {
  local file="$1"
  local content
  content="$(git show ":$file")"

  # Ignore explicitly redacted markers.
  content="$(printf '%s' "$content" | rg -v '\[REDACTED[^\]]*\]' || true)"

  if printf '%s' "$content" | rg -n -i --pcre2 '(api[_-]?key|access[_-]?token|refresh[_-]?token|password|passwd|secret)\s*[:=]\s*\S{8,}' >/dev/null; then
    echo "memory-lint: possible secret-like key/value in $file" >&2
    fail=1
  fi

  if printf '%s' "$content" | rg -n -i --pcre2 'authorization\s*:\s*bearer\s+[a-z0-9._-]{10,}' >/dev/null; then
    echo "memory-lint: possible bearer token in $file" >&2
    fail=1
  fi

  if printf '%s' "$content" | rg -n -i --pcre2 'x-api-key\s*:\s*[a-z0-9._-]{10,}' >/dev/null; then
    echo "memory-lint: possible x-api-key in $file" >&2
    fail=1
  fi

  if printf '%s' "$content" | rg -n --pcre2 -- '-----BEGIN (RSA |EC |OPENSSH |DSA )?PRIVATE KEY-----' >/dev/null; then
    echo "memory-lint: private key marker found in $file" >&2
    fail=1
  fi

  if printf '%s' "$content" | rg -n -i --pcre2 'session(id)?\s*[:=]\s*[a-z0-9%._-]{12,}' >/dev/null; then
    echo "memory-lint: possible session credential in $file" >&2
    fail=1
  fi
}

while IFS= read -r f; do
  [[ -z "$f" ]] && continue

  case "$f" in
    domains/*/sessions/*.md)
      check_required_sections "$f" || fail=1
      check_sensitive_patterns "$f"
      ;;
    domains/ops/reviews/*.md)
      if [[ "$f" != domains/ops/reviews/_*.md ]]; then
        check_weekly_review_sections "$f" || fail=1
      fi
      check_sensitive_patterns "$f"
      ;;
    domains/*/index.md|inbox/triage.md|templates/*.md)
      check_sensitive_patterns "$f"
      ;;
    *)
      ;;
  esac
done <<< "$staged_files"

if [[ "$fail" -ne 0 ]]; then
  echo "memory-lint: commit blocked" >&2
  exit 1
fi

echo "memory-lint: ok"
