import UIKit
import WebKit
import SafariServices

private let filmURL = URL(string: "https://misamod.site")!

final class ViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {
    private var webView: WKWebView!
    private var spinner: UIActivityIndicatorView!
    private var loadingLabel: UILabel!
    private var errorPanel: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupWebView()
        setupLoading()
        loadSite()
    }

    private func setupWebView() {
        let config = WKWebViewConfiguration()
        config.websiteDataStore = .default()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        config.defaultWebpagePreferences.allowsContentJavaScript = true

        webView = WKWebView(frame: .zero, configuration: config)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.backgroundColor = .black
        webView.isOpaque = false
        webView.scrollView.backgroundColor = .black
        webView.scrollView.alwaysBounceVertical = true
        view.addSubview(webView)

        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupLoading() {
        let box = UIView()
        box.translatesAutoresizingMaskIntoConstraints = false
        box.backgroundColor = UIColor(white: 0, alpha: 0.78)
        box.layer.cornerRadius = 18
        view.addSubview(box)

        spinner = UIActivityIndicatorView(style: .large)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.color = .white
        spinner.startAnimating()
        box.addSubview(spinner)

        loadingLabel = UILabel()
        loadingLabel.translatesAutoresizingMaskIntoConstraints = false
        loadingLabel.text = "Đang tải MisaMod Film…"
        loadingLabel.textColor = .white
        loadingLabel.font = .systemFont(ofSize: 16, weight: .medium)
        loadingLabel.textAlignment = .center
        box.addSubview(loadingLabel)

        NSLayoutConstraint.activate([
            box.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            box.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            box.widthAnchor.constraint(equalToConstant: 230),
            box.heightAnchor.constraint(equalToConstant: 125),
            spinner.centerXAnchor.constraint(equalTo: box.centerXAnchor),
            spinner.topAnchor.constraint(equalTo: box.topAnchor, constant: 22),
            loadingLabel.centerXAnchor.constraint(equalTo: box.centerXAnchor),
            loadingLabel.topAnchor.constraint(equalTo: spinner.bottomAnchor, constant: 14),
            loadingLabel.leadingAnchor.constraint(equalTo: box.leadingAnchor, constant: 10),
            loadingLabel.trailingAnchor.constraint(equalTo: box.trailingAnchor, constant: -10)
        ])
    }

    private func loadSite() {
        removeErrorPanel()
        spinner.isHidden = false
        loadingLabel.isHidden = false
        webView.load(URLRequest(url: filmURL, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30))
    }

    private func showError(_ error: Error) {
        spinner.isHidden = true
        loadingLabel.isHidden = true
        removeErrorPanel()

        let panel = UIView()
        panel.translatesAutoresizingMaskIntoConstraints = false
        panel.backgroundColor = UIColor(white: 0, alpha: 0.92)
        panel.layer.cornerRadius = 22
        view.addSubview(panel)

        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = "Không thể tải MisaMod Film"
        title.textColor = .white
        title.font = .systemFont(ofSize: 20, weight: .bold)
        title.textAlignment = .center
        panel.addSubview(title)

        let ns = error as NSError
        let detail = UILabel()
        detail.translatesAutoresizingMaskIntoConstraints = false
        detail.text = "\(error.localizedDescription)\n\nMã lỗi: \(ns.code)"
        detail.textColor = UIColor.white.withAlphaComponent(0.75)
        detail.font = .systemFont(ofSize: 14)
        detail.numberOfLines = 0
        detail.textAlignment = .center
        panel.addSubview(detail)

        let retry = UIButton(type: .system)
        retry.translatesAutoresizingMaskIntoConstraints = false
        retry.setTitle("Thử lại", for: .normal)
        retry.setTitleColor(.white, for: .normal)
        retry.backgroundColor = .systemBlue
        retry.layer.cornerRadius = 12
        retry.addTarget(self, action: #selector(retryTapped), for: .touchUpInside)
        panel.addSubview(retry)

        let safari = UIButton(type: .system)
        safari.translatesAutoresizingMaskIntoConstraints = false
        safari.setTitle("Mở bằng Safari", for: .normal)
        safari.setTitleColor(.white, for: .normal)
        safari.backgroundColor = UIColor(white: 1, alpha: 0.14)
        safari.layer.cornerRadius = 12
        safari.addTarget(self, action: #selector(safariTapped), for: .touchUpInside)
        panel.addSubview(safari)

        NSLayoutConstraint.activate([
            panel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            panel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            panel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 24),
            panel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24),
            panel.widthAnchor.constraint(lessThanOrEqualToConstant: 340),
            title.topAnchor.constraint(equalTo: panel.topAnchor, constant: 24),
            title.leadingAnchor.constraint(equalTo: panel.leadingAnchor, constant: 20),
            title.trailingAnchor.constraint(equalTo: panel.trailingAnchor, constant: -20),
            detail.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 14),
            detail.leadingAnchor.constraint(equalTo: panel.leadingAnchor, constant: 20),
            detail.trailingAnchor.constraint(equalTo: panel.trailingAnchor, constant: -20),
            retry.topAnchor.constraint(equalTo: detail.bottomAnchor, constant: 20),
            retry.leadingAnchor.constraint(equalTo: panel.leadingAnchor, constant: 24),
            retry.trailingAnchor.constraint(equalTo: panel.trailingAnchor, constant: -24),
            retry.heightAnchor.constraint(equalToConstant: 46),
            safari.topAnchor.constraint(equalTo: retry.bottomAnchor, constant: 10),
            safari.leadingAnchor.constraint(equalTo: retry.leadingAnchor),
            safari.trailingAnchor.constraint(equalTo: retry.trailingAnchor),
            safari.heightAnchor.constraint(equalToConstant: 46),
            safari.bottomAnchor.constraint(equalTo: panel.bottomAnchor, constant: -24)
        ])
        errorPanel = panel
    }

    private func removeErrorPanel() {
        errorPanel?.removeFromSuperview()
        errorPanel = nil
    }

    @objc private func retryTapped() { loadSite() }

    @objc private func safariTapped() {
        present(SFSafariViewController(url: filmURL), animated: true)
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        spinner.isHidden = false
        loadingLabel.isHidden = false
        removeErrorPanel()
    }

    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        spinner.isHidden = true
        loadingLabel.isHidden = true
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        spinner.isHidden = true
        loadingLabel.isHidden = true
        removeErrorPanel()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        showError(error)
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        showError(error)
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }

    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if let url = navigationAction.request.url { webView.load(URLRequest(url: url)) }
        return nil
    }

    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        completionHandler()
    }
}

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = ViewController()
        self.window = window
        window.makeKeyAndVisible()
        return true
    }
}
