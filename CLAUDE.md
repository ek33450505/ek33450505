# CLAUDE.md — ek33450505 Profile README Repo

## Overview
GitHub special profile README repo (renders as profile page). No build/test surface — only documentation and automated stat refresh.

## Stat Refresh Pipeline

The `scripts/refresh-stats.sh` bash script syncs dynamic counts from the CAST framework repos:

```bash
bash scripts/refresh-stats.sh
```

Reads from `~/Projects/personal/claude-agent-team` and `~/Projects/personal/cast-desktop`, then updates sentinel tokens in `README.md`.

## Automated Weekly PR

`.github/workflows/refresh-stats.yml` — **scheduled Monday 09:00 UTC** — automatically opens stat-update PRs.

- Checks out sibling repos (`claude-agent-team`, `cast-desktop`)
- Runs `refresh-stats.sh` with `PERSONAL_ROOT` pointing to the checkout
- If stats changed, opens PR via `peter-evans/create-pull-request`
- Auto-merge after CI green is safe — docs-only change

**Prerequisite:** Repo Settings → Actions → General → Workflow permissions must allow "GitHub Actions to create and approve pull requests."

## Sentinels

The following tokens auto-update in `README.md` from `~/Projects/personal/claude-agent-team/cast-stats.json`:

- `<!-- CAST_VERSION -->` — CAST framework version (e.g., 8.0.0)
- `<!-- CAST_AGENT_COUNT -->` — Total agents (17 lean + 4 opt-in via --with-extras)
- `<!-- CAST_TEST_COUNT -->` — Total BATS tests across all files
- `<!-- CAST_DB_TABLE_COUNT -->` — Distinct tables in cast.db (36 in v8)
- `<!-- CAST_COMMAND_COUNT -->` — Top-level commands (20 in v8)
- `<!-- CAST_SKILL_COUNT -->` — Callable skills (18 in v8)
- `<!-- CAST_PACKAGE_COUNT -->` — Homebrew-installable packages (13 in v8)
- `<!-- VERSION:cast-desktop -->` — Tracked separately; auto-updated by refresh-stats.sh

Format: `<!-- TOKEN_NAME -->value<!-- /TOKEN_NAME -->`

**Deprecated (v8):** `CAST_TEST_FILE_COUNT` — no longer in canonical stats; dropped from README.

## Bug Artifact: Tilde Directory

A literal `~` directory exists at repo root — a bug artifact from past tilde non-expansion during initial setup. Leave it alone; it is harmless and tracked in `.gitignore`.
