# Soccer Stats Tracker

## What This Product Does
A web app for tracking goals and assists during youth soccer games. Designed to be used live on the sideline during a match. Records who scored, who assisted on each goal, organizes stats by game, and shows season totals per player.

## Who It's For
Kyle — a soccer parent who wants to track his son's team stats quickly and easily during games. Needs to work on both phone (sideline use) and desktop (reviewing stats later).

## How It's Built
- Single-page web app — everything is in `index.html` at the project root
- Works on mobile and desktop browsers
- Data stored in Supabase (Postgres) with localStorage as offline cache
- Supabase JS client loaded via CDN; anon key is in `index.html`
- Deployed via GitHub Pages (repo: `soccer-tracker`, branch: `main`)
- One admin login (Supabase Auth email/password) — only the signed-in admin can write; everyone else gets read-only live viewing. `isAdmin()` gates all write UI and `saveData()`.
- Supabase Realtime (`postgres_changes` on `games`/`app_state`) pushes goal/score/clock changes to every open tab/device automatically — no manual refresh needed to see a live game update.

## Features
- Quick-entry interface for recording goals/assists during live games
- Live game clock — admin taps Start Game (counts up from 0:00), End Half (freezes wherever it is), Resume Game (jumps to the configured half length and resumes counting up), End Game (freezes for good), then Clear. Ticks live for every viewer, admin or not.
- Status badge beside the clock reflects the game state: Upcoming before kickoff, Live while the clock runs (the only one that pulses, and it honours prefers-reduced-motion), Half whenever the clock is stopped with time banked, Final once ended.
- A finished game stays on the Game tab showing its Final result until the admin taps Clear — so anyone checking in after the whistle still sees the score. In that state the scoring grid, opponent-goals stepper and clock controls are hidden; fix goals from the game's detail page instead.
- Opponent goals tracked with +/- buttons during live games; score shown as "X - Y"
- Edit finished games — change opponent/team, date, competition, opponent goals
- Add goals/assists to finished games via the same player-tap flow
- Add historical (past) games from the Games tab with "+ Add Game"
- Player roster as card grid with photos, tappable to open profile modal
- Player profiles with editable name, number, photo; shows season stats and per-game log
- Photos resized to 200x200 JPEG and stored as base64 in Supabase
- Teams (name only) — opponent picked from this list instead of free text. Opponents show as a name with no crest; own team's name/logo is set in the Team tab and still displays.
- Competitions (e.g. "Tournament", "Regular Season") — create/edit/delete in Settings tab
- Competition assigned when starting a game via dropdown
- Competition badges shown on game cards in history and game detail
- Stats view filter pills to filter season stats by competition
- Per-game stat breakdowns
- Season totals per player with sorting
- Lineups — build formations (a goalkeeper plus 3-4 outfield lines of 1-4 players each) and place roster players into them. Formations start empty; none are seeded.
- The Lineups tab is formation-first: the dropdown picks a formation, and that formation's lineups sit beneath it as filter pills, so one formation can hold several lineups. Lineup names are editable; "+ Add new formation…" in the New Lineup picker builds one without leaving the flow.
- The pitch draws each player as a dark disc with their squad number and first name, attack at the top and the keeper at the bottom. Players flagged as goalkeepers use the accent-yellow disc instead, on the pitch and the bench alike.
- Anyone on the roster but not on the pitch is listed below it as the bench.
- 6-tab navigation: Game, Schedule, Stats, Team, Lineups, Settings/Login

## Data Model
```js
{
  players: [{ id, name, number, photo, goalie }], // photo: base64 string or null; goalie set by a checkbox on the player profile
  games: [{
    id, opponent, date, events, finished,
    competitionId, teamId, opponentGoals,
    clock: { halfLengthMinutes, half, running, startedAt, accumulatedSeconds }
  }],
  competitions: [{ id, name, emoji, categoryType }],
  formations: [{ id, name, lines, squadSize }],  // lines = outfield rows, defence -> attack; [3,2,3] is a 3-2-3
  lineups: [{ id, name, formationId, goalkeeperId, slots, gameId }],
  teams: [{ id, name, logo }],                  // logo retained in the schema but unused; opponents render name-only
  ownTeam: { name, logo },
  activeGameId: null | string      // stays set after a game ends, until the admin clears it
}
```
- In-memory `data` object is the single source of truth at runtime
- `saveData(data)` writes to localStorage (sync) and Supabase (async, fire-and-forget); no-ops entirely if not logged in as admin
- Deletes are targeted per-row (`deleteRemoteRow`) at the point of deletion, not diffed against whole tables on every save — a past bug had a stale device's save wipe out rows created elsewhere
- Every Supabase write result is checked for `.error` and surfaced via `alert()` if a write is rejected — supabase-js resolves rather than throws on a rejected write, so this doesn't happen automatically
- On page load: renders from localStorage immediately, refreshes from Supabase once, then a Realtime subscription keeps `games`/`app_state` live from then on (also re-syncs on reconnect/tab-visible, in case a device missed pushed events while asleep/backgrounded)
- Game clock is a count-up stopwatch (not a countdown): `elapsed = accumulatedSeconds + (running ? now - startedAt : 0)`, so any device can compute the correct current time with zero per-second writes
- `getActiveGame()` can return a *finished* game (see Clear above), so anything that mutates a game through it guards on `game.finished`
- Formations name themselves from their shape (`lines.join('-')`), and the keeper is implicit — never part of `lines`. `squadSize` is stored per formation rather than hardcoded, and the builder validates `lines` against it, so 7v7/11v11 can be added without a migration. 9v9 (8 outfield) is the only size the UI offers today.
- `lineups.slots` is a sparse `"lineIndex-slotIndex"` -> player id map, so half-filled lineups save fine and survive a later edit to the formation's shape. Assigning a player who is already placed moves them rather than duplicating.
- `lineups.game_id` exists but is unused — it lets a lineup be tied to a match later as a UI-only change.
- Lineup selection is scoped to the selected formation (`getSelectedLineup()` only considers that formation's lineups), so switching formations never leaves a stale lineup from another one selected.
- Deleting a formation also deletes its lineups, naming them in the confirm. Lineups are reached *through* a formation now, so one left behind would be unreachable in the UI while still syncing.
- Migrations live in `supabase-*.sql` at the project root and are run by hand in the Supabase SQL editor. `supabase-goalie-migration.sql` is required: every players upsert sends `goalie`, and PostgREST rejects the whole request if the column is missing (42703), which would break saving a player's name and photo too.
- The `formations`/`lineups` tables are optional at runtime: if `supabase-lineups-migration.sql` hasn't been run, those selects fail, a warning is logged, and the rest of the app loads normally. Their upserts are skipped while empty so saves stay quiet.
- `renderLineups()` only writes into its own container, so moving Lineups off the tab bar later is a handful of lines (note `switchView()` assumes every view has a matching tab button).
- Supabase tables: `players`, `games`, `competitions`, `teams`, `formations`, `lineups`, `app_state`
- `games.events` stored as JSONB column (not a separate table)

## What We Don't Do
- No accounts for anyone but the one admin (this is a personal tool; everyone else is a read-only viewer)
- No live streaming or video
- No drag-and-drop on the pitch — slots are tap-to-assign (far more reliable on a phone)
- No per-player positional stats; a lineup records who lines up where, nothing more
