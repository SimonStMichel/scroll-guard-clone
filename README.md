# ScrollGuard Clone

A free, self-built alternative to [ScrollGuard](https://scrollguard.app/): use Instagram without
Reels, without suggested posts in your feed, and without the algorithmic grid on the search page.

Built for personal use on iOS first, with an Android version planned later.

## How it works

iOS sandboxing means no app can modify the UI of another app — nothing can reach inside the
native Instagram app and hide the Reels button. So, like ScrollGuard, this app uses a
three-piece workaround:

1. **A filtered Instagram web client.** The app is a thin shell around a `WKWebView` that loads
   `instagram.com` (mobile web). Because we control the web view, we can inject CSS/JS that
   hides the Reels tab, strips suggested posts from the home feed, and blanks the Explore grid.
2. **An Apple Shortcuts automation as the redirect.** You keep the real Instagram app installed
   (so notifications and DMs still work) and set up a Shortcuts automation:
   *"When Instagram opens → open ScrollGuard Clone."* Instagram flashes for a moment, then you
   land in the filtered client. The app registers the `scrollguard://` URL scheme so the
   shortcut can open it.
3. **(Optional, later) Screen Time shielding** via the FamilyControls framework to hard-block
   the native app instead of relying on the redirect.

## Repository layout

```
ScrollGuardClone.xcodeproj/   Xcode project (open this)
ScrollGuardClone/             App source (SwiftUI + WebKit)
docs/PLAN.md                  Phased development plan and current status
docs/SETUP.md                 How to build and run on your iPhone
docs/MAC-CHECKLIST.md         What to do next time you're on the Mac
docs/DEVLOG.md                Running notes on what was built and why
```

## Quick start

1. Open `ScrollGuardClone.xcodeproj` in Xcode on your Mac.
2. Select your personal team under *Signing & Capabilities* (a free Apple ID works).
3. Plug in your iPhone, select it as the run destination, and hit **Run**.

Full instructions, including first-run trust settings on the phone, are in
[docs/SETUP.md](docs/SETUP.md).

## Status

Phases 0–3 built (web shell, content filters, settings, redirect onboarding); on-device
acceptance pending — see [docs/PLAN.md](docs/PLAN.md) for the roadmap and
[docs/MAC-CHECKLIST.md](docs/MAC-CHECKLIST.md) for the test session.
