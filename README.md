# MD-MCZ

## Demo Video

![Demo](DEMO.gif)


## Reusing the component

`SearchView` is the reusable piece. Embed it inside any `NavigationStack` and (optionally) handle taps:

```swift
NavigationStack {
    SearchView(
        onSelect: { item in
            // push to detail, fill a form, etc.
        }
    )
    .navigationTitle("Search")
}
```

`SearchScreen` is the convenience full-screen variant that does the wrapping for you:

```swift
SearchScreen(onSelect: { item in ... })
```

When `onSelect` is `nil`, rows render as plain non-interactive cells, so existing call sites stay unchanged.

## Setup (`GITHUB_TOKEN` via `Secrets.xcconfig`)

1. Copy the example file:
   ```bash
   cp MD-MCZ/Config/Secrets.example.xcconfig MD-MCZ/Config/Secrets.xcconfig
   ```
2. Add your token (or the one I provided by email):
   ```xcconfig
   GITHUB_TOKEN = ghp_your_token_here
   ```

## How to Run Tests

- In Xcode: pick the `MD-MCZ` scheme and press `Cmd+U`.
- In terminal:

```bash
xcodebuild test -project MD-MCZ.xcodeproj -scheme MD-MCZ -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Architecture

- **Generic envelope:** both search endpoints share one response wrapper, so `GitHubSearchResponseDTO<Item>` keeps that decoding in one place.
- **Merge in protocol extension:** `searchAutocomplete(query:)` is a shared default implementation so combine/sort/cap logic isn't duplicated per endpoint.
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
- "Limit results to 50 items per request" can be read two ways — per network call or per merged list — so I applied both caps: `per_page=50` on each endpoint and 50 on the combined sorted result.
- `.searchable` is owned by `SearchView`, so embedders accept it as part of the component as a tradeoff.