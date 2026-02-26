# Architecture — The Atelier

## File Structure

```
taskflow/
├── index.html              # Entire SPA: CSS + HTML + JS (~3000 lines)
├── config.js               # (if exists) optional config overrides
├── supabase-setup.sql      # Database schema, seed data, RLS policies
├── api/
│   ├── claude.js           # Vercel serverless: proxies POST to Anthropic Messages API
│   └── db.js               # Vercel serverless: Supabase CRUD (load/upsert-task/save-person/delete-task)
├── img/
│   ├── empty-inbox.jpg     # Woodcut illustration — no tasks in focus
│   ├── empty-desk.jpg      # Woodcut illustration — designer has no primary
│   └── all-clear.jpg       # Woodcut illustration — kanban column empty
└── docs/
    ├── ARCHITECTURE.md     # This file
    ├── DESIGN.md           # Design system documentation
    ├── FEATURES.md         # Feature inventory with status
    ├── API.md              # API reference
    └── KNOWN_ISSUES.md     # Known bugs
```

## State Management

### The `STATE` Object

All app state lives in a single global object:

```js
const STATE = loadState() || getDefaultState();
```

Shape:
```js
{
  team: {
    daniel: { name: 'Daniel', role: 'Senior Designer', skills: ['brand', 'web', 'product'] },
    benjamin: { name: 'Benjamin', role: 'Junior Designer', skills: ['social', 'marketing', 'illustration'] }
  },
  tasks: {
    'ATL-001': {
      id, title, assignee, type, status, progress, due, requester, requestedBy,
      brief, priority, urgency, blocker,
      checklist: [{ text: string, done: boolean }],
      attachments: [{ type: 'file'|'link', name, url, addedBy, addedAt, isDeliverable? }],
      conversationHistory: [{ role: 'user'|'assistant', content: string }],
      slot?: number  // 1 or 2 for interruption tasks
    }
  },
  currentDesigner: 'daniel',  // which designer tab is active
  requesterStep: 0,
  requesterDraft: {}
}
```

### localStorage + Supabase Sync

- **Read path:** `loadState()` reads from `localStorage.getItem('atelier_state')`. Falls back to `getDefaultState()` which has hardcoded demo data.
- **Write path:** `saveState()` writes to localStorage, re-renders all views, then debounces a `syncToSupabase()` call (500ms timer).
- **Startup sync:** `loadFromSupabase()` fires 1 second after page load. If Supabase has data, it overwrites the local state and re-renders.
- **Conflict resolution:** Last-write-wins. Supabase sync pushes every task individually via `upsert-task`.

```
Page load → loadState() from localStorage → render → 1s later → loadFromSupabase()
User action → saveState() → localStorage + render → 500ms debounce → syncToSupabase()
```

### Person Memory

Separate from `STATE`. Stored in `localStorage.getItem('atelier_people')`:

```js
{
  "sarah": { name: "Sarah", department: "Marketing", lastRequest: "...", lastSeen: "2026-02-26T..." }
}
```

Functions: `getKnownPeople()`, `savePerson(name, data)`. Injected into the requester system prompt so the interviewer recognizes returning requesters.

## View System

Three views, controlled by `currentView` variable and CSS class `.active`:

```js
let currentView = 'manager'; // 'manager' | 'designer' | 'requester'

function switchView(view) {
  // Remove .active from all .view elements
  // Add .active to #${view}View
  // Update .view-tab buttons
  // Call appropriate render function
}
```

Views are `<div class="view">` elements with `display: none` by default, `display: flex` when `.active`.

### Manager View (`#managerView`)
- **Left panel:** Chat (`.chat-panel`) — AI strategic PM partner
- **Right panel:** Board (`.board-panel`) — sections: In Focus, Secondary, Queue, Completed
- Quick action pills below chat: "Triage queue", "What's behind?", "How's Daniel?", "How's Benjamin?"
- Init: `initManager()` sends auto-greeting on first load

### Designer View (`#designerView`)
- **Top:** Designer picker tabs (Daniel / Benjamin), controlled by `switchDesigner(id)`
- **Center:** Primary task card (`.primary-zone`) with checklist, attachments, action buttons
- **Below:** Secondary slots (`.interruption-zone`) — 2 slots shown as cards or dashed empty placeholders
- **Bottom-right:** Intercom-style floating chat widget (`.chat-bubble` + `.chat-widget`)
- Init: `initDesignerChat()` sends contextual greeting based on current task state

### Requester View (`#requesterView`)
- **Header bar:** Title + "Design System" button + "New Request" button
- **Main area:** Kanban board (`.kanban-board`) with 5 columns: Waiting, In Progress, In Review, Blocked, Completed
- **Drawer:** Slide-out right panel (`.request-drawer`) for intake interview
- Cards are read-only here (`openTaskModalReadOnly`)

## AI Integration

### Claude API Call

```js
const CLAUDE_MODEL = 'claude-sonnet-4-20250514';

async function callClaude(systemPrompt, messages, maxTokens = 256) {
  const res = await fetch('/api/claude', {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify({ model: CLAUDE_MODEL, max_tokens: maxTokens, system: systemPrompt, messages })
  });
  const data = await res.json();
  return data.content[0].text;
}
```

### System Prompts

Each view has its own system prompt with injected context:

| View | System Prompt Variable | Context Injected | Max Tokens |
|------|----------------------|------------------|------------|
| Manager | `MANAGER_SYSTEM` + `getManagerContext()` | Team roster, all tasks with status/assignee/progress/blockers, capacity counts | 300-400 |
| Designer | `getDesignerSystemPrompt()` | Current designer's tasks, checklists, original request conversations | 300 |
| Requester | `getRequesterSystemPrompt()` | Workload context, known people, active tasks | 256 |

### Action Tag Parsing (Manager Only)

The manager AI can output hidden action tags that modify state:

```
[ACTION:ASSIGN task_id=ATL-001 assignee=daniel role=primary]
[ACTION:STATUS task_id=ATL-001 status=in-progress]
```

Parsed in `managerSend()` with regex:
```js
const actionRegex = /\[ACTION:(ASSIGN|STATUS)\s+(.+?)\]/g;
```

After execution, action tags are stripped from the displayed message. Cards that were modified get a pulsing glow highlight for 4 seconds.

### ASSIGN Logic
- Sets `task.assignee` and `task.type` (primary/secondary)
- If assigning as primary and designer already has one, bumps existing primary to secondary (interruption)
- If assigning as secondary and task was in queue, changes type to `interruption`
- Auto-updates status: queued → triaged (secondary) or in-progress (primary)

### STATUS Logic
- Sets `task.status`
- If `complete`: sets progress to 100% and marks all checklist items done

## Task Lifecycle

```
queue/queued → triaged → in-progress → review → complete
                                      ↘ blocked ↗
```

- **queue/queued** — Unassigned, waiting in the queue
- **triaged** — Assigned to a designer but not started (usually secondary tasks)
- **in-progress** — Actively being worked on (usually primary tasks)
- **review** — Designer submitted for review
- **blocked** — Waiting on external dependency (stored in `task.blocker`)
- **complete** — Done. Progress = 100%, all checklist items checked

### Type System

| Type | Meaning | Slots |
|------|---------|-------|
| `queue` | Unassigned | N/A |
| `primary` | Designer's main focus | 1 per designer |
| `interruption` | Secondary/smaller task | 2 per designer |

## Primary/Secondary Model

Each designer has capacity for: **1 primary** + **2 secondary** tasks.

### Swap Logic (in `modalSetRole`)

**Setting to primary:**
1. Check if designer already has a primary
2. If yes: bump existing primary to secondary (if slots available) or back to queue (if slots full)
3. Set new task as primary, auto-set status to `in-progress`

**Setting to secondary:**
1. Check if designer already has 2 secondaries
2. If full: show toast error, abort
3. Set task type to `interruption`, assign slot number

## The Interviewer Flow

The requester intake is a conversational AI interview with 10 steps:

1. **Who are you?** — Name + team (skipped if recognized from `atelier_people`)
2. **What do you need?** — Free-form description
3. **Where will it live?** — Destination platform
4. **What's it for?** — Purpose/context
5. **References/files?** — Inspiration, assets, links
6. **Copy Gate (HARD RULE)** — If asset needs text: copy must be 80%+ ready. If not → `[REQUEST_INCOMPLETE]`, conversation ends
7. **Timeline** — When they need it
8. **Urgency** — Urgent/Important/Standard classification
9. **Set expectations** — AI checks workload context and gives honest timeline estimate
10. **Summary & Submit** — Outputs `[REQUEST_COMPLETE]` with structured data

### Output Parsing

When the AI response contains `[REQUEST_COMPLETE]`:

```
[REQUEST_COMPLETE]
Title: Spiral Social Media Kit
Type: social-media
Deadline: Mar 5
Urgency: important
Requester: Sarah
Department: Marketing
Checklist: Create mood board | Design Instagram templates | Design Twitter assets
```

Parsed in `requesterSend()`:
- Extracts key-value pairs with regex
- Creates new task in `STATE.tasks` with auto-generated ID (`ATL-XXX`)
- Splits checklist on `|` into `[{ text, done: false }]`
- Stores full conversation history in `task.conversationHistory`
- Attaches any files uploaded during conversation (`requesterAttachments`)
- Shows summary card in chat with queue position

### Person Memory

```js
function savePerson(name, data) {
  const people = getKnownPeople(); // from localStorage
  people[name.toLowerCase()] = { ...existing, ...data, name, lastSeen: ISO_string };
  localStorage.setItem('atelier_people', JSON.stringify(people));
}
```

Known people are injected into the requester system prompt so the AI greets returning users by name.

## Rendering Pipeline

Every state mutation follows this pattern:

```
User action → modify STATE.tasks[id] → saveState()
                                          ├── localStorage.setItem()
                                          ├── updateTimestamp()
                                          ├── renderBoard()
                                          ├── renderRequesterQueue()
                                          ├── renderDesigner() (if active)
                                          └── debounced syncToSupabase()
```

### Key Render Functions

| Function | What it renders |
|----------|----------------|
| `renderBoard()` | Manager right panel — In Focus, Secondary slots, Queue, Completed |
| `renderDesigner()` | Designer primary zone, secondary slots, completed section |
| `renderRequesterQueue()` | Kanban board with 5 columns |
| `renderCard(task, showAssignee)` | Single task card (used in board) |
| `renderSlot(task, num)` | Filled secondary slot |
| `renderEmptySlot(name, num)` | Dashed empty secondary slot |
| `renderDesignerInt(task, num)` | Secondary card in designer view |
| `openTaskModalInternal(taskId, readOnly)` | Full task modal with all details |

All render functions generate HTML strings via template literals and set `.innerHTML`. `lucide.createIcons()` is called after each render to initialize icon SVGs.

## Chat History

Each view maintains its own in-memory chat history array:

- `managerHistory` — Manager chat messages
- `designerChatHistory` — Designer widget messages
- `requesterHistory` — Requester intake messages

These are **not persisted** — they reset on page reload or view switch. The system prompt is regenerated fresh for every API call with current state context.

## Timestamp Display

```js
let _lastSaveTime = Date.now();
```

Updated on every `saveState()`. A `setInterval` (10s) updates `#lastUpdated` span: "Updated just now" → "Updated Xs ago" → "Updated Xm ago" → "Updated Xh ago".
