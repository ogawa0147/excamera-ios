import UIKit
import DIKit

protocol CameraVisionNavigator {
    func toMain()
    func toPlayer(url: URL, animated: Bool)
}

final class CameraVisionNavigatorImpl: CameraVisionNavigator, Injectable {
    struct Dependency: NavigatorType {
        let resolver: AppResolver
        let navigationController: UINavigationController
    }

    private let dependency: Dependency

    init(dependency: Dependency) {
        self.dependency = dependency
    }

    func toMain() {
        let viewController = dependency.resolver.resolveCameraVisionViewController(navigator: self)
        dependency.navigationController.pushViewController(viewController, animated: true)
    }

    func toPlayer(url: URL, animated: Bool) {
        let navigator = dependency.resolver.resolvePlayerNavigatorImpl(navigationController: dependency.navigationController)
        navigator.toMain(url: url, animated: true)
    }
}
