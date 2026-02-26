# API Reference — The Atelier

All endpoints are Vercel serverless functions in the `api/` directory.

---

## `POST /api/claude`

Proxies requests to the Anthropic Messages API.

**File:** `api/claude.js`

### Request

```json
{
  "model": "claude-sonnet-4-20250514",
  "max_tokens": 300,
  "system": "You are the Atelier...",
  "messages": [
    { "role": "user", "content": "What's the team status?" },
    { "role": "assistant", "content": "Here's the current state..." }
  ]
}
```

### Response

Returns the Anthropic API response directly:

```json
{
  "id": "msg_...",
  "type": "message",
  "role": "assistant",
  "content": [{ "type": "text", "text": "..." }],
  "model": "claude-sonnet-4-20250514",
  "stop_reason": "end_turn"
}
```

### Implementation

```js
// Forwards body directly to Anthropic
const response = await fetch('https://api.anthropic.com/v1/messages', {
  method: 'POST',
  headers: {
    'x-api-key': process.env.CLAUDE_API_KEY,
    'anthropic-version': '2023-06-01',
    'content-type': 'application/json'
  },
  body: JSON.stringify(req.body)
});
```

**Env:** `CLAUDE_API_KEY`

---

## `GET /api/db?action=load`

Loads all data from Supabase: tasks, team, and people.

### Response

```json
{
  "tasks": {
    "ATL-001": {
      "id": "ATL-001",
      "title": "Cora Landing Page Redesign",
      "assignee": "daniel",
      "type": "primary",
      "status": "in-progress",
      "progress": 60,
      "due": "Feb 28",
      "requester": "Product Team",
      "requestedBy": "Product Team",
      "brief": "Full redesign...",
      "priority": "high",
      "urgency": "standard",
      "blocker": null,
      "checklist": [{ "text": "Wireframe layout", "done": true }],
      "attachments": [{ "type": "link", "name": "Figma", "url": "#" }],
      "conversationHistory": [{ "role": "user", "content": "..." }]
    }
  },
  "team": {
    "daniel": { "name": "Daniel", "role": "Senior Designer", "skills": ["brand", "web", "product"] },
    "benjamin": { "name": "Benjamin", "role": "Junior Designer", "skills": ["social", "marketing", "illustration"] }
  },
  "people": [
    { "name": "Sarah", "department": "Marketing", "last_request": null, "last_seen": "2026-02-26T..." }
  ]
}
```

**Note:** Tasks array from Supabase is converted to an object keyed by `id`. Column `requested_by` is mapped to `requestedBy`. Column `conversation_history` is mapped to `conversationHistory`.

---

## `POST /api/db?action=upsert-task`

Creates or updates a task (upsert on primary key `id`).

### Request

```json
{
  "id": "ATL-001",
  "title": "Cora Landing Page Redesign",
  "assignee": "daniel",
  "type": "primary",
  "status": "in-progress",
  "progress": 60,
  "due": "Feb 28",
  "requester": "Product Team",
  "requestedBy": "Product Team",
  "brief": "Full redesign...",
  "priority": "high",
  "urgency": "standard",
  "blocker": null,
  "checklist": [],
  "attachments": [],
  "conversationHistory": []
}
```

### Response

```json
{ "ok": true }
```

**Implementation:** Uses Supabase `Prefer: resolution=merge-duplicates` header for upsert. Sets `updated_at` to current timestamp.

---

## `POST /api/db?action=save-person`

Saves or updates a person in the `people` table (upsert on primary key `name`).

### Request

```json
{
  "name": "Sarah",
  "department": "Marketing",
  "last_request": "Social Media Kit",
  "last_seen": "2026-02-26T03:00:00.000Z"
}
```

### Response

```json
{ "ok": true }
```

---

## `DELETE /api/db?action=delete-task&id=ATL-001`

Deletes a task by ID.

### Response

```json
{ "ok": true }
```

**Note:** Uses HTTP DELETE method (not POST). The `id` query parameter is used to filter: `tasks?id=eq.${id}`.

---

## Environment Variables

Set in the Vercel Dashboard under Project Settings → Environment Variables.

| Variable | Used By | Description |
|----------|---------|-------------|
| `CLAUDE_API_KEY` | `api/claude.js` | Anthropic API key (`sk-ant-api03-...`) |
| `SUPABASE_URL` | `api/db.js` | Supabase project URL (`https://xxx.supabase.co`) |
| `SUPABASE_SECRET_KEY` | `api/db.js` | Supabase service role key (bypasses RLS) |

**Note:** The env var in Vercel is `SUPABASE_SECRET_KEY` (matching `process.env.SUPABASE_SECRET_KEY` in db.js), not `SUPABASE_SECRET` as mentioned in some docs. The public `SUPABASE_KEY` is not used by the backend — the service role key is used for all operations.

## Database Schema

See `supabase-setup.sql` for full schema. Summary:

```sql
tasks (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  assignee TEXT,
  type TEXT DEFAULT 'queue',        -- queue | primary | interruption
  status TEXT DEFAULT 'queued',     -- queued | triaged | in-progress | review | blocked | complete
  progress INTEGER DEFAULT 0,
  due TEXT,
  requester TEXT,
  requested_by TEXT,
  brief TEXT,
  priority TEXT DEFAULT 'medium',   -- low | medium | high
  urgency TEXT DEFAULT 'standard',  -- standard | important | urgent
  blocker TEXT,
  checklist JSONB DEFAULT '[]',
  attachments JSONB DEFAULT '[]',
  conversation_history JSONB DEFAULT '[]',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
)

team (id TEXT PK, name TEXT, role TEXT, skills JSONB)
people (name TEXT PK, department TEXT, last_request TEXT, last_seen TIMESTAMPTZ)
```

RLS is enabled with public-access policies (single-tenant app). All tables grant full access to the `anon` role.

## Supabase Helper

All Supabase calls go through `supaFetch()`:

```js
async function supaFetch(path, options = {}) {
  const res = await fetch(`${SUPABASE_URL}/rest/v1/${path}`, {
    ...options,
    headers: {
      'apikey': SUPABASE_KEY,
      'Authorization': `Bearer ${SUPABASE_KEY}`,
      'Content-Type': 'application/json',
      'Prefer': options.prefer || 'return=representation',
      ...options.headers
    }
  });
  // ... error handling, JSON parsing
}
```
