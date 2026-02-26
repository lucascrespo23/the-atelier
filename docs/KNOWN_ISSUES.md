# Known Issues — The Atelier

## Bugs from QA

### 1. View Switching via Card Click (Event Propagation)
**Severity:** Medium  
**Description:** Clicking task cards sometimes triggers an unintended view switch. The `onclick` handlers on cards call `openTaskModal()`, but event propagation can bubble up to parent elements or trigger the wrong handler.  
**Root cause:** Inline `onclick` handlers on nested elements. Some handlers use `event.stopPropagation()` but not consistently.  
**Location:** `renderCard()`, `renderDesignerInt()`, `renderSlot()` — all use inline `onclick` on card divs.

### 2. Chat History Lost on View Switch
**Severity:** Medium  
**Description:** When switching between Manager/Designer/Requester views, chat messages are lost. Each view's chat history lives in in-memory arrays (`managerHistory`, `designerChatHistory`, `requesterHistory`) that are not persisted.  
**Specific case:** `switchDesigner()` explicitly clears designer chat: `designerChatHistory = []; document.getElementById('designerMessages').innerHTML = '';`  
**Impact:** Users lose context when navigating away and back.

### 3. Requester Submit Button Inconsistent
**Severity:** Low  
**Description:** The requester send button behavior is sometimes unreliable. The input field's `onkeydown` handler checks `event.key === 'Enter'` and calls `requesterSend()`, but the chat may not be initialized if the drawer hasn't been opened yet.  
**Location:** `requesterSend()` — relies on `requesterHistory` being initialized by `initRequesterChat()`.

### 4. Modal Dismiss Unreliable
**Severity:** Low  
**Description:** Clicking the modal overlay to dismiss doesn't always work. The `onclick="if(event.target===this)closeTaskModal()"` check fails when clicks land on child elements within the overlay area.  
**Additional issue:** The deliverable modal (`showDeliverableModal`) creates a second overlay that can stack on top.

### 5. Chat Input Leaks Between Views
**Severity:** Low  
**Description:** Chat input state (text in input fields) persists when switching views because the DOM elements are never cleared. If you type in the manager chat input, switch to designer, then back, the text is still there but the history context has diverged.  
**Also:** The designer chat widget's `open` state persists across designer switches.

### 6. Chat Widget Overlaps Designer Empty State
**Severity:** Low  
**Description:** When a designer has no primary task, the empty state illustration is shown centered. The floating chat bubble (`.chat-bubble`, fixed position bottom-right) and expanded chat widget (`.chat-widget`) can overlap with or cover the empty state content, especially on smaller screens.  
**Location:** CSS — `.chat-bubble` is `position: fixed; bottom: 24px; right: 24px;` regardless of content state.

---

## Other Known Limitations

### No File Upload Backend
The `/api/upload` endpoint is called from `handleFileUpload()`, `submitDeliverable()`, and `handleRequesterAttachment()`, but the endpoint doesn't exist. File uploads silently fail (caught in try/catch), and attachments are saved with `url: '#'`.

### No ATL-ID Collision Prevention
Task IDs are generated as `ATL-` + zero-padded count of existing tasks. If tasks are deleted and new ones created, IDs can collide with previously deleted tasks in Supabase.

### Delete Only Local
`modalDeleteTask()` deletes from `STATE.tasks` and calls `saveState()` (which syncs remaining tasks), but doesn't call the Supabase delete endpoint. Deleted tasks will reappear on next `loadFromSupabase()`.

### Single-Tab Only
No cross-tab synchronization. Multiple tabs will have diverging state since each reads from localStorage independently and the debounced Supabase sync can overwrite.

### Manager Init Fires Once
`managerInitDone` flag prevents re-initialization. If the initial API call fails, the manager chat shows the error but never retries the greeting.
