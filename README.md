# MD-MCZ

## Demo Video

## What’s Implemented

## Setup (`GITHUB_TOKEN` via `Secrets.xcconfig`)

1. Create `Config/Secrets.xcconfig` locally.
2. Add your token (or the one I provided by email).

```xcconfig
GITHUB_TOKEN = ghp_your_token_here
```

3. Set Debug/Release base configuration to `Config/Secrets.xcconfig`.
4. `Config/Info-GithubAdditions.plist` already maps `GITHUB_TOKEN` to `$(GITHUB_TOKEN)`.
5. At runtime, `GitHubConfig` checks Info.plist first, then falls back to the `GITHUB_TOKEN` environment variable.

## How to Run Tests

- In Xcode: pick the `MD-MCZ` scheme and press `Cmd+U`.
- In terminal:

```bash
xcodebuild test -project MD-MCZ.xcodeproj -scheme MD-MCZ -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Architecture

- **Generic envelope:** both search endpoints share one response wrapper, so `GitHubSearchResponseDTO<Item>` keeps that decoding in one place.
- **Merge in protocol extension:** `searchAutocomplete(query:)` lives in the `APIServicing` extension so combine/sort/cap logic is shared once.
- **Actor service:** `APIService` is an `actor`, which keeps async request handling safe without extra locking.
- **Debounce + cancel:** the view model waits briefly before searching and cancels older tasks when the query changes.
- **UI states:** `.idle`, `.loading`, `.empty`, `.results([SearchItem])`, `.error(String)`.

## Known Limitations / Out of Scope

- No pagination UI yet (autocomplete uses the first page).
- No dedicated rate-limit/retry UX.
- No offline cache.
- Sorting is alphabetical only (no custom ranking).
- Token setup is local/manual (`Secrets.xcconfig` or env var).

## Additional Comments

- I kept this intentionally simple for the scope of the task. Instead of adding extra layers (like navigation scaffolding, factories, or more abstractions), I focused on making the core flow solid: search both endpoints, merge and sort results, handle fast typing well, and keep the behavior well tested.
- For a production workflow, I would still use atomic commits on feature branches, but I would squash them before merging to `master`. For a project this small, opening multiple PRs felt unnecessary time-wise.