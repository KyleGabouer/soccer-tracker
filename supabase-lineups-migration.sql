-- =============================================
-- Soccer Stats Tracker - Formations + Lineups
-- Run this ONCE in the Supabase SQL Editor.
--
-- What it does: adds two tables behind the Lineups tab.
--
-- `formations` is a reusable shape: `lines` is the outfield rows ordered
-- defence -> attack, so [3,2,3] renders as a 3-2-3 (the goalkeeper is
-- implicit and always present, so it is not in `lines`). `squad_size` is
-- stored per formation rather than hardcoded in the app, so 7v7 or 11v11
-- can be layered in later without touching this schema.
--
-- `lineups` assigns players to one formation's slots. `slots` is a sparse
-- map of "lineIndex-slotIndex" -> player id, so a half-filled lineup saves
-- fine and a later edit to the formation's shape degrades gracefully.
-- `game_id` is intentionally unused for now — it lets a lineup be attached
-- to a specific game later as a pure UI change, with no second migration.
--
-- Safe to run: creates two new tables and their policies. Nothing existing
-- is read, changed or deleted.
-- =============================================

CREATE TABLE formations (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  lines JSONB NOT NULL DEFAULT '[]'::jsonb,
  squad_size INTEGER DEFAULT 9
);

CREATE TABLE lineups (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  formation_id TEXT,
  goalkeeper_id TEXT,
  slots JSONB DEFAULT '{}'::jsonb,
  game_id TEXT
);

ALTER TABLE formations ENABLE ROW LEVEL SECURITY;
ALTER TABLE lineups ENABLE ROW LEVEL SECURITY;

-- Same access shape as the rest of the app: anyone can read, only the
-- signed-in admin can write.
CREATE POLICY "Public read on formations" ON formations FOR SELECT USING (true);
CREATE POLICY "Authenticated write on formations" ON formations FOR ALL USING (auth.uid() IS NOT NULL) WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Public read on lineups" ON lineups FOR SELECT USING (true);
CREATE POLICY "Authenticated write on lineups" ON lineups FOR ALL USING (auth.uid() IS NOT NULL) WITH CHECK (auth.uid() IS NOT NULL);
