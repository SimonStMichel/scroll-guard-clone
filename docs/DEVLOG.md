# Dev log

Running notes on what was built, decisions made, and why. Newest entries first.

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
