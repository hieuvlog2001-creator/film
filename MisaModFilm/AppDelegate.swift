import UIKit
import WebKit

private let filmURLs: [URL] = [
    URL(string: "https://misamod.site")!,
    URL(string: "https://www.misamod.site")!,
    URL(string: "http://misamod.site")!,
    URL(string: "http://www.misamod.site")!
]

final class ViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {
    private let webView: WKWebView
    private let loadingView = UIView()
    private let spinner = UIActivityIndicatorView(style: .large)
    private let loadingLabel = UILabel()
    private let errorView = UIView()
    private let errorLabel = UILabel()
    private let retryButton = UIButton(type: .system)
    private var currentURLIndex = 0
    private var lastErrorCode = 0

    init() {
        let config = WKWebViewConfiguration()
        config.websiteDataStore = .default()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        config.defaultWebpagePreferences.allowsContentJavaScript = true
        webView = WKWebView(frame: .zero, configuration: config)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.alwaysBounceVertical = true
        // Thu nhỏ giao diện web trong app để bố cục trên iPhone cân đối hơn.
        // 0.86 = khoảng 86% kích thước hiện tại, vẫn giữ toàn bộ giao diện trong WKWebView.
        webView.pageZoom = 0.86
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        buildLoadingView()
        buildErrorView()
        loadSite()
    }

    private func buildLoadingView() {
        loadingView.backgroundColor = UIColor.black.withAlphaComponent(0.94)
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingView)
        NSLayoutConstraint.activate([
            loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingView.topAnchor.constraint(equalTo: view.topAnchor),
            loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.color = .white
        loadingView.addSubview(spinner)
        loadingLabel.text = "Đang mở MisaMod Film…"
        loadingLabel.textColor = .white
        loadingLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        loadingLabel.textAlignment = .center
        loadingLabel.translatesAutoresizingMaskIntoConstraints = false
        loadingView.addSubview(loadingLabel)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: loadingView.centerYAnchor, constant: -18),
            loadingLabel.topAnchor.constraint(equalTo: spinner.bottomAnchor, constant: 16),
            loadingLabel.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor)
        ])
    }

    private func buildErrorView() {
        errorView.backgroundColor = UIColor.black.withAlphaComponent(0.97)
        errorView.translatesAutoresizingMaskIntoConstraints = false
        errorView.isHidden = true
        view.addSubview(errorView)
        NSLayoutConstraint.activate([
            errorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            errorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            errorView.topAnchor.constraint(equalTo: view.topAnchor),
            errorView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        let title = UILabel()
        title.text = "Không thể tải MisaMod Film"
        title.textColor = .white
        title.font = .systemFont(ofSize: 23, weight: .bold)
        title.textAlignment = .center
        title.translatesAutoresizingMaskIntoConstraints = false
        errorView.addSubview(title)

        errorLabel.textColor = UIColor.white.withAlphaComponent(0.78)
        errorLabel.font = .systemFont(ofSize: 15)
        errorLabel.numberOfLines = 0
        errorLabel.textAlignment = .center
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        errorView.addSubview(errorLabel)

        retryButton.setTitle("Thử lại", for: .normal)
        retryButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        retryButton.backgroundColor = .systemBlue
        retryButton.tintColor = .white
        retryButton.layer.cornerRadius = 14
        retryButton.translatesAutoresizingMaskIntoConstraints = false
        retryButton.addTarget(self, action: #selector(retry), for: .touchUpInside)
        errorView.addSubview(retryButton)

        NSLayoutConstraint.activate([
            title.centerXAnchor.constraint(equalTo: errorView.centerXAnchor),
            title.centerYAnchor.constraint(equalTo: errorView.centerYAnchor, constant: -95),
            title.leadingAnchor.constraint(greaterThanOrEqualTo: errorView.leadingAnchor, constant: 24),
            title.trailingAnchor.constraint(lessThanOrEqualTo: errorView.trailingAnchor, constant: -24),
            errorLabel.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 18),
            errorLabel.leadingAnchor.constraint(equalTo: errorView.leadingAnchor, constant: 28),
            errorLabel.trailingAnchor.constraint(equalTo: errorView.trailingAnchor, constant: -28),
            retryButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 28),
            retryButton.leadingAnchor.constraint(equalTo: errorView.leadingAnchor, constant: 40),
            retryButton.trailingAnchor.constraint(equalTo: errorView.trailingAnchor, constant: -40),
            retryButton.heightAnchor.constraint(equalToConstant: 54)
        ])
    }

    private func loadSite() {
        currentURLIndex = 0
        lastErrorCode = 0
        errorView.isHidden = true
        loadingView.isHidden = false
        spinner.startAnimating()
        attemptCurrentURL()
    }

    private func attemptCurrentURL() {
        guard currentURLIndex < filmURLs.count else {
            spinner.stopAnimating()
            loadingView.isHidden = true
            errorLabel.text = "Không thể kết nối MisaMod Film.\n\nĐã thử nhiều đường dẫn HTTPS/HTTP.\nMã lỗi cuối: \(lastErrorCode)"
            errorView.isHidden = false
            return
        }
        let url = filmURLs[currentURLIndex]
        loadingLabel.text = "Đang kết nối MisaMod Film…"
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 20)
        request.setValue("1", forHTTPHeaderField: "DNT")
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 18_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148", forHTTPHeaderField: "User-Agent")
        webView.load(request)
    }

    private func nextURL(after error: Error) {
        lastErrorCode = (error as NSError).code
        currentURLIndex += 1
        attemptCurrentURL()
    }

    @objc private func retry() { loadSite() }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        loadingView.isHidden = false
        errorView.isHidden = true
        spinner.startAnimating()
    }

    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        loadingView.isHidden = true
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loadingView.isHidden = true
        errorView.isHidden = true
        spinner.stopAnimating()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        nextURL(after: error)
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        nextURL(after: error)
    }

    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration,
                 for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if let url = navigationAction.request.url { webView.load(URLRequest(url: url)) }
        return nil
    }

    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String,
                 initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        completionHandler()
    }
}

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = ViewController()
        window.makeKeyAndVisible()
        self.window = window
        return true
    }
}
