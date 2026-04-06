## Edward Kubiak

Full-stack engineer at [META Solutions](http://metasolutions.net/) in Columbus, Ohio. By day, I build production education technology for Ohio school districts. By night, I build open-source infrastructure for AI-native development.

---

## By Day — META Solutions

`React` `Express` `Node.js` `Python` `MS SQL Server` `PostgreSQL` `Docker` `Jenkins`

Production systems in education technology:

- **CrossCheck** — EMIS data verification platform. Built with React 18, AG Grid, MUI, JWT auth, and TanStack Query. Used by school districts to validate and reconcile state reporting data.
- **ERATE** — E-Rate funding compliance system. Multi-tier architecture: Flask REST API, PostgreSQL, Python data scrapers, two React frontends, Docker Compose, Traefik, and Jenkins CI/CD.
- **SES Wiki** — Student enrollment scenario knowledge base. React 19 + Express 5, Dockerized, with full-text search, auto-backup, and inline editing.

---

## By Night — CAST Ecosystem

### CAST — Claude Agent Specialist Team

[claude-agent-team](https://github.com/ek33450505/claude-agent-team) · Shell/Bash · MIT · v4.2

17 specialist agents that dispatch automatically via Claude Code's hook layer — commit, debug, review, plan, security, and more. Features model-driven routing (no routing tables), local-first SQLite observability, per-agent persistent memory, and 255 BATS tests.
```sh
brew tap ek33450505/cast && brew install cast
```

What makes it unusual:

- **Local-first, zero cloud lock-in** — all memory, routing state, and observability live in SQLite on disk
- **Token cost tracking per agent** — spend broken down by model, so you can see exactly where Haiku can replace Sonnet
- **Policy gates** that hard-block dangerous operations before they execute
- **Hook-driven dispatch** — Claude Code lifecycle events trigger the right agent automatically

---

### Modular Ecosystem — Install Only What You Need

Each CAST component ships as a standalone Homebrew package. Mix and match to build your own stack:

| Package | What It Does | Install |
|---|---|---|
| [cast-agents](https://github.com/ek33450505/cast-agents) | 17 specialist Claude Code agents | `brew tap ek33450505/cast-agents && brew install cast-agents` |
| [cast-hooks](https://github.com/ek33450505/cast-hooks) | 13 hook scripts — observability, safety gates, dispatch | `brew tap ek33450505/cast-hooks && brew install cast-hooks` |
| [cast-observe](https://github.com/ek33450505/cast-observe) | Session cost + token spend tracking (SQLite) | `brew tap ek33450505/cast-observe && brew install cast-observe` |
| [cast-security](https://github.com/ek33450505/cast-security) | Policy gates, PII redaction, and audit trail | `brew tap ek33450505/cast-security && brew install cast-security` |
| [cast-dash](https://github.com/ek33450505/cast-dash) | Terminal UI dashboard (Python + Textual) | `brew tap ek33450505/cast-dash && brew install cast-dash` |
| [cast-memory](https://github.com/ek33450505/cast-memory) | Persistent memory for Claude Code agents (Python + Shell + MCP) | `brew tap ek33450505/cast-memory && brew install cast-memory` |

All open source. All independently installable.

---

### Claude Code Dashboard

[claude-code-dashboard](https://github.com/ek33450505/claude-code-dashboard) · React 19 + TypeScript + Express 5 + SQLite · MIT

Real-time observability UI for CAST. Features a sessions timeline, agent analytics, hook health monitor, memory browser, and a live read-only SQLite explorer. Built to answer one question: *what is my agent team actually doing, and what is it costing me?*
