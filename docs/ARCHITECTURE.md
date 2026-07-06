# Architecture

This doc is the technical companion to the README's "How it works" — it goes one level deeper
into how the pieces talk to each other, with diagrams. For *why* each decision was made, see
[DEVLOG.md](DEVLOG.md); for what's built vs. planned, see [PLAN.md](PLAN.md).

## Layers

```
ScrollGuardClone/
├── ScrollGuardCloneApp.swift   Entry point, registers the scrollguard:// URL scheme
├── ContentView.swift           Root view: hosts the web view, splash, settings/onboarding sheets
├── SettingsView.swift          Filter toggles + navigation escape hatches (home/back/reload)
├── OnboardingView.swift        Shortcuts-automation walkthrough
├── InstagramWebView.swift      UIViewRepresentable wrapping WKWebView + its navigation delegate
└── Filtering/
    ├── FilterRules.swift       Declarative rule data (CSS selectors, text markers, blocked routes)
    ├── ContentFilter.swift     Builds the WKUserScript (CSS + JS runtime) from the rules
    └── FilterSettings.swift    Persists which rules are enabled/disabled
```

Three layers, each with one job:

- **SwiftUI layer** — native chrome: the settings sheet, the onboarding walkthrough, the splash
  cover. Never touches Instagram's DOM directly.
- **Web layer** — a single `WKWebView` wrapped by `InstagramWebView`, configured once (Safari user
  agent, persistent cookie store, navigation policy) and driven afterwards through `WebViewProxy`.
- **Filtering** — declarative rules (`FilterRules.swift`) compiled into one injected script
  (`ContentFilter.swift`) per navigation. This is the only layer that knows anything about
  Instagram's markup, which is the point: when Instagram's selectors drift, `FilterRules.swift`
  is the one file that needs edits.

See [diagrams/00-overview.puml](diagrams/00-overview.puml) for the component diagram (open it with
one of the viewers in [Viewing the diagrams](#viewing-the-diagrams) below).

## Sequence diagrams

The four flows below are the ones worth understanding end-to-end — everything else in the app is
plumbing around them.

### 1. App launch → first filtered page load

How the filter script gets in front of Instagram's content *before* it can flash on screen: the
script is attached to the `WKWebView` configuration before `load()` is ever called, and injected
at `document-start` on the JS side.

*(Source: [diagrams/01-app-launch.puml](diagrams/01-app-launch.puml))*

### 2. In-page filter runtime

The interesting part. Instagram is a client-rendered SPA, so a one-shot DOM scan on page load
isn't enough — content keeps arriving as the user scrolls, and routes change without a real
navigation. The injected runtime handles three cases: the initial scan, SPA route changes
(patched `history.pushState`/`replaceState` + `popstate`), and lazily-rendered feed content (a
`MutationObserver`). All three funnel into the same `scan()`.

*(Source: [diagrams/02-content-filter-engine.puml](diagrams/02-content-filter-engine.puml))*

### 3. Toggling a filter in Settings

`WKUserScript`s only take effect on navigation, so flipping a toggle has to reinstall the script
and reload the page — there's no way to hot-patch a running page's injected script. The diff
against `installedRuleIDs` exists so unrelated SwiftUI state changes don't trigger a needless
reload.

*(Source: [diagrams/03-filter-toggle.puml](diagrams/03-filter-toggle.puml))*

### 4. The Shortcuts redirect

The mechanism that makes the whole app usable day-to-day. iOS sandboxing means nothing can
reach into the native Instagram app, so instead a personal Shortcuts automation (created once,
manually — Apple has no API for it) watches for Instagram launching and immediately foregrounds
ScrollGuard Clone instead.

*(Source: [diagrams/04-instagram-redirect.puml](diagrams/04-instagram-redirect.puml))*

## Viewing the diagrams

The `.puml` sources under [diagrams/](diagrams/) render with:

- **VS Code** — the "PlantUML" extension (jebbs.plantuml) renders sequence/component diagrams
  locally with no extra install for the preview.
- **IntelliJ / AppCode** — the bundled or "PlantUML integration" plugin.
- **Anything else** — paste the file contents into the official online editor at
  [plantuml.com/plantuml](https://plantuml.com/plantuml).

They're kept as plain text specifically so a future selector change (see `FilterRules.swift`)
that alters one of these flows is a one-line diff, not a re-exported image.
