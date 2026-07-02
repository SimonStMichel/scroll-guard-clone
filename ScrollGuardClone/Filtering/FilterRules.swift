import Foundation

/// One removable Instagram surface.
///
/// This file is the maintenance point when Instagram changes its markup:
/// every selector and marker lives here, with notes on what it matches and
/// why. Instagram's class names are obfuscated and churn constantly, so the
/// rules only rely on stable hooks: URL paths in `href` attributes, the
/// current SPA route (exposed as `data-sg-path` on `<html>` by the runtime
/// in `ContentFilter.swift`), and visible text labels.
///
/// - `css` hides elements structurally and is applied before first paint.
/// - `markers` are *exact* text labels (after trimming) that identify feed
///   units the JS scanner should hide — needed because CSS can't match text.
/// - `blockedRoutePrefixes` bounce the SPA back to the home feed if a route
///   slips through (e.g. a deep link straight into the Reels feed).
struct FilterRule: Identifiable {
    let id: String
    let title: String
    var css: String = ""
    var markers: [String] = []
    var blockedRoutePrefixes: [String] = []
}

extension FilterRule {
    /// Master list of rules; the user's enable/disable state lives in
    /// `FilterSettings`.
    static let all: [FilterRule] = [hideReelsTab, hideFeedSuggestions, hideExploreGrid]

    /// The Reels tab in the bottom bar, plus any other link into the Reels
    /// feed. Matches `/reels...` (the endless feed) but deliberately NOT
    /// `/reel/<id>` (a single reel a friend shared — that's normal social
    /// use, not doomscrolling). The route block covers direct navigation.
    static let hideReelsTab = FilterRule(
        id: "reels-tab",
        title: "Hide the Reels tab",
        css: """
        a[href^="/reels"] { display: none !important; }
        """,
        blockedRoutePrefixes: ["/reels"]
    )

    /// Suggested and sponsored units in the home feed. No stable structure
    /// to target, so the JS scanner looks for these exact header labels and
    /// hides the enclosing unit. Labels are locale-specific — English and
    /// French are covered; add your locale's labels here if the feed shows
    /// suggestions in another language.
    static let hideFeedSuggestions = FilterRule(
        id: "feed-suggestions",
        title: "Hide suggested posts in the feed",
        markers: [
            // English
            "Suggested for you",
            "Suggested posts",
            "Suggested Reels",
            "Suggested reels",
            "Sponsored",
            // French (Instagram uses both depending on region)
            "Suggestions pour vous",
            "Publications suggérées",
            "Reels suggérés",
            "Sponsorisé",
            "Commandité",
        ]
    )

    /// The algorithmic grid on the search/Explore page. Rather than guessing
    /// at obfuscated containers, hide every post/reel link inside `main`
    /// while on an `/explore` route — that removes the grid tiles but leaves
    /// the search box and its results (accounts, hashtags, places) intact,
    /// since those link to profiles/tags, not `/p/` or `/reel`.
    static let hideExploreGrid = FilterRule(
        id: "explore-grid",
        title: "Hide the Explore grid",
        css: """
        html[data-sg-path^="/explore"] main a[href^="/p/"],
        html[data-sg-path^="/explore"] main a[href^="/reel"] { display: none !important; }
        """
    )
}
