# Edward Kubiak

> Agent infrastructure engineer. I build the layer between you and the agent loop.

Columbus, Ohio · [edwardkubiak.com](https://edwardkubiak.com) · [LinkedIn](https://www.linkedin.com/in/edward-kubiak-bbbaa6401/) · [edward.kubiak.dev@gmail.com](mailto:edward.kubiak.dev@gmail.com)

**Open to roles on agent infrastructure, developer tools, and Claude Code platform teams.**

---

## What I work on

Lately I’ve been focused on the operational side of multi-agent systems — routing, memory, observability, policy gates — the kinds of details that make the difference between an impressive demo and something reliable enough to leave running on its own.

For the last six months, I’ve been building [**CAST**](https://github.com/ek33450505/claude-agent-team), a local-first OS layer for Claude Code, plus its native desktop observability surface and a handful of smaller supporting packages around it.

---

## CAST — Claude Agent Specialist Team

[`claude-agent-team`](https://github.com/ek33450505/claude-agent-team) · Bash · MIT · **v<!-- CAST_VERSION -->7.0<!-- /CAST_VERSION -->** — backend lockdown

Claude Code ships with a powerful agent primitive and almost no scaffolding around it. CAST is the scaffolding: <!-- CAST_AGENT_COUNT -->23<!-- /CAST_AGENT_COUNT --> specialist agents, hook-driven dispatch, model-tier routing, per-agent persistent memory, and a 37-table SQLite event store that makes the whole loop legible.

```sh
brew tap ek33450505/cast && brew install cast
```

**A few of the design decisions worth defending:**

- **Hook-driven dispatch over polling.** Claude Code emits lifecycle events (`SessionStart`, `PreToolUse`, `SubagentStop`, `Stop`). CAST hangs all routing, telemetry, and policy off those — no daemon, no background loop, no missed events. The harness is the orchestrator.
- **Local-first, SQLite everywhere.** Agent runs, routing decisions, memory, quality gates, hook output — all in `~/.claude/cast.db`. No cloud round-trip. The dashboard is just a SELECT away. Data is yours; observability is yours.
- **Per-agent memory, not shared context.** Each agent keeps its own scoped memory under `~/.claude/agent-memory-local/<agent>/`. Cellar Door (below) extends this to a typed shared store when agents *do* need to coordinate — but the default is isolation, because shared context bleeds.
- **Policy gates that hard-block.** Branch-protection bypass attempts, force-pushes to main, raw `git commit` — the hook layer refuses them. Quality is enforced at the seam, not by hoping the agent behaved.

**<!-- CAST_TEST_COUNT -->1,306<!-- /CAST_TEST_COUNT --> BATS tests across <!-- CAST_TEST_FILE_COUNT -->141<!-- /CAST_TEST_FILE_COUNT --> files** cover the shell surface. The framework treats its own correctness as a first-class concern.

---

## cast-desktop — Native Observability for CAST

[`cast-desktop`](https://github.com/ek33450505/cast-desktop) · Tauri 2 + Rust + TypeScript · MIT · **v<!-- VERSION:cast-desktop -->1.0.0<!-- /VERSION:cast-desktop -->** — public release

The claude-code-dashboard is a web UI that requires a running server. cast-desktop packages CAST observability as a self-contained Tauri 2 native app — no Node, no server management, no configuration.

The desktop app binds native infrastructure to Claude Code's agent execution model:

- **Native PTY terminal** (xterm.js backend + Rust pty layer) with persistent pane-to-session binding. Every terminal pane is tracked in `pane_bindings` table — cast.db always knows which CAST session owns which pane, so you can trace input/output back to the agent run that spawned it.
- **Inline code editor** (CodeMirror 6 + TypeScript LSP sidecar) with agent dispatch. Select code in the editor, spawn a CAST agent, results stream back into the same window.
- **Full cast.db coverage**: 55 Express routes, read-only by default, loopback-only (DNS-rebinding guard). Surfaces 24+ tables: sessions, agent runs, routing decisions, memory, hook events, cost telemetry, pane bindings.
- **Live session cost SSE**: streams per-session burn rate ($/min) and 4-hour cost projection as tokens flow.
- **6 themes** — light/dark variants across professional, high-contrast, and accent-color choices.
- **Homebrew installable**: `brew tap ek33450505/cast-desktop && brew install cast-desktop`

**Design problems it solves:**
- Eliminates the "observability server management" friction that makes local dashboards feel like extra work.
- Pane-to-session binding bridges the terminal and agent layers — you can see *which* terminal pane is executing *which* agent without tracing context manually.
- Sidecar LSP + dispatch keeps the agent loop visible while you're coding — no context switch to a browser tab.
- Local-only Express binding (no cloud round-trip) means latency is submillisecond; dashboard updates feel real-time.

All code and data flow through `~/.claude/cast.db` — same source of truth as the CLI. Useful as a portfolio piece demonstrating Tauri architecture, SQLite query patterns under load, and React real-time data binding.

---

## CAST Ecosystem

> Auto-synced from [claude-agent-team/docs/ecosystem.md](https://github.com/ek33450505/claude-agent-team/blob/main/docs/ecosystem.md). Run `~/Projects/personal/claude-agent-team/scripts/sync-ecosystem-readme.sh` to refresh.

<!-- ECOSYSTEM_START -->
| Repo | Description | Latest | Install |
|---|---|---|---|
| [cast-hooks](https://github.com/ek33450505/cast-hooks) | 13 auditable hook scripts — observability, safety guards, quality gates. SessionStart, PreToolUse, PostToolUse, PostCompact. | ![](https://img.shields.io/github/v/release/ek33450505/cast-hooks?style=flat-square) | `brew tap ek33450505/cast-hooks && brew install cast-hooks` |
| [cast-agents](https://github.com/ek33450505/cast-agents) | 23 specialist agents — commit, debug, review, plan, test, research, and more. Agent definitions with YAML frontmatter. v7-synced. | ![](https://img.shields.io/github/v/release/ek33450505/cast-agents?style=flat-square) | `brew tap ek33450505/cast-agents && brew install cast-agents` |
| [cast-memory](https://github.com/ek33450505/cast-memory) | Persistent agent memory with FTS5 search, relevance scoring, shared pool, semantic embeddings. Per-agent knowledge accumulation. | ![](https://img.shields.io/github/v/release/ek33450505/cast-memory?style=flat-square) | `brew tap ek33450505/cast-memory && brew install cast-memory` |
| [cast-routines](https://github.com/ek33450505/cast-routines) | Scheduled autonomous Claude Code routines via YAML + cron. Daily briefings, inbox triage, release celebration, weekly cost reports. | ![](https://img.shields.io/github/v/release/ek33450505/cast-routines?style=flat-square) | `brew tap ek33450505/cast-routines && brew install cast-routines` |
| [cast-parallel](https://github.com/ek33450505/cast-parallel) | Parallel agent execution across worktree sessions. Agent Dispatch Manifest (ADM) support. | ![](https://img.shields.io/github/v/release/ek33450505/cast-parallel?style=flat-square) | `brew tap ek33450505/cast-parallel && brew install cast-parallel` |
| [cast-observe](https://github.com/ek33450505/cast-observe) | Session-level observability — cost tracking, agent run history, token spend, event sourcing. Feeds cast.db. | ![](https://img.shields.io/github/v/release/ek33450505/cast-observe?style=flat-square) | `brew tap ek33450505/cast-observe && brew install cast-observe` |
| [cast-security](https://github.com/ek33450505/cast-security) | Security hooks and audit trails. PII redaction, parry-guard integration, compliance logging. | ![](https://img.shields.io/github/v/release/ek33450505/cast-security?style=flat-square) | `brew tap ek33450505/cast-security && brew install cast-security` |
| [cast-doctor](https://github.com/ek33450505/cast-doctor) | Read-only health check for any Claude Code install. Validates hooks, MCP servers, agent frontmatter, cast.db schema, stale memories. | ![](https://img.shields.io/github/v/release/ek33450505/cast-doctor?style=flat-square) | `brew tap ek33450505/cast-doctor && brew install cast-doctor` |
| [cast-time](https://github.com/ek33450505/cast-time) | Gives Claude Code a clock — injects local time, timezone, and a semantic time-of-day bucket at every SessionStart. | ![](https://img.shields.io/github/v/release/ek33450505/cast-time?style=flat-square) | `brew tap ek33450505/cast-time && brew install cast-time` |
| [cast-dash](https://github.com/ek33450505/cast-dash) | Terminal UI dashboard for live swarm monitoring. 4-panel real-time display (Textual framework). | ![](https://img.shields.io/github/v/release/ek33450505/cast-dash?style=flat-square) | `brew tap ek33450505/cast-dash && brew install cast-dash` |
| [cast-claudes_journal](https://github.com/ek33450505/cast-claudes_journal) | Session continuity — Claude's Journal auto-injects prior-day context via SessionStart hook. Obsidian vault sync. | ![](https://img.shields.io/github/v/release/ek33450505/cast-claudes_journal?style=flat-square) | `brew tap ek33450505/homebrew-claudes-journal && brew install claudes-journal` |
| [cast-website](https://github.com/ek33450505/cast-website) | castframework.dev — marketing site and docs portal for the CAST ecosystem. | ![](https://img.shields.io/github/v/release/ek33450505/cast-website?style=flat-square) | — |
| [cast-desktop](https://github.com/ek33450505/cast-desktop) | Tauri 2 native app — embedded PTY terminal, command palette, 11 dashboard views, Constellation 3D graph. NEW. | ![](https://img.shields.io/github/v/release/ek33450505/cast-desktop?style=flat-square) | `brew tap ek33450505/homebrew-cast-desktop && brew install cast-desktop` |
<!-- ECOSYSTEM_END -->

### Adjacent Projects

Not part of the CAST ecosystem proper but built alongside:

| Project | One line |
|---|---|
| [`claude-code-dashboard`](https://github.com/ek33450505/claude-code-dashboard) | React 19 + Express + SQLite observability UI for the agent loop. Sessions, agents, hook health, memory browser, SQLite explorer. |
| [`cellar-door`](https://github.com/ek33450505/cellar-door) | Typed shared memory for local AI agents — model-agnostic, Claude + Ollama. |

All open source. All Homebrew-installable where applicable.

---

## Stack

Bash · Python · TypeScript · React 19 · Express 5 · SQLite · BATS · Vitest · Tauri 2. macOS first, Linux supported. Anthropic API + Claude Code Agent SDK.

---

*Currently writing about agent observability, memory architecture, and what production multi-agent systems actually need. Reach out: [edward.kubiak.dev@gmail.com](mailto:edward.kubiak.dev@gmail.com).*
