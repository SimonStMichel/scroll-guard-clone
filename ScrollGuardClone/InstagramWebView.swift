import SwiftUI
import WebKit

/// Lets native UI (the settings sheet) drive the web view without owning it.
final class WebViewProxy: ObservableObject {
    weak var webView: WKWebView?

    func goHome() {
        webView?.load(URLRequest(url: InstagramWebView.homeURL))
    }

    func reload() {
        webView?.reload()
    }

    func goBack() {
        webView?.goBack()
    }
}

/// Full-screen web client for instagram.com with the content filters from
/// `Filtering/` injected before every page load.
struct InstagramWebView: UIViewRepresentable {
    static let homeURL = URL(string: "https://www.instagram.com/")!

    /// Rules currently enabled in settings. When the set changes, the filter
    /// script is reinstalled and the page reloaded (user scripts only apply
    /// on navigation, so a reload is the honest way to make toggles take
    /// effect immediately).
    let enabledRules: [FilterRule]
    let proxy: WebViewProxy

    /// WKWebView's default user agent makes Instagram serve a degraded
    /// "unsupported browser" page, so we present as stock iOS Safari.
    static let safariUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_5 like Mac OS X) "
        + "AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.5 Mobile/15E148 Safari/604.1"

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        // Persistent store: log in once, stay logged in across launches.
        configuration.websiteDataStore = .default()
        configuration.allowsInlineMediaPlayback = true
        configuration.userContentController.addUserScript(
            ContentFilter.makeUserScript(rules: enabledRules)
        )
        context.coordinator.installedRuleIDs = Set(enabledRules.map(\.id))

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.customUserAgent = Self.safariUserAgent
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(
            context.coordinator,
            action: #selector(Coordinator.handleRefresh),
            for: .valueChanged
        )
        webView.scrollView.refreshControl = refreshControl

        context.coordinator.webView = webView
        proxy.webView = webView
        webView.load(URLRequest(url: Self.homeURL))
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        let ids = Set(enabledRules.map(\.id))
        guard ids != context.coordinator.installedRuleIDs else { return }
        context.coordinator.installedRuleIDs = ids

        let controller = webView.configuration.userContentController
        controller.removeAllUserScripts()
        controller.addUserScript(ContentFilter.makeUserScript(rules: enabledRules))
        webView.reload()
    }

    final class Coordinator: NSObject, WKNavigationDelegate {
        weak var webView: WKWebView?
        var installedRuleIDs: Set<String> = []

        /// Hosts the web view may navigate to. Facebook domains are needed for
        /// the "Log in with Facebook" flow; everything else opens in Safari so
        /// the app can't quietly become a general-purpose browser.
        private let allowedHosts = [
            "instagram.com",
            "cdninstagram.com",
            "instagr.am",
            "facebook.com",
            "fbcdn.net",
        ]

        private func isAllowed(_ url: URL) -> Bool {
            guard let host = url.host else { return false }
            return allowedHosts.contains { host == $0 || host.hasSuffix("." + $0) }
        }

        @objc func handleRefresh() {
            webView?.reload()
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            webView.scrollView.refreshControl?.endRefreshing()
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            webView.scrollView.refreshControl?.endRefreshing()
        }

        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction,
            decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
        ) {
            guard let url = navigationAction.url, url.scheme?.hasPrefix("http") == true else {
                decisionHandler(.cancel)
                return
            }
            if isAllowed(url) {
                decisionHandler(.allow)
            } else if navigationAction.navigationType == .linkActivated {
                UIApplication.shared.open(url)
                decisionHandler(.cancel)
            } else {
                decisionHandler(.cancel)
            }
        }
    }
}
