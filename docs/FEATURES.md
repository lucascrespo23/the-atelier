# Feature Inventory — The Atelier

## Legend
- ✅ Done — shipped and working
- 🔧 Partial — backend/logic exists, frontend wiring incomplete
- 📋 Planned — designed but not built

---

## Core Views

| Feature | Status | Notes |
|---------|--------|-------|
| Manager command center | ✅ | Chat panel + board panel side by side |
| Manager AI chat | ✅ | Strategic PM partner with action tag execution |
| Manager board rendering | ✅ | In Focus, Secondary slots, Queue, Completed sections |
| Designer focus mode | ✅ | Primary task card, secondary slots, action buttons |
| Designer coach chat | ✅ | Intercom-style floating widget with task-aware coaching |
| Designer picker (Daniel/Benjamin) | ✅ | Tab switching, independent chat history per designer |
| Requester kanban board | ✅ | 5 columns: Waiting, In Progress, In Review, Blocked, Completed |
| Requester intake interview | ✅ | 10-step AI-driven conversational intake |
| Request drawer (slide-out) | ✅ | Right panel for new request flow |

## Task Management

| Feature | Status | Notes |
|---------|--------|-------|
| Task modal with full CRUD | ✅ | View/edit all task details, manager vs read-only modes |
| Primary/Secondary toggle | ✅ | In modal action bar. Auto-bumps existing primary |
| Checklist management | ✅ | Add, remove, toggle items. Auto-recalculates progress |
| Attachments (file upload) | ✅ | File picker in modal + requester chat |
| Attachments (link) | ✅ | Name + URL form in modal |
| Status transitions | ✅ | Triaged → In Progress → Review → Complete (+ Blocked) |
| Assign to designer | ✅ | Dropdown in modal, auto-sets type/status |
| Manager-only delete | ✅ | With confirmation dialog, only visible in manager view |
| Conversation history | ✅ | Collapsible in modal, expandable in designer view |
| Deliverable handoff flow | ✅ | Modal prompts for file/link before marking complete |
| Deliverable preview | ✅ | Shows Figma embeds, images, or file names on completed cards |

## AI Features

| Feature | Status | Notes |
|---------|--------|-------|
| Manager AI — status reports | ✅ | Auto-greeting on dashboard open |
| Manager AI — action execution | ✅ | `[ACTION:ASSIGN]` and `[ACTION:STATUS]` parsing |
| Manager AI — card highlighting | ✅ | Modified cards pulse with terracotta glow |
| Manager AI — task references | ✅ | Task titles in AI replies are clickable (opens modal) |
| Designer AI — contextual coaching | ✅ | Knows current tasks, checklists, original request conversations |
| Requester AI — intake interview | ✅ | 10-step flow with copy gate enforcement |
| Requester AI — task creation | ✅ | Parses `[REQUEST_COMPLETE]` into new task |
| Requester AI — workload awareness | ✅ | Checks capacity before setting expectations |
| Requester AI — person memory | ✅ | Recognizes returning requesters by name |
| Requester AI — attachment handling | ✅ | Files attached during chat transfer to task |

## UI/UX

| Feature | Status | Notes |
|---------|--------|-------|
| Dark mode | ✅ | Toggle in nav, persisted in localStorage |
| Toast notifications | ✅ | Auto-dismiss, color-coded |
| Empty states with illustrations | ✅ | Woodcut-style images for no tasks, clean desk, all clear |
| Mobile responsive | ✅ | Breakpoints at 768px and 480px |
| "Updated X ago" timestamp | ✅ | Auto-updates every 10 seconds |
| Card entrance animations | ✅ | Staggered slide-in |
| Checklist pop animation | ✅ | Spring bounce on check |
| Modal spring animation | ✅ | Scale + translateY entrance |
| Quick action pills | ✅ | Manager chat shortcuts |
| Template library | ✅ | Pre-fills request drawer with template text |
| Design system iframe | ✅ | Opens Parthenon design system in modal |
| View transitions | ✅ | Fade-in on switch |

## Backend

| Feature | Status | Notes |
|---------|--------|-------|
| Claude API proxy | ✅ | `/api/claude` — model, max_tokens, system, messages |
| Supabase load | ✅ | `/api/db?action=load` — tasks + team + people |
| Supabase upsert task | ✅ | `/api/db?action=upsert-task` |
| Supabase save person | ✅ | `/api/db?action=save-person` |
| Supabase delete task | ✅ | `/api/db?action=delete-task` (DELETE method) |
| localStorage caching | ✅ | Instant loads, Supabase as async backup |
| Debounced sync | ✅ | 500ms after saveState() |
| Supabase frontend wiring | 🔧 | Load works, upsert works, person save not called from frontend, delete uses local only |

## Planned / Not Built

| Feature | Status | Notes |
|---------|--------|-------|
| Urgency system (frontend) | 📋 | Three tiers designed (urgent/important/standard), dynamic escalation logic written, not rendered in UI |
| Urgency sorting | 📋 | Board should sort by urgency tier then due date |
| Manager urgency dropdown | 📋 | Override urgency in task modal |
| Supabase person sync | 📋 | `savePerson()` only writes localStorage, not Supabase |
| Real-time multi-user sync | 📋 | Currently single-user, no Supabase realtime subscriptions |
| File upload storage | 📋 | Upload endpoint (`/api/upload`) called but not implemented |
