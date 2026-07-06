# Dev log

Running notes on what was built, decisions made, and why. Newest entries first.

## 2026-07-06 — Documentation pass for portfolio readiness

No app code changed. Added `docs/ARCHITECTURE.md` and `docs/diagrams/*.puml` (one component
diagram, four sequence diagrams: app launch, the in-page filter runtime, the settings-toggle
reload flow, and the Shortcuts redirect), and updated the README (stale Status section, a
disclaimer, a Tech stack list, a demo placeholder, and an inline Mermaid diagram of the redirect
so GitHub renders something without opening a `.puml` file).

**Decisions:**

- **PlantUML source files, not exported images.** Kept as plain text under `docs/diagrams/` so a
  future selector fix in `FilterRules.swift` that changes one of these flows is a one-line diff,
  not a re-exported PNG. `docs/ARCHITECTURE.md` documents how to view them (VS Code's PlantUML
  extension, IntelliJ, or the online editor) since GitHub doesn't render `.puml` inline.
- **One Mermaid diagram in the README anyway.** GitHub renders Mermaid fenced code blocks
  natively, so the single most illustrative flow (the Shortcuts redirect) is duplicated there in
  Mermaid syntax for anyone just skimming the README, while the full diagram set stays in
  PlantUML in `docs/` as originally asked for.
- **Disclaimer in the README.** Since this repo may go on a resume/portfolio and potentially be
  shared publicly later, added an explicit non-affiliation note (not connected to Instagram,
  Meta, or the ScrollGuard app) rather than leaving that implicit.

## 2026-07-02 — Phases 1–3 accepted on-device

First on-device test session on the Mac (`docs/MAC-CHECKLIST.md`). Filters, toggles, and the
Shortcuts redirect all work as designed — no rule tightening needed yet. Two fixes were needed
to get a clean build/run rather than to the filtering behavior itself:

- **Compile fix in `InstagramWebView.swift`.** `WKNavigationAction` has no `.url` property;
  the URL lives at `navigationAction.request.url`. Signing wasn't the only thing untested on
  a real toolchain — this only surfaced once Xcode actually compiled the project on the Mac.
- **Signing.** `DEVELOPMENT_TEAM` set via Xcode's Signing & Capabilities tab (automatic
  signing, per `docs/SETUP.md`); Xcode also reordered a couple of pbxproj sections as a side
  effect of opening the project, harmless.

Phases 1, 2, and 3 are now ✅ in `docs/PLAN.md`.

## 2026-07-02 — Phase 3: Shortcuts onboarding & polish

New: `OnboardingView.swift`, `AppIcon.appiconset/Icon-1024.png`. Changed: `ContentView.swift`
(first-launch sheet + splash), `SettingsView.swift` (redirect section), `InstagramWebView.swift`
(loading state), `project.pbxproj` (display name).

**Decisions:**

- **Walkthrough, not automation.** Apple provides no API to create personal Shortcuts
  automations, so `OnboardingView` is a numbered 7-step guide (with an "Open Shortcuts"
  deep link via `shortcuts://`). The steps target the iOS 17/18 flow and say so where labels
  drift between versions. The automation action is "Open App → ScrollGuard Clone" — simpler
  and more robust than the `scrollguard://` URL scheme, which stays registered as a fallback
  and for testing.
- **First launch + on demand.** The walkthrough auto-presents until the user taps
  "It works — I'm done" (`sg.redirectSetupDone` in UserDefaults), and stays reachable from
  the settings sheet via a NavigationLink (no sheet-over-sheet juggling).
- **Display name "ScrollGuard Clone"** (`INFOPLIST_KEY_CFBundleDisplayName`) because the
  walkthrough tells the user to pick that name in the Open App action.
- **App icon generated in-repo.** No image tooling on the dev machine, so a dependency-free
  Node script (PNG encoder over built-in zlib) renders the 1024px icon: white shield with a
  cut-out "blocked feed row" capsule on an indigo→violet gradient. Single 1024px entry is all
  modern Xcode needs; regenerate by rerunning the script if the design changes.
- **Splash cover instead of launch flash.** `WebViewProxy` publishes `isLoading` (true until
  the first navigation settles, including failures); ContentView overlays a gradient +
  shield cover matching the icon and fades it out. Beats staring at instagram.com booting.

## 2026-07-02 — Phase 2: settings & toggles

New: `Filtering/FilterSettings.swift` (persistence), `SettingsView.swift` (UI). Changed:
`ContentView.swift` (edge handle + sheet), `InstagramWebView.swift` (rule hot-swap +
`WebViewProxy`).

**Decisions:**

- **Persist the *disabled* rule ids** (`sg.disabledFilterIDs` in `UserDefaults`), not the
  enabled ones — rules added in future versions default to on without a migration.
- **Toggles take effect via script reinstall + reload.** `WKUserScript`s only apply on
  navigation, so when the enabled set changes, `updateUIView` swaps the scripts on the
  existing `userContentController` and reloads. Keyed on the rule-id set, so unrelated
  SwiftUI updates never touch the web view.
- **Edge handle instead of a toolbar.** A native toolbar would either cover Instagram's own
  top header / bottom tab bar or permanently eat vertical space. Instead: a small translucent
  shield handle flush with the trailing edge, slightly below center, where it only overlaps
  scrolling feed content. It opens a sheet with the filter toggles and navigation actions.
- **Navigation actions in the sheet, not on screen.** Home feed / back / reload live in the
  settings sheet via a `WebViewProxy` (weak reference set by `makeUIView`) — Instagram web
  covers day-to-day navigation itself; these are escape hatches, not chrome.

Untested on device (no Mac in this session); Phases 1 and 2 will be accepted together.

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
