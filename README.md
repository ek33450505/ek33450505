## Edward Kubiak

Full-stack engineer at [META Solutions](http://metasolutions.net/) in Columbus, Ohio. Building open-source infrastructure for AI-native development.

---

## Project Engram

[project-engram](https://github.com/ek33450505/project-engram) · Python + SQLite + Bash · Apache 2.0 · v0.6.0

Persistent AI identity system. Extracts identity signals from conversations — communication style, behavioral corrections, preferences, relationship arc — compresses them with recency-weighted decay scoring, and injects a token-efficient identity payload at session start. Works across models, across providers.

```sh
brew tap ek33450505/engram && brew install engram
```

- **Provider support** — Claude Code, OpenAI, Ollama, any system-prompt API
- **Named personas** with directory-based auto-activation
- **Published portable spec** — `specs/identity-payload-v1.md`
- **347 tests** — 324 pytest + 23 BATS
- **Integrates with CAST** — identity payload injected into every agent session

> One identity. Any model. Every session.

---

## [CAST](https://castframework.dev) — Claude Agent Specialist Team

[claude-agent-team](https://github.com/ek33450505/claude-agent-team) · Shell/Bash · MIT · v4.2

31 specialist agents that dispatch automatically via Claude Code's hook layer — commit, debug, review, plan, security, and more. Model-driven routing, local-first SQLite observability, per-agent persistent memory, and 255 BATS tests.

```sh
brew tap ek33450505/cast && brew install cast
```

- **Local-first** — all memory, routing state, and observability in SQLite on disk
- **Token cost tracking per agent** — spend broken down by model
- **Policy gates** — hard-block dangerous operations before they execute
- **Hook-driven dispatch** — Claude Code lifecycle events trigger the right agent automatically

---

### CAST Modular Ecosystem

| Package | What It Does |
|---|---|
| [cast-agents](https://github.com/ek33450505/cast-agents) | 17 specialist Claude Code agents |
| [cast-hooks](https://github.com/ek33450505/cast-hooks) | 13 hook scripts — observability, safety gates, dispatch |
| [cast-observe](https://github.com/ek33450505/cast-observe) | Session cost + token spend tracking (SQLite) |
| [cast-security](https://github.com/ek33450505/cast-security) | Policy gates, PII redaction, audit trail |
| [cast-dash](https://github.com/ek33450505/cast-dash) | Terminal UI dashboard (Python + Textual) |
| [cast-memory](https://github.com/ek33450505/cast-memory) | Persistent agent memory (Python + Shell + MCP) |
| [cast-parallel](https://github.com/ek33450505/cast-parallel) | Parallel plan execution across dual worktrees |
| [cast-claudes_journal](https://github.com/ek33450505/cast-claudes_journal) | Claude's personal journal — session-end reflections + cross-session continuity |

All open source. All independently installable.

---

### Claude Code Dashboard

[claude-code-dashboard](https://github.com/ek33450505/claude-code-dashboard) · React 19 + TypeScript + Express 5 + SQLite · MIT

Observability UI for CAST. Sessions timeline, agent analytics, hook health monitor, memory browser, live SQLite explorer.
