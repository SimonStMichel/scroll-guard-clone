# Building and running on your iPhone

## Prerequisites

- A Mac with Xcode 16 or newer (App Store → "Xcode").
- An iPhone on iOS 17 or newer, plus a cable (Wi-Fi debugging works after the first wired run).
- An Apple ID. A free one is enough — see the note on the 7-day limit below.

## Steps

1. Clone this repo and open `ScrollGuardClone.xcodeproj` in Xcode.
2. In the project navigator, select the **ScrollGuardClone** project → **ScrollGuardClone**
   target → **Signing & Capabilities** tab:
   - Check **Automatically manage signing**.
   - Pick your **Team** (add your Apple ID under Xcode → Settings → Accounts if the list is
     empty).
   - If Xcode complains the bundle identifier is taken, change
     `com.simonstmichel.scrollguardclone` to anything unique.
3. Plug in your iPhone and select it in the run-destination picker at the top of the window.
   The first time, the phone asks you to trust the computer, and Xcode may need a few minutes
   to prepare the device.
4. Press **Run** (⌘R).
5. First install only: the app won't launch until you trust your developer certificate on the
   phone — **Settings → General → VPN & Device Management** → your Apple ID → **Trust**.
   You may also need to enable **Settings → Privacy & Security → Developer Mode** and reboot.

## Verifying Phase 0

- The app opens Instagram's mobile site; log in with your normal account.
- Kill the app and reopen it — you should still be logged in.
- In Safari, type `scrollguard://` in the address bar and go — the app should open. This is
  the hook the Shortcuts automation will use later.

## Setting up the Instagram redirect

On first launch the app walks you through creating the Shortcuts automation ("When Instagram
opens → open ScrollGuard Clone"). It takes about 30 seconds and can be reopened any time from
the settings sheet (the shield handle on the right edge of the screen).

## Note: free Apple ID vs. paid developer account

With a free Apple ID, the app's signature expires after **7 days** — the app stops launching
and you just re-run it from Xcode to re-sign. The $99/year Apple Developer Program removes
that limit and enables TestFlight, which is only needed when friends want the app.

## Phase 4 setup: adding the Screen Time hard-block targets

Phase 4 needs two new app extension targets before any code can be written — Xcode has to
generate them (new build phases, provisioning, an embed-extensions step on the host app) so
this isn't something to hand-edit into the project file. About 10 minutes, one-time.

1. With `ScrollGuardClone.xcodeproj` open, **File → New → Target…**. Filter/search for
   "Family Controls" — pick **Shield Configuration Extension**. Product name: `ShieldConfiguration`
   (use exactly this name so the generated files match what gets built next). Finish.
2. **File → New → Target…** again, this time **Shield Action Extension**. Product name:
   `ShieldAction`. Finish.
3. Xcode will prompt to "Activate" each new scheme and should automatically add an embed
   step to the ScrollGuardClone app target — accept the defaults.
4. For **each of the three targets** (ScrollGuardClone, ShieldConfiguration, ShieldAction):
   select it → **Signing & Capabilities** tab → **+ Capability** → **Family Controls**. The
   two extension templates may already include it — check first, only add if it's missing.
5. On the two new targets, also confirm (same tab): **Automatically manage signing** is
   checked and **Team** is set to your account — new targets don't inherit signing settings
   from the host app.
6. **Build only** (⌘B) — no code has been written yet, this just confirms the three-target
   project compiles and signs. If it fails, stop here and report the error before going
   further; if it succeeds, commit and push so the extension code can be filled in.

Note: this registers two new App IDs against your Apple ID's developer-portal quota (on top
of the app's existing bundle ID) — shouldn't be an issue for a first pass. Also, once the
shield is live in a later step, a free Apple ID's 7-day signature expiry (above) gets a sharper
edge: unlike Phases 0–3, a lapsed signature can leave native Instagram shielded with no
in-app way to clear it until you re-sign from Xcode. Recoverable, just worth knowing going in.
