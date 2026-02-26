# Design System — The Atelier

## Philosophy

Inspired directly by Claude.ai's UI. The guiding principle is **restraint**: beauty comes from what's NOT there. The warm beige background IS the design — white cards float on it with minimal borders and almost no shadows.

**The one-line test:** If someone screenshots The Atelier and puts it next to Claude.ai, they should feel like the same design team made both.

### Core Principles
- **Person-based, not ticket-based** — No ATL-IDs shown to users. Tasks referenced by title only.
- **Restraint over decoration** — No gradients, no icons everywhere, minimal shadows
- **Typography is hierarchy** — Weight and color create hierarchy, not size
- **Containers barely there** — 1px borders, generous radius, no heavy shadows

## Color Palette

### Light Mode (`:root`)

```css
--bg:             #F9F8F2;   /* warm beige — the main background */
--bg-warm:        #f7f3ed;   /* slightly warmer, used in summary cards */
--bg-hover:       #f3efe8;   /* hover state for items */
--bg-card:        #ffffff;   /* white cards floating on beige */
--text:           #2d2b28;   /* primary text — near-black, warm */
--text-secondary: #8b8680;   /* secondary text — warm gray */
--text-tertiary:  #b0a99f;   /* tertiary text — light warm gray */
--border:         #ebe6de;   /* card borders — very subtle */
--border-input:   #ddd8d0;   /* input borders — slightly stronger */
--divider:        #f0ebe4;   /* dividers within cards */
--accent:         #c4704b;   /* terracotta — the ONE accent color */
--green:          #6b8f71;   /* status: in progress */
--red:            #c46b5e;   /* status: blocked, danger */
--purple:         #8b7aab;   /* status: in review */
--gold:           #b89650;   /* status: triaged, important */
```

### Dark Mode (`[data-theme="dark"]`)

```css
--bg:             #1a1918;
--bg-warm:        #222120;
--bg-hover:       #2a2928;
--bg-card:        #262524;
--text:           #e8e4df;
--text-secondary: #9b9590;
--text-tertiary:  #6b6560;
--border:         #3a3835;
--border-input:   #4a4845;
--divider:        #333130;
--accent:         #d4815c;   /* slightly brighter terracotta for dark mode */
```

Toggle: `toggleDarkMode()` sets `data-theme` attribute on `<html>` and persists in `localStorage.atelier_theme`.

## Typography

```css
body {
  font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
  font-size: 14px;
  line-height: 1.65;
  font-weight: 400;
  letter-spacing: -0.01em;
}

h1, h2, h3, .heading {
  font-family: 'Playfair Display', serif;
  font-weight: 500;
}
```

| Use | Font | Size | Weight |
|-----|------|------|--------|
| Body text | Inter | 14px | 400 |
| Section labels | Inter | 12px | 500, uppercase, letter-spacing: 1.2px |
| Card titles | Inter | 14px | 500 |
| Designer task title | Playfair Display | 28px | 500 |
| Modal title | Playfair Display | 22px | 500 |
| Nav logo | Playfair Display | 18px | 500 |
| Status labels | Inter | 11px | 500, uppercase |
| Metadata | Inter | 12px | 400 |

## Component Inventory

### Nav Bar (`#viewSelector`)
- Fixed top, 52px height, no border or background
- Logo: "The **Atelier**" — "The" in `#9c8b7a`, "Atelier" in terracotta
- View tabs: plain text buttons. Active: `--text` + weight 500. Inactive: `--text-tertiary` + weight 400
- Dark mode toggle (moon/sun icon)
- "Updated X ago" timestamp

### Chat Panel (`.chat-panel`)
- White card with border, floats on beige with margin
- Width: 480px, min-width: 400px
- Messages: `.msg.ai` (white bg, border) and `.msg.user` (subtle blue `#edf2fa`)
- Typing indicator: 3 dots fading in sequence
- Input: 48px height, 16px border-radius, placeholder "Talk to The Atelier…"
- Send button: 36px circle, dark bg, white arrow

### Task Cards (`.task-card`)
- White bg, 1px border, 12px radius, 16px padding
- Title preceded by 6px colored dot (priority-based)
- Status as colored text only (no pill/badge background)
- Progress bar: 4px tall, terracotta fill
- Hover: translateY(-1px) + subtle shadow

### Primary Zone (`.primary-zone`)
- White card, 16px radius, 40px padding, max-width 640px
- Task title in Playfair 28px
- Brief in 15px secondary color
- Details grid: label (11px uppercase tertiary) + value (14px)
- Checklist with custom checkboxes (16x16, 3px radius)
- Action buttons: Complete (dark), Blocked (outlined red), Need Info (outlined)

### Secondary Slots (`.slot-card`)
- Empty: dashed border, "Slot N — Available" centered
- Filled: solid border, white bg, compact task info

### Task Modal (`.modal-overlay` + `.modal-box`)
- Overlay: `rgba(0,0,0,0.3)` warm-tinted dark
- Box: 560px max-width, 36px padding, 16px radius
- Contains: title, status line, brief, details grid, checklist with add/remove, attachments with upload/link, conversation history (collapsible), activity log, action bar (assign, role toggle, status buttons, delete)

### Kanban Board (`.kanban-board`)
- Horizontal flex, gap 16px, overflow-x auto
- 5 columns: Waiting, In Progress, In Review, Blocked, Completed
- Column headers with 8px colored dot + label + count badge
- Cards (`.queue-card`): white, 12px radius, title + assignee + due + progress

### Toast Notifications (`.toast`)
- Fixed top-right, stacked
- White card, 12px radius, 280px min-width, 8px colored dot
- Slide-in animation, auto-dismiss after 4 seconds

### Chat Widget (`.chat-widget`)
- Intercom-style: floating bubble (56px circle, terracotta) + expanding panel
- Panel: 380px × 500px, white card, slides up with spring animation
- Used in Designer view only

### Empty States (`.empty-state`)
- Centered, illustration + heading + description
- Illustrations are woodcut-style, displayed with `mix-blend-mode: multiply` to blend into beige

### Quick Action Pills (`.quick-action`)
- Rounded (20px radius), border, transparent bg
- Hover: warm bg + text color change + translateY(-1px)

### Request Drawer (`.request-drawer`)
- Fixed right panel, 420px wide, slides in from right
- Full-height from nav to bottom
- Contains chat interface for intake interview

### Template Library (`.template-modal`)
- Grid of template cards with icons, titles, descriptions
- Cards link to pre-filled request messages

### Design System Modal
- Full-screen iframe overlay showing Parthenon design system (`parthenon-design-system.vercel.app`)

## Illustration Assets

| File | Usage | Description |
|------|-------|-------------|
| `img/empty-inbox.jpg` | Manager board — no tasks in focus | Woodcut-style illustration |
| `img/empty-desk.jpg` | Designer view — no primary task | Woodcut-style illustration |
| `img/all-clear.jpg` | Kanban column — empty column | Woodcut-style illustration |

All displayed with `mix-blend-mode: multiply` to blend naturally with the warm beige background.

## Animation Inventory

| Animation | Element | Duration | Easing |
|-----------|---------|----------|--------|
| `cardSlideIn` | Task cards, queue cards | 0.35s | ease-out, staggered 0.05s per child |
| `checkPop` | Checkbox on complete | 0.3s | cubic-bezier(0.34, 1.56, 0.64, 1) — spring |
| `sendPulse` | Chat send button on :active | 0.15s | ease-out |
| `progressGrow` | Progress bars | 0.8s | cubic-bezier(0.22, 1, 0.36, 1), delay 0.3s |
| `bubbleBreathe` | Chat widget bubble | 3s | ease-in-out, infinite |
| `viewFadeIn` | View on switch | 0.25s | ease-out |
| `modalSlideUp` | Modal box | 0.25s | cubic-bezier(0.34, 1.56, 0.64, 1) — spring |
| `colFadeIn` | Kanban columns | 0.3s | ease-out, staggered 0.06s |
| `msgIn` | Chat messages | 0.2s | ease-out |
| `toastIn` / `toastOut` | Toast notifications | 0.3s in, 0.3s out (3.7s delay) |
| `zoneReveal` | Primary zone card | 0.4s | cubic-bezier(0.22, 1, 0.36, 1) |
| `btnGlow` | New Request button | 2.5s | ease-in-out, infinite |
| `cardPulse` | Highlighted card (after AI action) | 2s | ease-in-out, infinite |
| `typingFade` | Typing indicator dots | 1.4s | ease-in-out, staggered 0.2s |

## Urgency System (Designed, Not Yet Built in Frontend)

Three tiers, **manager-only visibility** (not shown to designers or requesters):

| Tier | Color | When |
|------|-------|------|
| Urgent | `--red` (#c46b5e) | ≤3 days or blocking external deadline |
| Important | `--gold` (#b89650) | 1-2 weeks, tied to real event |
| Standard | None (default) | Flexible, no hard deadline |

Dynamic escalation: even if stored as "standard", if due date is ≤3 days away → render as urgent. ≤7 days → render as important. Visual override only.

## Radius System

```css
--radius:    12px;  /* cards, inputs, action buttons */
--radius-lg: 16px;  /* main containers, chat panel, modal, primary zone */
/* pills/inputs: 20-24px */
```

## Spacing Conventions

- Main container margins: 24px
- Card padding: 16px (compact) to 40px (primary zone)
- Section gaps: 32px between board sections
- Chat message gaps: 20px (manager), 16px (widget)
- Card list gaps: 10px
