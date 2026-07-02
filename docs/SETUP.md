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
