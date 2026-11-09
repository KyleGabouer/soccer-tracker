-- =============================================
-- Soccer Stats Tracker - Goalkeeper flag on players
-- Run this ONCE in the Supabase SQL Editor.
--
-- What it does: adds a per-player goalkeeper flag, set from a checkbox on
-- the player profile. It marks who keeps goal, independent of any lineup:
-- flagged players render with the accent-yellow disc in the Lineups tab
-- wherever they appear, on the pitch or the bench.
--
-- Safe to run: one new boolean column defaulting to false, so every
-- existing player simply starts out not a keeper. No data is changed.
-- =============================================

ALTER TABLE players ADD COLUMN goalie BOOLEAN DEFAULT FALSE;
