# Development plan

The app is built in phases. Each phase ends in something runnable on the iPhone, and the next
phase only starts after the previous one has been tested and approved.

Legend: ✅ done · 🔨 in progress · ⏳ not started

## Phase 0 — Runnable shell ✅

A minimal app you can install on your iPhone today: Instagram mobile web in a full-screen
`WKWebView`, no filtering yet.

Scope:
- Xcode project (SwiftUI, iOS 17+, iPhone).
- `WKWebView` loading `instagram.com` with a Safari user agent (so Instagram serves the normal
  mobile site) and a persistent cookie store (log in once, stay logged in).
- Pull-to-refresh; external links open in Safari; Instagram/Facebook-login domains stay inside
  the app.
- `scrollguard://` URL scheme registered, so a Shortcuts automation can open the app.

Acceptance: build and run on the iPhone, log in to Instagram, scroll the feed, kill and reopen
the app and still be logged in, and `scrollguard://` typed in Safari opens the app.

## Phase 1 — Content filter engine 🔨 (built, awaiting on-device test)

The core product: injected CSS/JS that removes the addictive surfaces.

Scope:
- A filter-rule system (`WKUserScript` + injected stylesheet) applied before page load, so
  blocked content never flashes on screen.
- Rules for the three targets: the Reels tab in the bottom bar, suggested/sponsored posts in
  the home feed, and the suggestion grid on the search/Explore page (search box keeps working).
- Rules kept in a maintainable, documented bundle file so selectors are easy to update when
  Instagram changes its markup.
- Handles Instagram's single-page-app navigation (filters must survive in-app route changes).

Acceptance: feed shows only followed accounts, no Reels tab, search page shows only the search
box.

Note: Instagram's markup is obfuscated, so the first on-device test is expected to surface
selector misses (a suggestion that slips through, or an over-hidden unit). That's normal —
report what you see and the rules in `ScrollGuardClone/Filtering/FilterRules.swift` get
tightened; the engine itself doesn't change.

## Phase 2 — Settings & toggles 🔨 (built, awaiting on-device test)

Scope:
- SwiftUI settings screen with a per-filter toggle (Reels / feed suggestions / Explore grid),
  persisted in `UserDefaults` and applied immediately via a page reload.
- Small navigation affordances: home feed, back, reload — in the settings sheet, opened from
  a translucent handle on the trailing screen edge.

Acceptance: flipping a toggle changes what the web client shows, and the choice survives an
app restart. (Phases 1 and 2 can be verified in the same on-device session.)

## Phase 3 — Shortcuts onboarding & polish ⏳

Scope:
- Guided in-app walkthrough for creating the "When Instagram opens → open ScrollGuard Clone"
  automation (Apple doesn't allow creating it programmatically; it's a one-time manual setup).
- App icon, launch feel, full-bleed layout polish.

Acceptance: a fresh user can go from install to a working redirect using only in-app
instructions.

## Phase 4 — Screen Time hard-block (optional) ⏳

Scope:
- FamilyControls / ManagedSettings shield on the native Instagram app, with an "open filtered
  client instead" escape hatch. Works in development on personal devices; public distribution
  would need Apple's Family Controls entitlement, which doesn't matter for personal use.

## Phase 5 — Friends & Android ⏳

Scope:
- TestFlight distribution (requires the $99/year Apple Developer Program).
- Android sibling app using an Accessibility Service, which on Android *can* hide elements
  inside the real Instagram app — different engine, same product design.
