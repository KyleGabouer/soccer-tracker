---
name: soccer-app-qa
description: Automated QA check for the soccer stats tracker. Opens the live app, walks through the core flows (Game, Schedule, Stats, Roster, Settings, a game detail page), and reports any errors, blank screens, or console regressions found. Run this periodically, or whenever asked to QA-check the soccer app.
---

# Soccer App QA Check

## Steps

1. Start the `soccer-tracker` preview server (`.claude/launch.json`) if it isn't already running, and open it in the browser pane.
2. Immediately check the console for errors on first load.
3. Walk through each tab in order, confirming the view renders (no blank screen, no thrown error) and shows the content it should:
   - **Game** — either "No active game" empty state, or a live game with a score
   - **Schedule** — game cards with date / opponent / competition / score, filter pills
   - **Stats** — the season stats table with sortable columns
   - **Roster** — player cards with photos, numbers, stats
   - **Settings/Login** — the login form (guest) or competitions list (admin)
4. Click into one game from Schedule and confirm the detail page renders correctly: date, opponent, competition badge, score, player stats, goal log.
5. Take a screenshot at each step.
6. Re-check the console for any *new* errors introduced during the walk-through (ignore known-harmless ones like a missing favicon).

## Output format

A short pass/fail report:
- One line per screen checked, ✅ or ❌
- Any real console errors, quoted verbatim
- One-line overall verdict at the top: all clear, or N issues found with a one-line description of each
- Do not just say "looks fine" — cite what was actually seen (exact text, exact error messages) as evidence
