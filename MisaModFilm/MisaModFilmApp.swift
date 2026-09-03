import SwiftUI
import WebKit
import UIKit
import SafariServices

private let filmURL = URL(string: "https://misamod.site")!

struct WebView: UIViewRepresentable {
    @Binding var isLoading: Bool
    @Binding var loadError: String?

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.websiteDataStore = .default()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        config.defaultWebpagePreferences.allowsContentJavaScript = true

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.backgroundColor = .black
        webView.isOpaque = false
        webView.scrollView.backgroundColor = .black
        webView.scrollView.alwaysBounceVertical = true

        context.coordinator.webView = webView
        context.coordinator.load()
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {}

    final class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        var parent: WebView
        weak var webView: WKWebView?

        init(_ parent: WebView) {
            self.parent = parent
        }

        func load() {
            parent.isLoading = true
            parent.loadError = nil
            webView?.load(URLRequest(url: filmURL, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30))
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.isLoading = true
            parent.loadError = nil
        }

        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            parent.isLoading = false
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.isLoading = false
            parent.loadError = nil
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.isLoading = false
            parent.loadError = "\(error.localizedDescription)\n\nMã lỗi: \((error as NSError).code)\nURL: \(webView.url?.absoluteString ?? filmURL.absoluteString)"
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            parent.isLoading = false
            parent.loadError = "\(error.localizedDescription)\n\nMã lỗi: \((error as NSError).code)\nURL: \(webView.url?.absoluteString ?? filmURL.absoluteString)"
        }

        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
                     decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            decisionHandler(.allow)
        }

        func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration,
                     for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            if let target = navigationAction.request.url {
                webView.load(URLRequest(url: target))
            }
            return nil
        }

        func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String,
                     initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
            completionHandler()
        }
    }
}

struct ContentView: View {
    @State private var isLoading = true
    @State private var loadError: String?
    @State private var reloadToken = UUID()

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            WebView(isLoading: $isLoading, loadError: $loadError)
                .id(reloadToken)
                .ignoresSafeArea()

            if isLoading {
                VStack(spacing: 14) {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.white)
                    Text("Đang tải MisaMod Film…")
                        .foregroundStyle(.white)
                        .font(.system(size: 16, weight: .medium))
                }
                .padding(24)
                .background(.black.opacity(0.72), in: RoundedRectangle(cornerRadius: 18))
            }

            if let loadError {
                VStack(spacing: 16) {
                    Image(systemName: "wifi.exclamationmark")
                        .font(.system(size: 34))
                        .foregroundStyle(.white)
                    Text("Không thể tải MisaMod Film")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.white)
                    Text(loadError)
                        .font(.system(size: 14))
                        .foregroundStyle(.white.opacity(0.75))
                        .multilineTextAlignment(.center)
                        .lineLimit(4)
                    Button("Thử lại") {
                        loadError = nil
                        isLoading = true
                        reloadToken = UUID()
                    }
                    .buttonStyle(.borderedProminent)

                    Button("Mở bằng Safari") {
                        if let url = URL(string: "https://misamod.site") {
                            let scene = UIApplication.shared.connectedScenes
                                .compactMap { $0 as? UIWindowScene }
                                .first
                            let root = scene?.windows.first(where: { $0.isKeyWindow })?.rootViewController
                            root?.present(SFSafariViewController(url: url), animated: true)
                        }
                    }
                    .buttonStyle(.bordered)
                }
                .padding(28)
                .frame(maxWidth: 340)
                .background(.black.opacity(0.88), in: RoundedRectangle(cornerRadius: 22))
                .padding(24)
            }
        }
        .preferredColorScheme(.dark)
    }
}

@main
struct MisaModFilmApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
