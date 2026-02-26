// Supabase data API — handles all CRUD for tasks, team, people
const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_KEY = process.env.SUPABASE_SECRET_KEY;

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
  if (!res.ok) {
    const err = await res.text();
    throw new Error(`Supabase error ${res.status}: ${err}`);
  }
  const text = await res.text();
  return text ? JSON.parse(text) : null;
}

export default async function handler(req, res) {
  const { method } = req;
  const { action, table, id } = req.query;

  try {
    // GET /api/db?action=load — Load all state (tasks + team + people)
    if (method === 'GET' && action === 'load') {
      const [tasks, team, people] = await Promise.all([
        supaFetch('tasks?order=created_at.asc'),
        supaFetch('team'),
        supaFetch('people')
      ]);

      // Convert tasks array to object keyed by id
      const tasksObj = {};
      for (const t of tasks) {
        tasksObj[t.id] = {
          id: t.id, title: t.title, assignee: t.assignee, type: t.type,
          status: t.status, progress: t.progress, due: t.due,
          requester: t.requester, requestedBy: t.requested_by,
          brief: t.brief, priority: t.priority, urgency: t.urgency,
          blocker: t.blocker, checklist: t.checklist || [],
          attachments: t.attachments || [],
          conversationHistory: t.conversation_history || [],
          slot: t.type === 'interruption' ? 1 : undefined
        };
      }

      const teamObj = {};
      for (const m of team) {
        teamObj[m.id] = { name: m.name, role: m.role, skills: m.skills || [] };
      }

      return res.status(200).json({ tasks: tasksObj, team: teamObj, people });
    }

    // POST /api/db?action=upsert-task — Create or update a task
    if (method === 'POST' && action === 'upsert-task') {
      const task = req.body;
      const row = {
        id: task.id, title: task.title, assignee: task.assignee || null,
        type: task.type, status: task.status, progress: task.progress || 0,
        due: task.due || 'TBD', requester: task.requester,
        requested_by: task.requestedBy || task.requester,
        brief: task.brief, priority: task.priority || 'medium',
        urgency: task.urgency || 'standard', blocker: task.blocker || null,
        checklist: task.checklist || [], attachments: task.attachments || [],
        conversation_history: task.conversationHistory || [],
        updated_at: new Date().toISOString()
      };

      await supaFetch('tasks', {
        method: 'POST',
        prefer: 'resolution=merge-duplicates,return=minimal',
        body: JSON.stringify(row)
      });

      return res.status(200).json({ ok: true });
    }

    // POST /api/db?action=save-person
    if (method === 'POST' && action === 'save-person') {
      const person = req.body;
      await supaFetch('people', {
        method: 'POST',
        prefer: 'resolution=merge-duplicates,return=minimal',
        body: JSON.stringify(person)
      });
      return res.status(200).json({ ok: true });
    }

    // DELETE /api/db?action=delete-task&id=ATL-001
    if (method === 'DELETE' && action === 'delete-task' && id) {
      await supaFetch(`tasks?id=eq.${id}`, { method: 'DELETE', prefer: 'return=minimal' });
      return res.status(200).json({ ok: true });
    }

    return res.status(400).json({ error: 'Unknown action' });
  } catch (err) {
    return res.status(500).json({ error: err.message });
  }
}
