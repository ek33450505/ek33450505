## Edward Kubiak

Full-stack engineer at [META Solutions](http://metasolutions.net/) in Columbus, Ohio.
Building production education technology for Ohio school districts and open-source infrastructure for AI-native development.

---

## Work — META Solutions

`React` `Express` `Node.js` `Python` `MS SQL Server` `PostgreSQL` `Docker` `Jenkins`

- **CrossCheck** — EMIS data verification platform. React 18, AG Grid, MUI, JWT auth, TanStack Query. Used by school districts to validate and reconcile state reporting data.
- **ERATE** — E-Rate funding compliance system. Flask REST API, PostgreSQL, Python scrapers, two React frontends, Docker Compose, Traefik, Jenkins CI/CD.
- **SES Wiki** — Student enrollment scenario knowledge base. React 19 + Express 5, Dockerized, full-text search, auto-backup, inline editing.

Tools: VS Code · DataGrip

---

## Personal Projects — CAST Ecosystem

### CAST — Claude Agent Specialist Team
[claude-agent-team](https://github.com/ek33450505/claude-agent-team) · Shell/Bash · MIT · v4.2

17 specialist agents that dispatch automatically via Claude Code's hook layer — commit, debug, review, plan, security, and more. Model-driven routing, local-first SQLite observability, per-agent persistent memory, and 255 BATS tests.
```sh
brew tap ek33450505/cast && brew install cast
```

- **Local-first** — all memory, routing state, and observability in SQLite on disk
- **Token cost tracking per agent** — spend broken down by model
- **Policy gates** — hard-block dangerous operations before they execute
- **Hook-driven dispatch** — Claude Code lifecycle events trigger the right agent automatically

---

### Modular Ecosystem — Install Only What You Need

| Package | What It Does |
|---|---|
| [cast-agents](https://github.com/ek33450505/cast-agents) | 17 specialist Claude Code agents |
| [cast-hooks](https://github.com/ek33450505/cast-hooks) | 13 hook scripts — observability, safety gates, dispatch |
| [cast-observe](https://github.com/ek33450505/cast-observe) | Session cost + token spend tracking (SQLite) |
| [cast-security](https://github.com/ek33450505/cast-security) | Policy gates, PII redaction, audit trail |
| [cast-dash](https://github.com/ek33450505/cast-dash) | Terminal UI dashboard (Python + Textual) |
| [cast-memory](https://github.com/ek33450505/cast-memory) | Persistent agent memory (Python + Shell + MCP) |
| [cast-parallel](https://github.com/ek33450505/cast-parallel) | Parallel plan execution across dual worktrees |

All open source. All independently installable.

---

### Claude Code Dashboard
[claude-code-dashboard](https://github.com/ek33450505/claude-code-dashboard) · React 19 + TypeScript + Express 5 + SQLite · MIT

Observability UI for CAST. Sessions timeline, agent analytics, hook health monitor, memory browser, live SQLite explorer.
