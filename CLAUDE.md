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
- Live game clock — admin taps Start Clock (counts up from 0:00), End 1st Half (freezes wherever it is), Start 2nd Half (jumps to the configured half length and resumes counting up), End Game (freezes for good). Ticks live for every viewer, admin or not.
- Opponent goals tracked with +/- buttons during live games; score shown as "X - Y"
- Edit finished games — change opponent/team, date, competition, opponent goals
- Add goals/assists to finished games via the same player-tap flow
- Add historical (past) games from the Games tab with "+ Add Game"
- Player roster as card grid with photos, tappable to open profile modal
- Player profiles with editable name, number, photo; shows season stats and per-game log
- Photos resized to 200x200 JPEG and stored as base64 in Supabase
- Teams (name + logo) — opponent picked from this list instead of free text; own team's name/logo set in Roster tab
- Competitions (e.g. "Tournament", "Regular Season") — create/edit/delete in Settings tab
- Competition assigned when starting a game via dropdown
- Competition badges shown on game cards in history and game detail
- Stats view filter pills to filter season stats by competition
- Per-game stat breakdowns
- Season totals per player with sorting
- 5-tab navigation: Game, Schedule, Stats, Team, Settings/Login

## Data Model
```js
{
  players: [{ id, name, number, photo }],       // photo: base64 string or null
  games: [{
    id, opponent, date, events, finished,
    competitionId, teamId, opponentGoals,
    clock: { halfLengthMinutes, half, running, startedAt, accumulatedSeconds }
  }],
  competitions: [{ id, name, emoji, categoryType }],
  teams: [{ id, name, logo }],                  // logo: base64 string or null
  ownTeam: { name, logo },
  activeGameId: null | string
}
```
- In-memory `data` object is the single source of truth at runtime
- `saveData(data)` writes to localStorage (sync) and Supabase (async, fire-and-forget); no-ops entirely if not logged in as admin
- Deletes are targeted per-row (`deleteRemoteRow`) at the point of deletion, not diffed against whole tables on every save — a past bug had a stale device's save wipe out rows created elsewhere
- Every Supabase write result is checked for `.error` and surfaced via `alert()` if a write is rejected — supabase-js resolves rather than throws on a rejected write, so this doesn't happen automatically
- On page load: renders from localStorage immediately, refreshes from Supabase once, then a Realtime subscription keeps `games`/`app_state` live from then on (also re-syncs on reconnect/tab-visible, in case a device missed pushed events while asleep/backgrounded)
- Game clock is a count-up stopwatch (not a countdown): `elapsed = accumulatedSeconds + (running ? now - startedAt : 0)`, so any device can compute the correct current time with zero per-second writes
- Supabase tables: `players`, `games`, `competitions`, `teams`, `app_state`
- `games.events` stored as JSONB column (not a separate table)

## What We Don't Do
- No accounts for anyone but the one admin (this is a personal tool; everyone else is a read-only viewer)
- No live streaming or video
- No complex formation or positioning data
