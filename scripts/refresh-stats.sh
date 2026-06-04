#!/usr/bin/env bash
# refresh-stats.sh — Refresh dynamic stats in the GitHub profile README.
#
# Reads counts and versions from sibling repos in ~/Projects/personal/ and
# updates sentinel tokens in README.md. Sentinel format:
#   <!-- TOKEN -->value<!-- /TOKEN -->
#
# Tokens managed:
#   CAST_VERSION          — claude-agent-team VERSION file
#   CAST_AGENT_COUNT      — tracked agents/core/*.md count
#   CAST_TEST_COUNT       — total @test functions across tracked .bats files
#   CAST_TEST_FILE_COUNT  — tracked .bats file count
#   CAST_DB_TABLE_COUNT   — distinct tables in ALLOWED_TABLES set in cast_db.py
#   VERSION:<repo>        — VERSION file from ~/Projects/personal/<repo>/
#
# Usage:
#   bash scripts/refresh-stats.sh                 # update README in this repo
#   bash scripts/refresh-stats.sh /path/to/README # update an explicit file
#
# Source of truth: filesystem state of sibling repos. If a sibling repo is
# missing, the corresponding sentinel is left unchanged (stale rather than blank).

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
README="${1:-$REPO_ROOT/README.md}"
PERSONAL_ROOT="${PERSONAL_ROOT:-$HOME/Projects/personal}"
CAST_REPO="$PERSONAL_ROOT/claude-agent-team"

if [ ! -f "$README" ]; then
  echo "README not found: $README" >&2
  exit 1
fi

update_token() {
  local token="$1" value="$2"
  # Match <!-- TOKEN -->anything-not-a-comment<!-- /TOKEN -->
  # Escape forward slashes in value for sed (in case version strings contain them).
  local esc="${value//\//\\/}"
  sed -i.bak "s|<!-- ${token} -->[^<]*<!-- /${token} -->|<!-- ${token} -->${esc}<!-- /${token} -->|g" "$README"
}

# --- Framework-level counts (from claude-agent-team) ---
if [ -d "$CAST_REPO" ]; then
  cd "$CAST_REPO"

  if [ -f VERSION ]; then
    CAST_VERSION="$(tr -d '[:space:]' < VERSION)"
    update_token "CAST_VERSION" "$CAST_VERSION"
  fi

  AGENT_COUNT=$(git ls-files 'agents/core/*.md' 2>/dev/null | grep -cE '^agents/core/[^/]+\.md$' || echo 0)
  update_token "CAST_AGENT_COUNT" "$AGENT_COUNT"

  TEST_FILES=$(git ls-files 'tests/*.bats' 'tests/*/*.bats' 2>/dev/null || true)
  if [ -n "$TEST_FILES" ]; then
    TEST_COUNT=$(echo "$TEST_FILES" | xargs grep -h "^@test" 2>/dev/null | wc -l | tr -d ' ')
    TEST_FILE_COUNT=$(echo "$TEST_FILES" | wc -l | tr -d ' ')
  else
    TEST_COUNT=0
    TEST_FILE_COUNT=0
  fi
  update_token "CAST_TEST_COUNT" "$TEST_COUNT"
  update_token "CAST_TEST_FILE_COUNT" "$TEST_FILE_COUNT"

  if [ -f "scripts/cast_db.py" ]; then
    TABLE_COUNT=$(awk '/ALLOWED_TABLES[[:space:]]*=[[:space:]]*\{/{f=1} f{print} /\}/{if(f)exit}' "scripts/cast_db.py" \
      | grep -oE "['\"][a-z_][a-z0-9_]*['\"]" | sort -u | wc -l | tr -d ' ')
    update_token "CAST_DB_TABLE_COUNT" "$TABLE_COUNT"
  fi

  cd "$REPO_ROOT"
else
  echo "[refresh-stats] $CAST_REPO not found — skipping framework-level counts" >&2
fi

# --- Per-package versions ---
# Walk every sibling repo with a VERSION file, expose as VERSION:<repo> sentinel.
# Only updates tokens that exist in the README — silent on missing tokens.
if [ -d "$PERSONAL_ROOT" ]; then
  for repo_dir in "$PERSONAL_ROOT"/*/; do
    repo_name="$(basename "$repo_dir")"
    version=""
    # Prefer VERSION file (CAST convention)
    if [ -f "$repo_dir/VERSION" ]; then
      version="$(tr -d '[:space:]' < "$repo_dir/VERSION")"
    # Fall back to package.json "version" field (Node projects)
    elif [ -f "$repo_dir/package.json" ]; then
      version="$(python3 -c "import json,sys; print(json.load(open('$repo_dir/package.json')).get('version',''))" 2>/dev/null || echo "")"
    fi
    [ -n "$version" ] || continue
    update_token "VERSION:$repo_name" "$version"
  done
fi

rm -f "${README}.bak"

# --- Report what changed ---
echo "Profile stats refreshed:"
[ -n "${CAST_VERSION:-}" ]    && echo "  CAST version:    $CAST_VERSION"
[ -n "${AGENT_COUNT:-}" ]     && echo "  Agents:          $AGENT_COUNT"
[ -n "${TEST_COUNT:-}" ]      && echo "  Tests:           $TEST_COUNT across $TEST_FILE_COUNT files"
[ -n "${TABLE_COUNT:-}" ]     && echo "  DB tables:       $TABLE_COUNT"
echo "  Per-package versions: scanned $PERSONAL_ROOT"
