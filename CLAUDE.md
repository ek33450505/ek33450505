# CLAUDE.md — ek33450505 Profile README Repo

## Overview
GitHub special profile README repo (renders as profile page). No build/test surface — only documentation and automated stat refresh.

## Stat Refresh Pipeline

The `scripts/refresh-stats.sh` bash script syncs dynamic counts from the CAST framework repos:

```bash
bash scripts/refresh-stats.sh
```

Reads framework counts from `~/Projects/personal/claude-agent-team/cast-stats.json`, then walks **every** sibling repo under `~/Projects/personal/` to resolve each project's version (precedence: `VERSION` file → `package.json` → `pyproject.toml` → `<pkg>/__init__.py`), and updates the sentinel tokens in `README.md`. `scripts/gen-ecosystem-card.py` regenerates the hero card from the same `cast-stats.json` as **two** deterministic variants — `assets/ecosystem-card.svg` (dark, the default/fallback) and `assets/ecosystem-card-light.svg` (light) — which `README.md` renders through a `<picture>` element so GitHub serves the right one per viewer theme (deterministic — no timestamps, so identical input yields identical bytes).

## Automated Weekly PR

`.github/workflows/refresh-stats.yml` — **scheduled Monday 09:00 UTC** — automatically opens stat-update PRs.

- Checks out sibling repos (`claude-agent-team`, `cast-desktop`, `claude-code-dashboard`, `attest`, `looptrip`, `misfire`)
- Runs `refresh-stats.sh` with `PERSONAL_ROOT` pointing to the checkout
- Regenerates both `assets/ecosystem-card.svg` (dark) and `assets/ecosystem-card-light.svg` (light) via `gen-ecosystem-card.py`
- If `README.md` or either SVG changed, opens PR via `peter-evans/create-pull-request`
- Auto-merge after CI green is safe — docs-only change

**Prerequisite:** Repo Settings → Actions → General → Workflow permissions must allow "GitHub Actions to create and approve pull requests."

## CI Gates

Two jobs in `.github/workflows/cast-stats-check.yml` gate profile freshness on every PR and push to `main`:

- **`cast-stats-drift-check`** — compares the README `CAST_*` sentinels against canonical `cast-stats.json` (via the reusable `claude-agent-team` action).
- **`svg-drift-check`** — checks out canonical stats, regenerates the SVGs, and `git diff --exit-code`s them, so a hand-edited or stale hero card cannot merge. Relies on `gen-ecosystem-card.py` being byte-deterministic.

## Sentinels

The following tokens auto-update in `README.md` from `~/Projects/personal/claude-agent-team/cast-stats.json`:

- `<!-- CAST_VERSION -->` — CAST framework version (e.g., 8.0.0)
- `<!-- CAST_AGENT_COUNT -->` — Total agents (17 lean + 4 opt-in via --with-extras)
- `<!-- CAST_TEST_COUNT -->` — Total BATS tests across all files
- `<!-- CAST_DB_TABLE_COUNT -->` — Distinct tables in cast.db (36 in v8)
- `<!-- CAST_COMMAND_COUNT -->` — Top-level commands (20 in v8)
- `<!-- CAST_SKILL_COUNT -->` — Callable skills (18 in v8)
- `<!-- CAST_PACKAGE_COUNT -->` — Homebrew-installable packages (13 in v8)

Per-project version tokens (resolved from each sibling repo, not `cast-stats.json`):

- `<!-- VERSION:cast-desktop -->` — from `package.json`
- `<!-- VERSION:claude-code-dashboard -->` — from `package.json`
- `<!-- VERSION:attest -->` — from `attest/__init__.py` `__version__`
- `<!-- VERSION:looptrip -->` — from `pyproject.toml`
- `<!-- VERSION:misfire -->` — from `pyproject.toml` (added when misfire ships; harmless if absent)

Format: `<!-- TOKEN_NAME -->value<!-- /TOKEN_NAME -->`. Sentinels for repos not currently in `README.md` are simply skipped — `refresh-stats.sh` only rewrites tokens that exist in the file.

**Version placement (sparse):** each project's version appears **once** — in the *Projects at a glance* table (column headed *Latest*). The collapsible detail-section headers intentionally omit it; do not re-add `VERSION:*` / `CAST_VERSION` tokens there. Live badges (top-of-README dynamic badges, ecosystem release badges, PyPI badges) are the exception — they read upstream directly and don't drift.

**Deprecated (v8):** `CAST_TEST_FILE_COUNT` — no longer in canonical stats; dropped from README.

**Note:** per-project *test counts* (e.g. attest 302, looptrip 491) are NOT auto-refreshed — they are hand-verified at edit time. Versions auto-refresh; test counts do not.

## Bug Artifact: Tilde Directory

A literal `~` directory exists at repo root — a bug artifact from past tilde non-expansion during initial setup. Leave it alone; it is harmless and tracked in `.gitignore`.
