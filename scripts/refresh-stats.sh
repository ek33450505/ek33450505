#!/usr/bin/env bash
# refresh-stats.sh — Refresh dynamic stats in the GitHub profile README.
#
# Reads counts and versions from sibling repos in ~/Projects/personal/ and
# updates sentinel tokens in README.md. Sentinel format:
#   <!-- TOKEN -->value<!-- /TOKEN -->
#
# Tokens managed:
#   CAST_VERSION          — from cast-stats.json (fallback: VERSION file)
#   CAST_AGENT_COUNT      — from cast-stats.json (fallback: agents/core/*.md count)
#   CAST_TEST_COUNT       — from cast-stats.json (fallback: @test count in .bats files)
#   CAST_DB_TABLE_COUNT   — from cast-stats.json (fallback: CREATE TABLE in cast-db-init.sh)
#   CAST_COMMAND_COUNT    — from cast-stats.json (no fallback)
#   CAST_SKILL_COUNT      — from cast-stats.json (no fallback)
#   CAST_PACKAGE_COUNT    — from cast-stats.json (no fallback)
#   VERSION:<repo>        — version from ~/Projects/personal/<repo>/
#                           (VERSION file, package.json, pyproject.toml, or <pkg>/__init__.py)
#
# Usage:
#   bash scripts/refresh-stats.sh                 # update README in this repo
#   bash scripts/refresh-stats.sh /path/to/README # update an explicit file
#
# Source of truth: cast-stats.json in sibling claude-agent-team repo. Falls back
# to filesystem derivation if the JSON is absent. If a sibling repo is missing
# entirely, sentinels are left unchanged (stale rather than blank).

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

# fmt_int: normalize a raw integer string (e.g. "1736" → "1736"), passing non-numeric
# values through unchanged. Emits RAW integers with NO thousands separator — the canonical
# cast-stats-drift-check compares sentinel values by exact string match, so "1,797" would
# fail against "1797". Keep counts comma-free.
fmt_int() {
  python3 -c "v='$1'; print(f'{int(v)}' if v.isdigit() else v)" 2>/dev/null || echo "$1"
}

# --- Framework-level counts (from claude-agent-team) ---
# Primary source: cast-stats.json (canonical, eliminates drift vs. re-derived values).
# Fallback: filesystem derivation (preserves "stale not blank" when JSON is absent).
CAST_VERSION=""
AGENT_COUNT=""
TEST_COUNT=""
TABLE_COUNT=""
COMMAND_COUNT=""
SKILL_COUNT=""
PACKAGE_COUNT=""

if [ -d "$CAST_REPO" ]; then
  STATS_JSON="$CAST_REPO/cast-stats.json"

  if [ -f "$STATS_JSON" ]; then
    # Primary path: read every field from the canonical JSON.
    # version is a plain string; counts are emitted as RAW integers (no thousands
    # separator) to stay byte-compatible with the exact-match cast-stats-drift-check.
    CAST_VERSION="$(python3 -c "import json; d=json.load(open('$STATS_JSON')); print(d.get('version',''))" 2>/dev/null || echo "")"
    AGENT_COUNT="$(python3 -c "import json; d=json.load(open('$STATS_JSON')); v=d.get('agents',''); print(f'{int(v)}' if v != '' else '')" 2>/dev/null || echo "")"
    TEST_COUNT="$(python3 -c "import json; d=json.load(open('$STATS_JSON')); v=d.get('tests',''); print(f'{int(v)}' if v != '' else '')" 2>/dev/null || echo "")"
    TABLE_COUNT="$(python3 -c "import json; d=json.load(open('$STATS_JSON')); v=d.get('tables',''); print(f'{int(v)}' if v != '' else '')" 2>/dev/null || echo "")"
    COMMAND_COUNT="$(python3 -c "import json; d=json.load(open('$STATS_JSON')); v=d.get('commands',''); print(f'{int(v)}' if v != '' else '')" 2>/dev/null || echo "")"
    SKILL_COUNT="$(python3 -c "import json; d=json.load(open('$STATS_JSON')); v=d.get('skills',''); print(f'{int(v)}' if v != '' else '')" 2>/dev/null || echo "")"
    PACKAGE_COUNT="$(python3 -c "import json; d=json.load(open('$STATS_JSON')); v=d.get('packages',''); print(f'{int(v)}' if v != '' else '')" 2>/dev/null || echo "")"

    [ -n "$CAST_VERSION" ]  && update_token "CAST_VERSION"       "$CAST_VERSION"
    [ -n "$AGENT_COUNT" ]   && update_token "CAST_AGENT_COUNT"   "$AGENT_COUNT"
    [ -n "$TEST_COUNT" ]    && update_token "CAST_TEST_COUNT"     "$TEST_COUNT"
    [ -n "$TABLE_COUNT" ]   && update_token "CAST_DB_TABLE_COUNT" "$TABLE_COUNT"
    [ -n "$COMMAND_COUNT" ] && update_token "CAST_COMMAND_COUNT"  "$COMMAND_COUNT"
    [ -n "$SKILL_COUNT" ]   && update_token "CAST_SKILL_COUNT"    "$SKILL_COUNT"
    [ -n "$PACKAGE_COUNT" ] && update_token "CAST_PACKAGE_COUNT"  "$PACKAGE_COUNT"

  else
    # Fallback path: derive counts from filesystem (cast-stats.json absent).
    echo "[refresh-stats] $STATS_JSON not found — falling back to filesystem derivation" >&2
    (cd "$CAST_REPO"

      if [ -f VERSION ]; then
        CAST_VERSION="$(tr -d '[:space:]' < VERSION)"
        update_token "CAST_VERSION" "$CAST_VERSION"
      fi

      AGENT_COUNT=$(fmt_int "$(git ls-files 'agents/core/*.md' 2>/dev/null | grep -cE '^agents/core/[^/]+\.md$' || echo 0)")
      update_token "CAST_AGENT_COUNT" "$AGENT_COUNT"

      TEST_FILES=$(git ls-files 'tests/*.bats' 'tests/*/*.bats' 2>/dev/null || true)
      if [ -n "$TEST_FILES" ]; then
        TEST_COUNT=$(fmt_int "$(echo "$TEST_FILES" | xargs grep -h "^@test" 2>/dev/null | wc -l | tr -d ' ')")
        TEST_FILE_COUNT=$(fmt_int "$(echo "$TEST_FILES" | wc -l | tr -d ' ')")
      else
        TEST_COUNT=0
        TEST_FILE_COUNT=0
      fi
      update_token "CAST_TEST_COUNT" "$TEST_COUNT"
      update_token "CAST_TEST_FILE_COUNT" "$TEST_FILE_COUNT"

      # Derive DB table count from cast-db-init.sh CREATE TABLE statements (canonical source of truth).
      # Uses line-anchored grep to exclude comment lines that contain "CREATE TABLE" as prose.
      # Falls back to cast_db.py ALLOWED_TABLES if init script is absent (e.g., older repo checkouts).
      if [ -f "scripts/cast-db-init.sh" ]; then
        TABLE_COUNT=$(fmt_int "$(grep -E '^CREATE TABLE (IF NOT EXISTS )?[a-z_][a-z0-9_]* \(' "scripts/cast-db-init.sh" \
          | grep -oE '[a-z_][a-z0-9_]* \(' | grep -oE '^[a-z_][a-z0-9_]*' | sort -u | wc -l | tr -d ' ')")
        update_token "CAST_DB_TABLE_COUNT" "$TABLE_COUNT"
      elif [ -f "scripts/cast_db.py" ]; then
        TABLE_COUNT=$(fmt_int "$(awk '/ALLOWED_TABLES[[:space:]]*=[[:space:]]*\{/{f=1} f{print} /\}/{if(f)exit}' "scripts/cast_db.py" \
          | grep -oE "['\"][a-z_][a-z0-9_]*['\"]" | sort -u | wc -l | tr -d ' ')")
        update_token "CAST_DB_TABLE_COUNT" "$TABLE_COUNT"
      fi
    )
  fi
else
  echo "[refresh-stats] $CAST_REPO not found — skipping framework-level counts" >&2
fi

# --- Per-package versions ---
# Walk every sibling repo and resolve its version by probing (first match wins):
#   1. VERSION file (CAST convention)
#   2. package.json "version" (Node projects)
#   3. pyproject.toml [project].version or [tool.poetry].version (Python projects)
#   4. <pkg>/__init__.py __version__ assignment (Python packages, final catch-all)
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
    # Fall back to pyproject.toml (Python projects): tomllib first, then a bare grep.
    elif [ -f "$repo_dir/pyproject.toml" ]; then
      version="$(PYPROJECT="$repo_dir/pyproject.toml" python3 -c '
import os
try:
    import tomllib
    with open(os.environ["PYPROJECT"], "rb") as f:
        d = tomllib.load(f)
    print(d.get("project", {}).get("version", "") or d.get("tool", {}).get("poetry", {}).get("version", ""))
except Exception:
    pass
' 2>/dev/null || echo "")"
      if [ -z "$version" ]; then
        version="$(grep -m1 '^version = "' "$repo_dir/pyproject.toml" | sed 's/^version = "\(.*\)"/\1/' 2>/dev/null || echo "")"
      fi
    fi
    # Final catch-all: scan <repo>/*/__init__.py for __version__ = '...' or "..."
    if [ -z "$version" ]; then
      for init_file in "$repo_dir"*/__init__.py; do
        [ -f "$init_file" ] || continue
        v="$(grep -m1 -E "^__version__[[:space:]]*=" "$init_file" 2>/dev/null | sed -n "s/__version__[[:space:]]*=[[:space:]]*['\"]\([^'\"]*\)['\"].*/\1/p" 2>/dev/null || echo "")"
        if [ -n "$v" ]; then
          version="$v"
          break
        fi
      done
    fi
    [ -n "$version" ] || continue
    update_token "VERSION:$repo_name" "$version"
  done
fi

rm -f "${README}.bak"

# --- Report what changed ---
echo "Profile stats refreshed:"
[ -n "${CAST_VERSION:-}" ]  && echo "  CAST version:    $CAST_VERSION"
[ -n "${AGENT_COUNT:-}" ]   && echo "  Agents:          $AGENT_COUNT"
[ -n "${TEST_COUNT:-}" ]    && echo "  Tests:           $TEST_COUNT"
[ -n "${TABLE_COUNT:-}" ]   && echo "  DB tables:       $TABLE_COUNT"
[ -n "${COMMAND_COUNT:-}" ] && echo "  Commands:        $COMMAND_COUNT"
[ -n "${SKILL_COUNT:-}" ]   && echo "  Skills:          $SKILL_COUNT"
[ -n "${PACKAGE_COUNT:-}" ] && echo "  Packages:        $PACKAGE_COUNT"
echo "  Per-package versions: scanned $PERSONAL_ROOT"
