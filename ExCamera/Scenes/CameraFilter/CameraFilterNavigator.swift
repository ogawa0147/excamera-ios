import UIKit
import DIKit

protocol CameraFilterNavigator {
    func toMain()
    func toPlayer(url: URL, animated: Bool)
}

final class CameraFilterNavigatorImpl: CameraFilterNavigator, Injectable {
    struct Dependency: NavigatorType {
        let resolver: AppResolver
        let navigationController: UINavigationController
    }

    private let dependency: Dependency

    init(dependency: Dependency) {
        self.dependency = dependency
    }

    func toMain() {
        let viewController = dependency.resolver.resolveCameraFilterViewController(navigator: self)
        dependency.navigationController.pushViewController(viewController, animated: true)
    }

    func toPlayer(url: URL, animated: Bool) {
        let navigator = dependency.resolver.resolvePlayerNavigatorImpl(navigationController: dependency.navigationController)
        navigator.toMain(url: url, animated: true)
    }
}
