import UIKit
import Fabric
import Crashlytics

final class Application {

    static let shared = Application()
    private let appResolver = AppResolverImpl()

    private init() {}

    func configureMainInterface(in window: UIWindow) {
        let navigationController = UINavigationController()
        let navigator = appResolver.resolveTopPageNavigatorImpl(navigationController: navigationController)
        navigator.toMain()
        UIView.transition(with: window, duration: 0.2, options: [], animations: {
            window.rootViewController = navigationController
            window.makeKeyAndVisible()
        }, completion: { _ in
        })
    }

    func configureAppearance() {
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        UINavigationBar.appearance().shadowImage = UIImage()
    }

    func configureFabric() {
        Fabric.with([Crashlytics.self])
    }
}
