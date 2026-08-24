-- =============================================
-- Soccer Stats Tracker - Teams migration
-- Run this ONCE in the Supabase SQL Editor.
--
-- What it does: adds a "teams" table (name + logo, centrally stored like
-- competitions) and a team_id column on games, so a game's opponent is
-- picked from this list instead of typed as free text.
--
-- Safe to run: this only creates a new table and adds one new nullable
-- column — no existing data is touched or deleted. Games created before
-- this migration keep their old free-text "opponent" value and will
-- keep displaying it until you edit them to pick a team.
-- =============================================

CREATE TABLE teams (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  logo TEXT
);

ALTER TABLE games ADD COLUMN team_id TEXT;

ALTER TABLE teams ENABLE ROW LEVEL SECURITY;

-- Anyone (including logged-out visitors) can read all data
CREATE POLICY "Public read on teams" ON teams FOR SELECT USING (true);

-- Only a signed-in user can insert/update/delete
CREATE POLICY "Authenticated write on teams" ON teams FOR ALL USING (auth.uid() IS NOT NULL) WITH CHECK (auth.uid() IS NOT NULL);
