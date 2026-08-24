-- =============================================
-- Soccer Stats Tracker - Own team identity migration
-- Run this ONCE in the Supabase SQL Editor.
--
-- What it does: adds columns to the app_state singleton row for your own
-- team's name and logo (set from the Team tab), separate from the "teams"
-- table which holds opponents you pick from when starting a game.
--
-- Safe to run: only adds two new nullable columns — no data is touched.
-- =============================================

ALTER TABLE app_state ADD COLUMN team_name TEXT;
ALTER TABLE app_state ADD COLUMN team_logo TEXT;
