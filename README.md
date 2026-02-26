# The Atelier — Design Team Intelligence

A design team management tool built for [Every.to](https://every.to)'s creative team. Three role-based views (Manager, Designer, Requester) with AI-powered chat in each, backed by Claude and Supabase.

**Live:** https://the-atelier.vercel.app  
**GitHub:** https://github.com/lucascrespo23/the-atelier

---

## What It Does

The Atelier manages a small design team (2 designers) with a capacity model: each designer has **1 primary task** + **2 secondary ("interruption") tasks** per week. Unassigned work lives in a **queue**.

- **Manager view** — Command center with AI chat (strategic PM partner) + visual board showing all tasks by status
- **Designer view** — Focus mode showing the designer's primary task, secondary slots, checklist, and a coaching chat widget
- **Requester view** — Kanban board of all requests + a slide-out drawer with an AI interviewer that conducts a 10-step intake and creates task cards automatically

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Frontend | Single `index.html` (~3000 lines: HTML + CSS + JS) |
| Fonts | Google Fonts: Playfair Display + Inter |
| Icons | [Lucide](https://lucide.dev) via CDN |
| AI | Claude API (claude-sonnet-4-20250514) via `/api/claude` serverless proxy |
| Database | Supabase (PostgreSQL) via `/api/db` serverless proxy |
| Hosting | Vercel (auto-deploys from `main` branch) |
| State | localStorage cache with async Supabase sync |

## Architecture Overview

```
index.html (entire SPA)
  ├── CSS (~1000 lines) — design system, all components, dark mode, animations
  ├── HTML (~100 lines) — three view shells + modal + toast container
  └── JS (~1900 lines) — state management, rendering, AI chat, CRUD

api/
  ├── claude.js  — POST proxy to Anthropic Messages API
  └── db.js      — Supabase CRUD (load, upsert-task, save-person, delete-task)

supabase-setup.sql — tables: tasks, team, people + RLS policies + seed data
```

**Data flow:** `localStorage` is the primary store (instant loads). On every `saveState()`, all views re-render and a debounced (500ms) sync pushes every task to Supabase. On startup, `loadFromSupabase()` fires after 1 second to pull the latest server state.

## Environment Variables (set in Vercel Dashboard)

| Variable | Description |
|----------|-------------|
| `CLAUDE_API_KEY` | Anthropic API key (sk-ant-...) |
| `SUPABASE_URL` | Supabase project URL (https://xxx.supabase.co) |
| `SUPABASE_KEY` | Supabase anon/public key (for RLS) |
| `SUPABASE_SECRET_KEY` | Supabase service role key (used by db.js) |

## Deployment

Push to `main` → Vercel auto-builds and deploys. No build step needed — it's static HTML + serverless functions.

## Local Development

```bash
# Install Vercel CLI
npm i -g vercel

# Link to project (first time)
vercel link

# Pull env vars
vercel env pull .env.local

# Run locally
vercel dev
```

Opens at `http://localhost:3000`. The serverless functions in `api/` work automatically with `vercel dev`.

## Database Setup

Run `supabase-setup.sql` in the Supabase SQL Editor. It creates:
- `tasks` — all task data (JSON columns for checklist, attachments, conversation_history)
- `team` — designer profiles (seeds Daniel + Benjamin)
- `people` — requester memory (name, department, last request)
- RLS policies with public access (single-tenant app)

## Documentation

- [Architecture Deep-Dive](docs/ARCHITECTURE.md)
- [Design System](docs/DESIGN.md)
- [Feature Inventory](docs/FEATURES.md)
- [API Reference](docs/API.md)
- [Known Issues](docs/KNOWN_ISSUES.md)
