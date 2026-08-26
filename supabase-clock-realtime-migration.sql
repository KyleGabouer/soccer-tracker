-- =============================================
-- Soccer Stats Tracker - Live game clock + Realtime sync
-- Run this ONCE in the Supabase SQL Editor.
--
-- What it does:
-- 1. Adds columns to `games` so a running match clock can be computed by any
--    device from a start timestamp + banked seconds, instead of requiring a
--    write every second: clock_running (is it ticking right now),
--    clock_started_at (when the current running segment began, if any),
--    clock_accumulated_seconds (the seconds value that segment counts up
--    from), clock_half (1 or 2), clock_half_length_minutes (configured half
--    length, e.g. 30 — used only to know where "Start 2nd Half" jumps to;
--    the clock always counts up, never down).
-- 2. Adds `games` and `app_state` to the supabase_realtime publication so
--    the app can subscribe to postgres_changes and push goal/score/clock
--    updates to every open tab/device live, instead of requiring a manual
--    refresh. Realtime respects the existing RLS policies (public read), so
--    both the admin and anonymous viewers receive updates.
--
-- Safe to run: only adds nullable/defaulted columns and enables realtime
-- publication for two tables — no existing data is touched or deleted.
-- If either ALTER PUBLICATION statement errors with "already a member of
-- publication", that table is already realtime-enabled — no action needed.
-- =============================================

ALTER TABLE games ADD COLUMN clock_running BOOLEAN DEFAULT FALSE;
ALTER TABLE games ADD COLUMN clock_started_at TIMESTAMPTZ;
ALTER TABLE games ADD COLUMN clock_accumulated_seconds INTEGER DEFAULT 0;
ALTER TABLE games ADD COLUMN clock_half INTEGER DEFAULT 1;
ALTER TABLE games ADD COLUMN clock_half_length_minutes INTEGER DEFAULT 30;

ALTER PUBLICATION supabase_realtime ADD TABLE games;
ALTER PUBLICATION supabase_realtime ADD TABLE app_state;
