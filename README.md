# Edward Kubiak

> Agent infrastructure engineer. I build the layer between you and the agent loop.

Columbus, Ohio · [edwardkubiak.com](https://edwardkubiak.com) · [LinkedIn](https://www.linkedin.com/in/edward-kubiak-bbbaa6401/) · [edward.kubiak.dev@gmail.com](mailto:edward.kubiak.dev@gmail.com)

**Open to roles on agent infrastructure, developer tools, and Claude Code platform teams.**

---

## What I work on

Lately I’ve been focused on the operational side of multi-agent systems — routing, memory, observability, policy gates — the kinds of details that make the difference between an impressive demo and something reliable enough to leave running on its own.

For the last six months, I’ve been building [**CAST**](https://github.com/ek33450505/claude-agent-team),, a local-first OS layer for Claude Code, plus a handful of smaller supporting packages around it.

---

## CAST — Claude Agent Specialist Team

[`claude-agent-team`](https://github.com/ek33450505/claude-agent-team) · Bash · MIT · **v6.0** &nbsp;·&nbsp; [**v7 in progress — RFCs welcomed →**](https://github.com/ek33450505/claude-agent-team/discussions/28)

Claude Code ships with a powerful agent primitive and almost no scaffolding around it. CAST is the scaffolding: 30 specialist agents, hook-driven dispatch, model-tier routing, per-agent persistent memory, and a 26-table SQLite event store that makes the whole loop legible.

```sh
brew tap ek33450505/cast && brew install cast
```

**A few of the design decisions worth defending:**

- **Hook-driven dispatch over polling.** Claude Code emits lifecycle events (`SessionStart`, `PreToolUse`, `SubagentStop`, `Stop`). CAST hangs all routing, telemetry, and policy off those — no daemon, no background loop, no missed events. The harness is the orchestrator.
- **Local-first, SQLite everywhere.** Agent runs, routing decisions, memory, quality gates, hook output — all in `~/.claude/cast.db`. No cloud round-trip. The dashboard is just a SELECT away. Data is yours; observability is yours.
- **Per-agent memory, not shared context.** Each agent keeps its own scoped memory under `~/.claude/agent-memory-local/<agent>/`. Cellar Door (below) extends this to a typed shared store when agents *do* need to coordinate — but the default is isolation, because shared context bleeds.
- **Policy gates that hard-block.** Branch-protection bypass attempts, force-pushes to main, raw `git commit` — the hook layer refuses them. Quality is enforced at the seam, not by hoping the agent behaved.

**1,067 BATS tests across 114 files** cover the shell surface. The framework treats its own correctness as a first-class concern.

> **v7 is in active design.** I'm collecting feature requests, friction points, and contribution ideas in [discussion #28](https://github.com/ek33450505/claude-agent-team/discussions/28) — anyone using CAST, building on Claude Code, or thinking about agent infrastructure is welcome to weigh in.

---

## Ecosystem

Each package below is independently installable and stands on its own. CAST is what happens when you wire them together.

| Package | One line |
|---|---|
| [`claude-code-dashboard`](https://github.com/ek33450505/claude-code-dashboard) | React 19 + Express + SQLite observability UI for the agent loop. 369 Vitest tests, 43 routes, 10 views. v2.2.0. |
| [`cellar-door`](https://github.com/ek33450505/cellar-door) | Typed shared memory for local AI agents — model-agnostic, Claude + Ollama. v0.3.0. |
| [`cast-hooks`](https://github.com/ek33450505/cast-hooks) | Standalone hook scripts — observability, safety, dispatch. Drop into any Claude Code setup. v0.2.0. |
| [`cast-memory`](https://github.com/ek33450505/cast-memory) | Persistent agent memory with FTS5 search, relevance scoring, MCP server. v0.2.0. |
| [`cast-dash`](https://github.com/ek33450505/cast-dash) | Terminal UI dashboard — Python + Textual. htop for CAST. v0.2.0. |
| [`cast-time`](https://github.com/ek33450505/cast-time) | Gives Claude Code a clock — local time + timezone injected at session start. v0.1.0. |
| [`cast-claudes_journal`](https://github.com/ek33450505/cast-claudes_journal) | Cross-session continuity for Claude — Obsidian vault, wiki-link graph. v0.2.0. |
| [`cast-observe`](https://github.com/ek33450505/cast-observe) | Session cost + token-spend tracking. No framework required. v0.2.0. |
| [`cast-security`](https://github.com/ek33450505/cast-security) | Policy gates, PII redaction, audit trail. No framework required. v0.2.0. |
| [`cast-parallel`](https://github.com/ek33450505/cast-parallel) | Plan execution split across parallel git worktrees. v0.1.0. |

All open source. All Homebrew-installable. All written to be useful without the rest.

---

## Stack

Bash · Python · TypeScript · React 19 · Express 5 · SQLite · BATS · Vitest. macOS first, Linux supported. Anthropic API + Claude Code Agent SDK.

---

*Currently writing about agent observability, memory architecture, and what production multi-agent systems actually need. Reach out: [edward.kubiak.dev@gmail.com](mailto:edward.kubiak.dev@gmail.com).*
