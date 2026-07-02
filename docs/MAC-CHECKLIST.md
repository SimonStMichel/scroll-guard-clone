# Mac session checklist

Everything to do next time you're on the Mac. Goal: get the app on your iPhone and accept
Phases 1–3 in one sitting.

## 0. Before leaving the Windows PC

- [ ] Commit and push the Phase 3 changes (this file included), or the Mac won't have them.

## 1. Get it running (≈10 min the first time)

- [ ] Pull the repo and open `ScrollGuardClone.xcodeproj` in Xcode.
- [ ] One-time setup (signing team, trusting the phone/certificate, Developer Mode):
      follow [SETUP.md](SETUP.md) steps 2–5.
- [ ] Press Run with your iPhone selected. You should see the purple splash, then Instagram —
      log in with your normal account.

## 2. Test Phase 1 — filters

- [ ] Bottom bar has **no Reels tab**.
- [ ] Scroll the home feed for a while: **no "Suggested for you" or "Sponsored"** units.
- [ ] Open the search tab: **no photo/reel grid**, just the search box — and searching for an
      account still works.

## 3. Test Phase 2 — settings

- [ ] Tap the small shield handle on the right edge → toggles sheet opens.
- [ ] Flip "Hide the Reels tab" off: page reloads, Reels tab is back. Flip it on again.
- [ ] Kill the app, reopen: toggles kept their state.
- [ ] Try "Home feed" and "Reload" in the sheet.

## 4. Test Phase 3 — redirect + polish

- [ ] Fresh install shows the redirect walkthrough automatically (or open it from the
      settings sheet). Follow the 7 steps to create the Shortcuts automation.
- [ ] The acceptance test: **open the real Instagram app → you land in ScrollGuard Clone.**
- [ ] Home screen shows the shield icon with the name "ScrollGuard Clone".
- [ ] Tap "It works — I'm done" in the walkthrough so it stops auto-showing.

## 5. Report back

Filters are best-effort until they meet the live site, so note anything that's off:

- A suggested/sponsored post that **slipped through** → what its header label said, exactly
  (and your Instagram language — rules currently cover English + French).
- Something legit that **got hidden** (a followed account's post, a UI element).
- A walkthrough step whose **wording doesn't match** what your iPhone shows.
- Anything else: login trouble, layout glitches, the handle covering something it shouldn't.

Bring that list back and the rules in `ScrollGuardClone/Filtering/FilterRules.swift` get
tightened — then Phase 4/5 are up.
