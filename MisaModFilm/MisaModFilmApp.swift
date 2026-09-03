import SwiftUI
import WebKit
import UIKit

private let filmURL = URL(string: "https://misamod.site")!

struct FilmWebView: UIViewRepresentable {
    @Binding var isLoading: Bool
    @Binding var errorMessage: String?
    @Binding var reloadID: UUID

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .default()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.backgroundColor = .black
        webView.isOpaque = true
        webView.scrollView.backgroundColor = .black
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.allowsBackForwardNavigationGestures = true
        webView.configuration.preferences.javaScriptCanOpenWindowsAutomatically = true

        context.coordinator.webView = webView
        context.coordinator.start()
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        if context.coordinator.lastReloadID != reloadID {
            context.coordinator.lastReloadID = reloadID
            context.coordinator.start()
        }
    }

    final class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        let parent: FilmWebView
        weak var webView: WKWebView?
        var lastReloadID = UUID()

        init(_ parent: FilmWebView) { self.parent = parent }

        func start() {
            DispatchQueue.main.async {
                self.parent.isLoading = true
                self.parent.errorMessage = nil
            }
            var request = URLRequest(url: filmURL,
                                     cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                     timeoutInterval: 45)
            request.setValue("1", forHTTPHeaderField: "DNT")
            webView?.load(request)
        }

        func navigationError(_ error: Error) {
            let ns = error as NSError
            DispatchQueue.main.async {
                self.parent.isLoading = false
                self.parent.errorMessage = "\(error.localizedDescription)\nMã lỗi: \(ns.code)"
            }
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.isLoading = true
            parent.errorMessage = nil
        }

        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            parent.isLoading = false
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.isLoading = false
            parent.errorMessage = nil
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            navigationError(error)
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            navigationError(error)
        }

        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
                     decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            decisionHandler(.allow)
        }

        func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration,
                     for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            if let url = navigationAction.request.url {
                webView.load(URLRequest(url: url))
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
    @State private var errorMessage: String?
    @State private var reloadID = UUID()

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            FilmWebView(isLoading: $isLoading,
                        errorMessage: $errorMessage,
                        reloadID: $reloadID)
                .id(reloadID)
                .ignoresSafeArea()

            if isLoading {
                VStack(spacing: 14) {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.white)
                    Text("Đang mở MisaMod Film…")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                }
                .padding(24)
                .background(.black.opacity(0.82), in: RoundedRectangle(cornerRadius: 22))
            }

            if let errorMessage {
                VStack(spacing: 16) {
                    Image(systemName: "wifi.exclamationmark")
                        .font(.system(size: 38))
                        .foregroundStyle(.white)
                    Text("Không thể tải MisaMod Film")
                        .font(.system(size: 21, weight: .bold))
                        .foregroundStyle(.white)
                    Text(errorMessage)
                        .font(.system(size: 14))
                        .foregroundStyle(.white.opacity(0.72))
                        .multilineTextAlignment(.center)
                    Button("Thử lại") {
                        errorMessage = nil
                        reloadID = UUID()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(28)
                .frame(maxWidth: 350)
                .background(.black.opacity(0.92), in: RoundedRectangle(cornerRadius: 24))
                .padding(24)
            }
        }
        .preferredColorScheme(.dark)
        .statusBarHidden(false)
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
