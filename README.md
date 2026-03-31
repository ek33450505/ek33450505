## Edward Kubiak

I build infrastructure for AI-native development — not apps on top of LLMs, but the orchestration layer underneath them. Currently at META Solutions in Columbus, Ohio.

Most developers use Claude Code interactively. I built a local OS layer on top of it.

---

## CAST — Claude Agent Specialist Team

[claude-agent-team](https://github.com/ek33450505/claude-agent-team) · Shell/Bash · MIT

16 specialist agents (code-writer, reviewer, security, tester, debugger, and more) that dispatch in parallel on a single task — the same way a dev team divides work, but coordinated by a semantic router. Hook-driven architecture means Claude Code's lifecycle events (pre-commit, pre-push, stop) trigger agents automatically without manual invocation.

What makes it unusual:
- **Local-first, zero cloud lock-in** — all memory, routing state, and observability live in SQLite on disk
- **Token cost tracking per agent** — spend broken down by model, so you can see exactly where Haiku can replace Sonnet
- **301 BATS tests**, policy gates, and event sourcing via `cast.db`
- Phase 10 complete. v3.0 shipped.

---

## Claude Code Dashboard

[claude-code-dashboard](https://github.com/ek33450505/claude-code-dashboard) · React 19 + Express 5 + TypeScript + SQLite · MIT

Real-time observability UI for CAST. Sessions timeline, agent analytics, hook health monitor, memory browser, and a live SQLite explorer. Built to answer the question: *what is my agent team actually doing, and what is it costing me?*

---

## Currently building

- Expanding CAST's planning layer — multi-wave orchestration with fan-out/fan-in coordination across agent groups
- Researching token efficiency patterns across agent workloads (the dashboard makes this measurable)

---

## Other work

- [Edward_Kubiak](https://github.com/ek33450505/Edward_Kubiak) — Portfolio site (React + Vite)
- [promptbot](https://github.com/ek33450505/promptbot) — Python prompt utilities

---

![GitHub Stats](https://github-readme-stats.vercel.app/api?username=ek33450505&show_icons=true&hide_border=true&theme=default&hide=stars)
![Top Languages](https://github-readme-stats.vercel.app/api/top-langs/?username=ek33450505&layout=compact&hide_border=true&theme=default)

If CAST is useful to you, a star helps others find it.
