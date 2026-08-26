-- =============================================
-- Soccer Stats Tracker - Make games.opponent nullable
-- Run this ONCE in the Supabase SQL Editor.
--
-- What it does: the original schema had games.opponent as NOT NULL
-- (free-text opponent name). Since the Teams migration, new games are
-- created with opponent: null and a team_id instead — but the NOT NULL
-- constraint was never relaxed. Result: every new game insert (e.g.
-- starting a live game) was silently rejected by Postgres, so the game
-- never actually landed in the games table even though app_state's
-- active_game_id pointed at it — making the in-progress game invisible
-- on any other device.
--
-- Safe to run: this only relaxes a constraint, no data is touched.
-- =============================================

ALTER TABLE games ALTER COLUMN opponent DROP NOT NULL;
