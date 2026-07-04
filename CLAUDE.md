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

The following CAST framework count tokens auto-update in `README.md` from `~/Projects/personal/claude-agent-team/cast-stats.json`:

- `<!-- CAST_AGENT_COUNT -->` — Total agents (23 in v8+)
- `<!-- CAST_TEST_COUNT -->` — Total BATS tests across all files
- `<!-- CAST_DB_TABLE_COUNT -->` — Distinct tables in cast.db (39 in v8+)
- `<!-- CAST_COMMAND_COUNT -->` — Top-level commands (21 in v8+)
- `<!-- CAST_SKILL_COUNT -->` — Callable skills (17 in v8+)
- `<!-- CAST_PACKAGE_COUNT -->` — Homebrew-installable packages (9 in v8+)

Per-project versions (no longer auto-refreshed in `README.md`):

The `CAST_VERSION` and `VERSION:*` sentinels have been removed from `README.md` along with the "Latest" version column from "Projects at a glance". Per-project versions now appear only via live release badges in "The CAST ecosystem" table and PyPI badges in the guardrail deep-dives. The CAST version appears in the dynamic top-of-README badge and the auto-generated SVG card. `refresh-stats.sh` still resolves these values harmlessly — it only rewrites tokens that exist in the file.

Format: `<!-- TOKEN_NAME -->value<!-- /TOKEN_NAME -->`. Sentinels for repos not currently in `README.md` are simply skipped — `refresh-stats.sh` only rewrites tokens that exist in the file.

**Version display:** The "Latest" version column has been removed from "Projects at a glance" to reduce manual maintenance burden. Per-project versions now appear only via live release badges in the "The CAST ecosystem" section tables and PyPI badges in the guardrail deep-dives (looptrip, misfire). The CAST framework version appears in the dynamic top-of-README badge and the auto-generated SVG card — no sentinel tokens.

**Deprecated (v8):** `CAST_TEST_FILE_COUNT` — no longer in canonical stats; dropped from README.

**Note:** per-project *test counts* (e.g. attest 302, looptrip 491) have been removed from the README to eliminate manual-update burden. Only live PyPI badges (looptrip, misfire) remain in the guardrail deep-dives.

## Bug Artifact: Tilde Directory

A literal `~` directory exists at repo root — a bug artifact from past tilde non-expansion during initial setup. Leave it alone; it is harmless and tracked in `.gitignore`.
