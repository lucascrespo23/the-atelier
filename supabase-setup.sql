-- The Atelier — Database Setup
-- Run this in Supabase Dashboard → SQL Editor

-- Tasks table
CREATE TABLE tasks (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  assignee TEXT,
  type TEXT DEFAULT 'queue',
  status TEXT DEFAULT 'queued',
  progress INTEGER DEFAULT 0,
  due TEXT,
  requester TEXT,
  requested_by TEXT,
  brief TEXT,
  priority TEXT DEFAULT 'medium',
  urgency TEXT DEFAULT 'standard',
  blocker TEXT,
  checklist JSONB DEFAULT '[]',
  attachments JSONB DEFAULT '[]',
  conversation_history JSONB DEFAULT '[]',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Team members
CREATE TABLE team (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  role TEXT,
  skills JSONB DEFAULT '[]'
);

-- Known requesters
CREATE TABLE people (
  name TEXT PRIMARY KEY,
  department TEXT,
  last_request TEXT,
  last_seen TIMESTAMPTZ DEFAULT NOW()
);

-- Default team
INSERT INTO team (id, name, role, skills) VALUES
  ('daniel', 'Daniel', 'Senior Designer', '["brand", "web", "product"]'),
  ('benjamin', 'Benjamin', 'Junior Designer', '["social", "marketing", "illustration"]');

-- Default tasks (demo data)
INSERT INTO tasks (id, title, assignee, type, status, progress, due, requester, brief, priority, checklist, attachments, conversation_history) VALUES
  ('ATL-001', 'Cora Landing Page Redesign', 'daniel', 'primary', 'in-progress', 60, 'Feb 28', 'Product Team',
   'Full redesign of the Cora product landing page. Modern, conversion-focused layout with updated brand elements.', 'high',
   '[{"text":"Wireframe layout","done":true},{"text":"Visual design — hero section","done":true},{"text":"Visual design — features grid","done":false},{"text":"Mobile responsive version","done":false},{"text":"Final review with stakeholders","done":false}]',
   '[{"type":"link","name":"Figma - Cora Brand Guide","url":"#","addedBy":"Lucas","addedAt":"2026-02-23"},{"type":"file","name":"cora-logo.svg","url":"#","addedBy":"Product Team","addedAt":"2026-02-22"}]',
   '[{"role":"user","content":"We need to redesign the Cora landing page. The current one is from 2022 and doesn''t reflect our new brand direction."},{"role":"assistant","content":"What''s the main goal for the redesign? Is it conversion optimization, brand alignment, or both?"},{"role":"user","content":"Both. We want to improve conversion rates and make it feel more premium to match our repositioning."},{"role":"assistant","content":"Perfect. Do you have the new copy ready, and what''s your timeline?"},{"role":"user","content":"Copy is 80% done, should be final by Friday. We need this live by Feb 28 for the product launch."}]'),
  ('ATL-002', 'Newsletter Header Template', 'daniel', 'interruption', 'review', 90, 'Feb 26', 'Editorial',
   'Reusable header template for the Every weekly newsletter. Needs to support dynamic headlines.', 'medium',
   '[{"text":"Design header layout","done":true},{"text":"Create Figma component","done":true},{"text":"Test with 3 sample headlines","done":false}]', '[]', '[]'),
  ('ATL-003', 'Spiral Social Media Kit', 'benjamin', 'primary', 'triaged', 0, 'Mar 5', 'Marketing',
   'Full social media kit for the Spiral product launch. Instagram, Twitter, LinkedIn formats.', 'high',
   '[{"text":"Mood board & references","done":false},{"text":"Instagram post templates (3)","done":false},{"text":"Twitter header + post","done":false},{"text":"LinkedIn banner","done":false},{"text":"Story templates (2)","done":false}]',
   '[{"type":"link","name":"Spiral Brand Assets","url":"#","addedBy":"Marketing","addedAt":"2026-02-24"}]', '[]'),
  ('ATL-004', 'Every Annual Report Cover', 'benjamin', 'interruption', 'blocked', 20, 'Mar 1', 'Finance',
   'Cover design for the annual report. Blocked — waiting on final copy from editorial.', 'medium',
   '[{"text":"Concept sketches","done":true},{"text":"Get final copy from editorial","done":false},{"text":"Final design","done":false}]',
   '[{"type":"file","name":"annual-report-draft.pdf","url":"#","addedBy":"Finance","addedAt":"2026-02-21"}]', '[]'),
  ('ATL-005', 'Sparkle Onboarding Flow', NULL, 'queue', 'queued', 0, 'TBD', 'Product Team',
   'Design the onboarding flow for Sparkle. Needs user research review first.', 'medium', '[]', '[]', '[]'),
  ('ATL-006', 'Lex Rebrand Presentation', NULL, 'queue', 'queued', 0, 'Mar 10', 'Marketing',
   'Keynote/Google Slides presentation for the Lex rebrand rollout.', 'low', '[]', '[]', '[]'),
  ('ATL-007', 'Monologue Blog Hero Images', NULL, 'queue', 'queued', 0, 'Mar 3', 'Editorial',
   'Set of 5 hero images for the Monologue blog relaunch.', 'high', '[]', '[]', '[]');

-- Enable RLS with public access (single-tenant)
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE team ENABLE ROW LEVEL SECURITY;
ALTER TABLE people ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public access tasks" ON tasks FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Public access team" ON team FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Public access people" ON people FOR ALL USING (true) WITH CHECK (true);

GRANT ALL ON tasks TO anon;
GRANT ALL ON team TO anon;
GRANT ALL ON people TO anon;
