# Dev log

Running notes on what was built, decisions made, and why. Newest entries first.

## 2026-07-02 — Phase 1: content filter engine

Two new files under `ScrollGuardClone/Filtering/` (picked up automatically by the
synchronized project folder — no pbxproj change needed):

- `FilterRules.swift` — the maintainable rules file. One rule per surface (Reels tab, feed
  suggestions, Explore grid), each documented with what it matches and why. This is the only
  file that should need edits when Instagram changes its markup.
- `ContentFilter.swift` — the engine: builds a `WKUserScript` (injected at document start,
  main frame only) from the rules. Rule data crosses into JS as JSON literals so quoting can
  never break the script.

**Decisions:**

- **Stable hooks only, no obfuscated class names.** Instagram's CSS classes churn weekly.
  Rules key off `href` paths (`/reels`, `/p/`), the SPA route, and visible text labels.
- **Text markers for feed suggestions.** "Suggested for you" / "Sponsored" units have no
  stable structure, so a JS scanner matches exact text-node labels (EN + FR) and hides the
  enclosing unit: nearest `<article>`, else the outermost ancestor containing no real post —
  with hop caps and main/body stops so a bad match can't blank the feed. Hidden units are
  re-checked on every scan and unhidden if React recycled their DOM node for a real post.
- **SPA route tracking.** `history.pushState`/`replaceState` are wrapped and `popstate`
  observed; the current path is mirrored to `data-sg-path` on `<html>` so route-scoped CSS
  (Explore grid) survives in-app navigation without page loads.
- **Route bounce for `/reels`.** Hiding the tab isn't enough — deep links or in-app taps can
  still land on the Reels feed, so the runtime redirects any `/reels*` route back home.
  Single shared reels (`/reel/<id>`, e.g. from a DM) are deliberately left alone.
- **Explore grid = hide post links, not containers.** On `/explore` routes, every
  `a[href^="/p/"]` / `a[href^="/reel"]` inside `main` is hidden. The search box and its
  results survive because accounts/hashtags/places don't link to posts.
- **JS/CSS embedded as Swift strings** rather than bundled `.js`/`.css` resources: one less
  build-phase moving part, and the rules file stays the single source of truth.

Verified the generated JS parses (Node syntax check); behavior needs the on-device test since
Instagram serves the real markup only to a logged-in mobile session.

## 2026-07-02 — Scaffolding + Phase 0

**Scaffolding.** Repo docs (README, PLAN, SETUP, this log) and an Xcode project created by
hand. The project uses Xcode 16's *file-system-synchronized groups* (`objectVersion = 77`), so
any file added to the `ScrollGuardClone/` folder is automatically part of the target — no
project-file surgery needed in later phases.

**Phase 0 decisions:**

- **Safari user agent.** `WKWebView`'s default user agent makes Instagram serve a degraded
  "unsupported browser" experience and aggressive app-install nags. We send a stock
  iOS Safari user agent string instead (`InstagramWebView.swift`).
- **Persistent cookies.** `WKWebsiteDataStore.default()` keeps the Instagram session across
  launches, so login is a one-time thing.
- **Navigation policy.** Main-frame navigations are only allowed on Instagram domains (plus
  Facebook domains, needed for the "Log in with Facebook" flow). Tapped links to anywhere else
  open in Safari, so the app can't quietly become a general browser.
- **URL scheme now, not later.** `scrollguard://` is registered in Phase 0 even though the
  Shortcuts onboarding is Phase 3, because it's the acceptance test that the redirect
  mechanism will work at all, and it lets us test the automation manually early.
- **Info.plist.** Xcode generates most of the Info.plist from build settings
  (`GENERATE_INFOPLIST_FILE`); the checked-in `ScrollGuardClone/Info.plist` only carries what
  build settings can't express — the URL scheme — and Xcode merges the two at build time.
