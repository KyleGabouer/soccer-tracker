# Soccer Stats Tracker

## What This Product Does
A web app for tracking goals and assists during youth soccer games. Designed to be used live on the sideline during a match. Records who scored, who assisted on each goal, organizes stats by game, and shows season totals per player.

## Who It's For
Kyle — a soccer parent who wants to track his son's team stats quickly and easily during games. Needs to work on both phone (sideline use) and desktop (reviewing stats later).

## How It's Built
- Single-page web app — everything is in `index.html` at the project root
- Works on mobile and desktop browsers
- Data stored in localStorage
- Deployed via Surge.sh

## Features
- Quick-entry interface for recording goals/assists during live games
- Opponent goals tracked with +/- buttons during live games; score shown as "X - Y"
- Edit finished games — change opponent, date, category, opponent goals
- Add goals/assists to finished games via the same player-tap flow
- Add historical (past) games from the Games tab with "+ Add Game"
- Player roster as card grid with photos, tappable to open profile modal
- Player profiles with editable name, number, photo; shows season stats and per-game log
- Photos resized to 200x200 JPEG and stored as base64 in localStorage
- Game categories (e.g. "Tournament", "Regular Season") — create/edit/delete in More tab
- Category assigned when starting a game via dropdown
- Category badges shown on game cards in history and game detail
- Stats view filter pills to filter season stats by category
- Per-game stat breakdowns
- Season totals per player with sorting
- 5-tab navigation: Game, Games, Stats, Roster, More

## Data Model
```js
{
  players: [{ id, name, number, photo }],       // photo: base64 string or null
  games: [{ id, opponent, date, events, finished, categoryId, opponentGoals }],
  categories: [{ id, name, emoji }],
  activeGameId: null | string
}
```
- `loadData()` migrates old data by backfilling `photo: null`, `categoryId: null`, `categories: []`, and `opponentGoals: 0`

## What We Don't Do
- No user accounts or login (this is a personal tool)
- No live streaming or video
- No complex formation or positioning data
