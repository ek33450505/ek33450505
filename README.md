# Edward Kubiak

> **Agent infrastructure engineer** — I build the layer between you and the agent loop.

<!--[![Open to work](https://img.shields.io/badge/Open%20to%20work-green?style=flat-square)](https://linkedin.com/in/edward-kubiak/)-->
[![CAST](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fraw.githubusercontent.com%2Fek33450505%2Fclaude-agent-team%2Fmain%2Fcast-stats.json&query=%24.version&label=CAST&style=flat-square)](https://github.com/ek33450505/claude-agent-team)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=flat-square)](LICENSE)
[![Tests](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fraw.githubusercontent.com%2Fek33450505%2Fclaude-agent-team%2Fmain%2Fcast-stats.json&query=%24.tests&label=tests&style=flat-square)](https://github.com/ek33450505/claude-agent-team/tree/main/tests)

**Columbus, Ohio** · [edwardkubiak.com](https://edwardkubiak.com) · [LinkedIn](https://linkedin.com/in/edward-kubiak/) · [edward.kubiak.dev@gmail.com](mailto:edward.kubiak.dev@gmail.com)

By day, I architect and maintain production EdTech at META Solutions — 5 apps serving 4,200+ users across 900+ Ohio school districts.

**Open to roles on agent infrastructure, developer tools, and Claude Code platform teams.**

---

## What I work on

Multi-agent systems fail in predictable ways: routing is opaque, memory bleeds across agents, policy is aspirational, and observability stops at the tool call. I've spent the last six months building [**CAST**](https://github.com/ek33450505/claude-agent-team) to fill those gaps — observability, orchestration, persistent memory, and hard-blocking policy enforcement.

CAST is a local-first OS layer for Claude Code: hook-driven agent dispatch, typed event sourcing in SQLite, per-agent memory isolation, and policy gates that refuse dangerous operations at the seam.

---

## CAST — Native CAST (v8)

[`claude-agent-team`](https://github.com/ek33450505/claude-agent-team) · Bash · MIT · **v<!-- CAST_VERSION -->8.0.0<!-- /CAST_VERSION -->** · **<!-- CAST_AGENT_COUNT -->23<!-- /CAST_AGENT_COUNT --> agents** · **<!-- CAST_TEST_COUNT -->1797<!-- /CAST_TEST_COUNT --> tests**

### The Problem It Solves

Multi-agent systems need observability, persistence, and unforgeable policy. CAST ships both in v8:

**Local-first by construction.** `cast.db` (SQLite) replicates outside `~/.claude` via Litestream — your data is yours, observability is yours, and the database survives a full `~/.claude` wipe. No cloud round-trip. The dashboard is a SELECT away.

**Data integrity by construction.** Pre-commit hooks block force-pushes and raw `git commit`. A fail-closed migration gate guards schema changes. PreToolUse hooks refuse `pkill`, `killall`, `rm -rf` from agent code — dangerous operations are killed at the seam, not left to agent discipline.

### Install

Copy-paste one:

```bash
# Claude Code native plugin (recommended for v8)
/plugin marketplace add ek33450505/claude-agent-team
/plugin install cast
/plugin enable cast@cast
```

```bash
# or via Homebrew
brew tap ek33450505/cast && brew install cast
```

### Capabilities

v<!-- CAST_VERSION -->8.0.0<!-- /CAST_VERSION --> · <!-- CAST_AGENT_COUNT -->23<!-- /CAST_AGENT_COUNT --> agents · <!-- CAST_TEST_COUNT -->1797<!-- /CAST_TEST_COUNT --> tests · <!-- CAST_DB_TABLE_COUNT -->36<!-- /CAST_DB_TABLE_COUNT --> tables · <!-- CAST_COMMAND_COUNT -->20<!-- /CAST_COMMAND_COUNT --> commands · <!-- CAST_SKILL_COUNT -->18<!-- /CAST_SKILL_COUNT --> skills · <!-- CAST_PACKAGE_COUNT -->13<!-- /CAST_PACKAGE_COUNT --> packages

**Design decisions worth defending:**

- **Hook-driven dispatch over polling.** Claude Code emits lifecycle events (`SessionStart`, `PreToolUse`, `SubagentStop`, `Stop`). CAST hangs all routing, telemetry, and policy off those — no daemon, no background loop, no missed events.
- **Local-first SQLite everywhere.** Agent runs, routing decisions, memory, quality gates, hook output — all in `~/.claude/cast.db`. No cloud dependency.
- **Per-agent memory, not shared context.** Each agent keeps scoped memory under `~/.claude/agent-memory-local/<agent>/`. Isolation by default; coordination via `cellar-door` when needed.
- **Hard-blocking policy gates.** Force-pushes, raw `git commit`, destructive shell ops — the hook layer refuses them. Quality enforced at the seam.
- **Eval harness with pass@k metrics.** `cast eval` runs pass@k benchmarks; `eval_runs` table tracks results over time for quantifying agent quality.
- **Typed agent handoffs.** `schemas/agent-handoff.json` ensures downstream agents receive well-formed context — kills silent cascade failures in multi-agent chains.

---

## cast-desktop — Native Observability for CAST

[`cast-desktop`](https://github.com/ek33450505/cast-desktop) · Tauri 2 + Rust + TypeScript · MIT · **v<!-- VERSION:cast-desktop -->1.2.12<!-- /VERSION:cast-desktop -->**

The claude-code-dashboard requires a running server. cast-desktop packages CAST observability as a self-contained Tauri 2 native app — no Node, no server management.

The desktop app binds native infrastructure to Claude Code's agent execution model:

- **Native PTY terminal** (xterm.js backend + Rust pty layer) with persistent pane-to-session binding. Every pane is tracked in `pane_bindings` table — cast.db always knows which agent run owns which terminal pane.
- **Inline code editor** (CodeMirror 6 + TypeScript LSP sidecar) with agent dispatch. Select code, spawn a CAST agent, results stream back inline.
- **Full cast.db coverage**: 70+ Express routes, read-only by default, loopback-only. Surfaces 36 tables: sessions, agent runs, routing decisions, memory, hook events, cost telemetry, pane bindings.
- **Live session cost SSE**: streams per-session burn rate ($/min) and 4-hour cost projection as tokens flow.
- **Homebrew installable**: `brew tap ek33450505/cast-desktop && brew install cast-desktop`

---

## attest — Completion-Attestation Gate for Claude Code

[`attest`](https://github.com/ek33450505/attest) · Python 3 (stdlib-only) · MIT · **v0.1.0** · **290 tests** · CI green

> **"DONE" is a claim, not proof. Grade the act, not the output.**

My newest standalone OSS tool — and the one I'm proudest of the discipline behind. Multi-agent workflows fail in a quiet way: a subagent reports `Status: DONE` in good faith after a `Write` that returned success but never landed on disk. A silent write-failure behind a confident `DONE`. Attest catches it.

It's a local, deterministic, **zero-LLM** Claude Code hook. `SubagentStart` snapshots the git working tree; `SubagentStop` recomputes the delta, parses the subagent's `Status: DONE` / `## Handoff` claim, and checks whether the files it *claimed* to change actually changed. If a claimed file never landed, it (opt-in) **blocks** the completion so the same subagent is forced to continue and fix it.

**Design decisions worth defending:**

- **Deterministic and zero-LLM.** It never calls a model — so it adds no tokens and *cannot hallucinate its own verdict*. The git tree is the only ground truth; Attest grades the *act*, not the output.
- **Fail-open on every doubt.** A parse error, a missing file, a slow run → the hook exits 0 and the session continues. It blocks only on *proof* of a false `DONE`, and only in opt-in enforce mode (`ATTEST_ENFORCE=1`). A conservative parser never treats a missing or prose-only claim as a false `DONE`.
- **Verified against the running system, not the docs.** Validated end-to-end against real Claude Code v2.1.170 with captured payloads committed to the repo — including proving that a synchronous `SubagentStop` hook *can* block a completion, which the official docs don't promise. The tool's own thesis, applied to its own foundation.

### Install

```bash
# Claude Code plugin
/plugin marketplace add https://github.com/ek33450505/attest
/plugin install attest@attest
```

```bash
# or via Homebrew
brew tap ek33450505/attest && brew install attest
```

---

## looptrip — Multi-Agent Coordination-Pathology Detector

[`looptrip`](https://github.com/ek33450505/looptrip) · Python 3 (stdlib-only core) · Apache-2.0 · **v0.1.0** · **491 tests** · live on [PyPI](https://pypi.org/project/looptrip/)

> **Catch the loop at iteration 2 — not on the invoice.**

A standalone OSS detector for the failure mode that quietly burns money in multi-agent systems: they *loop*. The same subagent gets dispatched again and again with no progress between repeats — duplicate-work, ping-pong / livelock, deadlock, non-termination — and you find out on the bill. looptrip watches a run as a stream of normalized events and trips at the **second** dispatch, the first repeat, instead of letting the loop run to exhaustion.

**Design decisions worth defending:**

- **Deterministic and zero-LLM.** Same event stream → same verdict; it adds no tokens and cannot hallucinate its own finding. The structure of the run is the only ground truth.
- **An observer, never a gate.** It reports; it never blocks, kills, or auto-fixes. What to do about a loop stays the human's call — blocking is a different tool's job.
- **Detection-first, over data you already have.** Works over OpenTelemetry GenAI handoff spans or a CAST `cast.db` — no new instrumentation — plus a live `SpanProcessor` for in-flight detection.
- **Proven on real money.** On two real recorded runaway sessions, tripping at iteration 2 would have averted **$792.96** of duplicate-work spend — reproducible in one command (`looptrip proof`), triple-anchored against a byte-faithful fixture and an independent oracle.

### Install

```bash
# Claude Code plugin
/plugin marketplace add https://github.com/ek33450505/looptrip
/plugin install looptrip@looptrip
```

```bash
# or via Homebrew / PyPI
brew tap ek33450505/looptrip && brew install looptrip
pip install looptrip
```

---

## The CAST Ecosystem

<details>
<summary>13 Homebrew-installable packages</summary>

<!-- Auto-synced from claude-agent-team/docs/ecosystem.md. Run scripts/sync-ecosystem-readme.sh to refresh. -->

<!-- ECOSYSTEM_START -->
| Repo | Description | Latest | Install |
|---|---|---|---|
| [cast-hooks](https://github.com/ek33450505/cast-hooks) | 13 auditable hook scripts — observability, safety guards, quality gates. SessionStart, PreToolUse, PostToolUse, PostCompact. | ![](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fraw.githubusercontent.com%2Fek33450505%2Fclaude-agent-team%2Fmain%2Fecosystem-versions.json&query=%24%5B%22cast-hooks%22%5D&label=cast-hooks&style=flat-square) | `brew tap ek33450505/cast-hooks && brew install cast-hooks` |
| [cast-agents](https://github.com/ek33450505/cast-agents) | 23 specialist agents — commit, debug, review, plan, test, research, and more. Agent definitions with YAML frontmatter. v8-synced. | ![](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fraw.githubusercontent.com%2Fek33450505%2Fclaude-agent-team%2Fmain%2Fecosystem-versions.json&query=%24%5B%22cast-agents%22%5D&label=cast-agents&style=flat-square) | `brew tap ek33450505/cast-agents && brew install cast-agents` |
| [cast-memory](https://github.com/ek33450505/cast-memory) | Persistent agent memory with FTS5 search, relevance scoring, shared pool, semantic embeddings. Per-agent knowledge accumulation. | ![](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fraw.githubusercontent.com%2Fek33450505%2Fclaude-agent-team%2Fmain%2Fecosystem-versions.json&query=%24%5B%22cast-memory%22%5D&label=cast-memory&style=flat-square) | `brew tap ek33450505/cast-memory && brew install cast-memory` |
| [cast-routines](https://github.com/ek33450505/cast-routines) | Scheduled autonomous Claude Code routines via YAML + cron. Daily briefings, inbox triage, release celebration, weekly cost reports. | ![](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fraw.githubusercontent.com%2Fek33450505%2Fclaude-agent-team%2Fmain%2Fecosystem-versions.json&query=%24%5B%22cast-routines%22%5D&label=cast-routines&style=flat-square) | `brew tap ek33450505/cast-routines && brew install cast-routines` |
| [cast-parallel](https://github.com/ek33450505/cast-parallel) | Parallel agent execution across worktree sessions. Agent Dispatch Manifest (ADM) support. | ![](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fraw.githubusercontent.com%2Fek33450505%2Fclaude-agent-team%2Fmain%2Fecosystem-versions.json&query=%24%5B%22cast-parallel%22%5D&label=cast-parallel&style=flat-square) | `brew tap ek33450505/cast-parallel && brew install cast-parallel` |
| [cast-observe](https://github.com/ek33450505/cast-observe) | Session-level observability — cost tracking, agent run history, token spend, event sourcing. Feeds cast.db. | ![](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fraw.githubusercontent.com%2Fek33450505%2Fclaude-agent-team%2Fmain%2Fecosystem-versions.json&query=%24%5B%22cast-observe%22%5D&label=cast-observe&style=flat-square) | `brew tap ek33450505/cast-observe && brew install cast-observe` |
| [cast-security](https://github.com/ek33450505/cast-security) | Security hooks and audit trails. PII redaction, parry-guard integration, compliance logging. | ![](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fraw.githubusercontent.com%2Fek33450505%2Fclaude-agent-team%2Fmain%2Fecosystem-versions.json&query=%24%5B%22cast-security%22%5D&label=cast-security&style=flat-square) | `brew tap ek33450505/cast-security && brew install cast-security` |
| [cast-doctor](https://github.com/ek33450505/cast-doctor) | Read-only health check for any Claude Code install. Validates hooks, MCP servers, agent frontmatter, cast.db schema, stale memories. | ![](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fraw.githubusercontent.com%2Fek33450505%2Fclaude-agent-team%2Fmain%2Fecosystem-versions.json&query=%24%5B%22cast-doctor%22%5D&label=cast-doctor&style=flat-square) | `brew tap ek33450505/cast-doctor && brew install cast-doctor` |
| [cast-time](https://github.com/ek33450505/cast-time) | Gives Claude Code a clock — injects local time, timezone, and a semantic time-of-day bucket at every SessionStart. | ![](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fraw.githubusercontent.com%2Fek33450505%2Fclaude-agent-team%2Fmain%2Fecosystem-versions.json&query=%24%5B%22cast-time%22%5D&label=cast-time&style=flat-square) | `brew tap ek33450505/cast-time && brew install cast-time` |
| [cast-dash](https://github.com/ek33450505/cast-dash) | Terminal UI dashboard for live swarm monitoring. 4-panel real-time display (Textual framework). | ![](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fraw.githubusercontent.com%2Fek33450505%2Fclaude-agent-team%2Fmain%2Fecosystem-versions.json&query=%24%5B%22cast-dash%22%5D&label=cast-dash&style=flat-square) | `brew tap ek33450505/cast-dash && brew install cast-dash` |
| [cast-claudes_journal](https://github.com/ek33450505/cast-claudes_journal) | Session continuity — Claude's Journal auto-injects prior-day context via SessionStart hook. Obsidian vault sync. | ![](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fraw.githubusercontent.com%2Fek33450505%2Fclaude-agent-team%2Fmain%2Fecosystem-versions.json&query=%24%5B%22cast-claudes_journal%22%5D&label=cast-claudes_journal&style=flat-square) | `brew tap ek33450505/homebrew-claudes-journal && brew install claudes-journal` |
| [cast-website](https://github.com/ek33450505/cast-website) | castframework.dev — marketing site and docs portal for the CAST ecosystem. | ![](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fraw.githubusercontent.com%2Fek33450505%2Fclaude-agent-team%2Fmain%2Fecosystem-versions.json&query=%24%5B%22cast-website%22%5D&label=cast-website&style=flat-square) | — |
| [cast-desktop](https://github.com/ek33450505/cast-desktop) | Tauri 2 native app — embedded PTY terminal, command palette, ~20 dashboard views. v8-synced. | ![](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fraw.githubusercontent.com%2Fek33450505%2Fclaude-agent-team%2Fmain%2Fecosystem-versions.json&query=%24%5B%22cast-desktop%22%5D&label=cast-desktop&style=flat-square) | `brew tap ek33450505/homebrew-cast-desktop && brew install cast-desktop` |
<!-- ECOSYSTEM_END -->

</details>

<!--

## Also Building

Not part of CAST proper, but built alongside:

- [**aether**](https://github.com/ek33450505/aether) — Tauri 2 AI-aware terminal for macOS.
- [**forge**](https://github.com/ek33450505/forge) — Native macOS terminal for AI-native development.
- [**promptbot**](https://github.com/ek33450505/promptbot) — Local-first CLI prompt rewriter.
- [**cellar-door**](https://github.com/ek33450505/cellar-door) — Typed shared memory for local AI agents.

--->

## Stack

Bash · Python · TypeScript · React 19 · Express 5 · SQLite · BATS · Vitest · Tauri 2 · GitHub Actions · Homebrew. macOS first, Linux supported. Anthropic API + Claude Code Agent SDK.

---

## Get in touch

Building in public. Questions, feedback, or interest in collaborating? Reach out:

**Email:** [edward.kubiak.dev@gmail.com](mailto:edward.kubiak.dev@gmail.com) · **Portfolio:** [edwardkubiak.com](https://edwardkubiak.com) · **LinkedIn:** [linkedin.com/in/edward-kubiak/](https://linkedin.com/in/edward-kubiak/)
