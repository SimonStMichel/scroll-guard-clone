import SwiftUI
import WebKit

/// Full-screen web client for instagram.com. Phase 1 will inject the content
/// filters into this web view; Phase 0 is just a well-behaved shell.
struct InstagramWebView: UIViewRepresentable {
    static let homeURL = URL(string: "https://www.instagram.com/")!

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
        webView.load(URLRequest(url: Self.homeURL))
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {}

    final class Coordinator: NSObject, WKNavigationDelegate {
        weak var webView: WKWebView?

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
