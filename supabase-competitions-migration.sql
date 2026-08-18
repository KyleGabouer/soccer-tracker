-- =============================================
-- Soccer Stats Tracker - Competitions migration
-- Run this ONCE in the Supabase SQL Editor.
--
-- What it does: renames "categories" to "competitions" (same data,
-- just a clearer name), and adds a fixed category to each competition
-- (Tournament / Showcase / Friendly / Cup / League).
--
-- Safe to run: this only renames existing objects and adds one new
-- column — no data is deleted. Existing security policies stay attached
-- through the rename automatically.
-- =============================================

ALTER TABLE categories RENAME TO competitions;
ALTER TABLE games RENAME COLUMN category_id TO competition_id;

ALTER TABLE competitions ADD COLUMN category_type TEXT
  CHECK (category_type IN ('Tournament','Showcase','Friendly','Cup','League'));

-- Backfill the categories for your existing competitions
UPDATE competitions SET category_type = 'Tournament' WHERE name = 'Rainier Challenge';
UPDATE competitions SET category_type = 'Showcase'   WHERE name = 'NW Summer Showcase';
UPDATE competitions SET category_type = 'League'     WHERE name = 'Pre-ECNL NW Division';
UPDATE competitions SET category_type = 'Friendly'   WHERE name = 'Seattle United Jamboree';
