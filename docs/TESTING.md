# Testing checklist

Run through this after building and installing the app ([SETUP.md](SETUP.md)) to confirm the
filters, the settings and the redirect all behave on your phone.

It is also the checklist to re-run when something starts slipping through. The filters target
Instagram's live markup, so they are best-effort against a site that changes without notice.
Section 5 covers what to do when that happens.

## 1. First run

- [ ] The app opens Instagram's mobile site. Log in with your normal account.
- [ ] Kill the app and reopen it. You should still be logged in.
- [ ] The home screen shows the shield icon, named "ScrollGuard Clone".

## 2. The filters

- [ ] The bottom bar has **no Reels tab**.
- [ ] Scroll the home feed for a while: **no "Suggested for you" or "Sponsored"** units.
- [ ] Open the search tab: **no photo or reel grid**, just the search box, and searching for an
      account still works.

## 3. The settings sheet

- [ ] Tap the small shield handle on the right edge of the screen. The sheet opens.
- [ ] Flip "Hide the Reels tab" off. The page reloads and the Reels tab is back. Flip it on again.
- [ ] Kill the app and reopen it. The toggles kept their state.
- [ ] Try "Home feed" and "Reload" in the sheet.

## 4. The Instagram redirect

- [ ] A fresh install shows the walkthrough on launch. You can also reopen it any time from the
      settings sheet. Follow its 7 steps to create the Shortcuts automation.
- [ ] The acceptance test: **open the real Instagram app and you land in ScrollGuard Clone.**
- [ ] Tap "It works - I'm done" so the walkthrough stops showing on launch.

## 5. When a filter stops working

Instagram ships layout changes regularly, and its class names are obfuscated and unstable. When
something slips through or something legitimate disappears, that is expected maintenance rather
than a broken build. Note exactly what you saw:

- **A suggested or sponsored post got through.** Write down its header label word for word, and
  which language your Instagram is set to. The shipped rules cover English and French.
- **Something legitimate got hidden**, such as a followed account's post or a piece of UI.
- **A walkthrough step no longer matches** what your iPhone actually shows.

Every one of those maps onto a single file,
[`ScrollGuardClone/Filtering/FilterRules.swift`](../ScrollGuardClone/Filtering/FilterRules.swift),
which is deliberately the only place that knows anything about Instagram's markup:

- `markers` holds the exact text labels the JS scanner matches, so a new "Suggested for you"
  wording or a new language is a one-line addition.
- `css` holds the structural selectors applied before first paint.
- `blockedRoutePrefixes` bounces the single-page app back to the home feed if a route slips
  through, such as a deep link straight into the Reels feed.

See [ARCHITECTURE.md](ARCHITECTURE.md) for how a rule becomes an injected script, and why a
toggle has to reload the page.
