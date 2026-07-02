import WebKit

/// Builds the `WKUserScript` that applies the filter rules inside the web
/// view. The script is injected at document start so structural CSS is in
/// place before first paint — blocked content never flashes on screen.
enum ContentFilter {
    static func makeUserScript(rules: [FilterRule]) -> WKUserScript {
        let cssRules = rules.map(\.css).filter { !$0.isEmpty }
        let markers = rules.flatMap(\.markers)
        let blockedRoutes = rules.flatMap(\.blockedRoutePrefixes)

        let source = runtime
            .replacingOccurrences(of: "__SG_CSS_RULES__", with: jsonLiteral(cssRules))
            .replacingOccurrences(of: "__SG_MARKERS__", with: jsonLiteral(markers))
            .replacingOccurrences(of: "__SG_BLOCKED_ROUTES__", with: jsonLiteral(blockedRoutes))

        return WKUserScript(
            source: source,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: true
        )
    }

    /// Rule data crosses into JS as JSON literals so quotes, accents, and
    /// newlines in the rules can never break the script.
    private static func jsonLiteral(_ strings: [String]) -> String {
        let data = (try? JSONEncoder().encode(strings)) ?? Data("[]".utf8)
        return String(decoding: data, as: UTF8.self)
    }

    /// The in-page runtime. Instagram is a React single-page app, so beyond
    /// injecting CSS this has to: expose the current route on `<html>` for
    /// route-scoped CSS, re-scan as the feed lazily renders (MutationObserver),
    /// and re-check hidden units in case React recycles their DOM nodes for
    /// real posts.
    private static let runtime = #"""
    (function () {
        'use strict';
        if (window.__scrollGuard) { return; }
        window.__scrollGuard = true;

        var CSS = __SG_CSS_RULES__.join('\n');
        var MARKERS = __SG_MARKERS__;
        var BLOCKED_ROUTES = __SG_BLOCKED_ROUTES__;

        function injectStyle() {
            if (!CSS || document.getElementById('sg-style')) { return; }
            var parent = document.head || document.documentElement;
            if (!parent) { return; }
            var style = document.createElement('style');
            style.id = 'sg-style';
            style.textContent = CSS;
            parent.appendChild(style);
        }

        // Route-scoped CSS (e.g. the Explore grid rule) keys off this
        // attribute; it must stay correct across SPA navigation, which
        // never triggers a real page load.
        function updateRoute() {
            var html = document.documentElement;
            if (html) { html.setAttribute('data-sg-path', location.pathname); }
        }

        function enforceRoutes() {
            for (var i = 0; i < BLOCKED_ROUTES.length; i++) {
                if (location.pathname.indexOf(BLOCKED_ROUTES[i]) === 0) {
                    location.replace('/');
                    return true;
                }
            }
            return false;
        }

        ['pushState', 'replaceState'].forEach(function (name) {
            var original = history[name];
            history[name] = function () {
                var result = original.apply(this, arguments);
                onNavigate();
                return result;
            };
        });
        window.addEventListener('popstate', onNavigate);

        function isMarkerText(value) {
            return MARKERS.indexOf(value.trim()) !== -1;
        }

        function findMarkerNodes(root) {
            var walker = document.createTreeWalker(root, NodeFilter.SHOW_TEXT);
            var hits = [];
            while (walker.nextNode()) {
                var node = walker.currentNode;
                if (node.nodeValue && isMarkerText(node.nodeValue)) { hits.push(node); }
            }
            return hits;
        }

        // A marker labels a feed unit. Posts live in <article>; other units
        // ("Suggested for you" account carousels) have no stable tag, so we
        // climb to the outermost ancestor that contains no real post. Hop
        // caps and the main/body stops make sure a bad match can't blank
        // the whole feed.
        function containerFor(node) {
            var el = node.parentElement;
            for (var hops = 0; el && hops < 12; hops++) {
                if (el.tagName === 'ARTICLE') { return el; }
                el = el.parentElement;
            }
            var candidate = null;
            el = node.parentElement;
            for (hops = 0; el && hops < 12; hops++) {
                if (el.tagName === 'MAIN' || el.tagName === 'BODY' || el.tagName === 'HTML') { break; }
                if (el.querySelector('article')) { break; }
                candidate = el;
                el = el.parentElement;
            }
            return candidate;
        }

        function hideSuggestedUnits() {
            if (MARKERS.length === 0) { return; }
            var root = document.querySelector('main');
            if (!root) { return; }
            findMarkerNodes(root).forEach(function (node) {
                var container = containerFor(node);
                if (container && !container.hasAttribute('data-sg-hidden')) {
                    container.setAttribute('data-sg-hidden', '');
                    container.style.setProperty('display', 'none', 'important');
                }
            });
        }

        // React recycles DOM nodes as the feed virtualizes; a node we hid as
        // "Suggested for you" can be reused for a followed account's post.
        // Unhide anything that no longer contains a marker.
        function unhideStaleUnits() {
            var hidden = document.querySelectorAll('[data-sg-hidden]');
            for (var i = 0; i < hidden.length; i++) {
                if (findMarkerNodes(hidden[i]).length === 0) {
                    hidden[i].removeAttribute('data-sg-hidden');
                    hidden[i].style.removeProperty('display');
                }
            }
        }

        var scanPending = false;
        function scheduleScan() {
            if (scanPending) { return; }
            scanPending = true;
            setTimeout(function () {
                scanPending = false;
                scan();
            }, 200);
        }

        function scan() {
            if (enforceRoutes()) { return; }
            injectStyle();
            updateRoute();
            unhideStaleUnits();
            hideSuggestedUnits();
        }

        function onNavigate() {
            if (enforceRoutes()) { return; }
            updateRoute();
            scheduleScan();
        }

        new MutationObserver(scheduleScan).observe(document, { childList: true, subtree: true });
        document.addEventListener('DOMContentLoaded', scan);
        scan();
    })();
    """#
}
