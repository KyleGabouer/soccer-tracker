-- =============================================
-- Soccer Stats Tracker - Lockdown
-- Run this ONCE in the Supabase SQL Editor.
--
-- What it does: replaces the current "anyone can do anything"
-- policies with "anyone can read, only a signed-in user can write."
--
-- Before running this:
--   1. In the Supabase dashboard, go to Authentication > Users
--      and click "Add user" to create your own login (email + password).
--   2. In Authentication > Settings (sometimes called "Sign In / Providers"),
--      turn OFF "Allow new users to sign up" so no one else can ever
--      create an account through the app.
-- =============================================

-- Remove the old wide-open policies
DROP POLICY IF EXISTS "Allow all on categories" ON categories;
DROP POLICY IF EXISTS "Allow all on players" ON players;
DROP POLICY IF EXISTS "Allow all on games" ON games;
DROP POLICY IF EXISTS "Allow all on app_state" ON app_state;

-- Anyone (including logged-out visitors) can read all data
CREATE POLICY "Public read on categories" ON categories FOR SELECT USING (true);
CREATE POLICY "Public read on players" ON players FOR SELECT USING (true);
CREATE POLICY "Public read on games" ON games FOR SELECT USING (true);
CREATE POLICY "Public read on app_state" ON app_state FOR SELECT USING (true);

-- Only a signed-in user can insert/update/delete
CREATE POLICY "Authenticated write on categories" ON categories FOR ALL USING (auth.uid() IS NOT NULL) WITH CHECK (auth.uid() IS NOT NULL);
CREATE POLICY "Authenticated write on players" ON players FOR ALL USING (auth.uid() IS NOT NULL) WITH CHECK (auth.uid() IS NOT NULL);
CREATE POLICY "Authenticated write on games" ON games FOR ALL USING (auth.uid() IS NOT NULL) WITH CHECK (auth.uid() IS NOT NULL);
CREATE POLICY "Authenticated write on app_state" ON app_state FOR ALL USING (auth.uid() IS NOT NULL) WITH CHECK (auth.uid() IS NOT NULL);
