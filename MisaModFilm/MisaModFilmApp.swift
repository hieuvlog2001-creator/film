import UIKit
import SafariServices

private let filmURL = URL(string: "https://misamod.site")!

final class ViewController: UIViewController, SFSafariViewControllerDelegate {
    private var safari: SFSafariViewController?
    private var didPresentSafari = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presentSite()
    }

    private func presentSite() {
        guard !didPresentSafari else { return }
        didPresentSafari = true

        let controller = SFSafariViewController(url: filmURL)
        controller.delegate = self
        controller.dismissButtonStyle = .close
        controller.preferredControlTintColor = .systemPink
        safari = controller
        present(controller, animated: false)
    }

    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        didPresentSafari = false
        safari = nil
        DispatchQueue.main.async { [weak self] in
            self?.presentSite()
        }
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
