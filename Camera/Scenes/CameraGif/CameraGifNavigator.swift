import UIKit
import DIKit

protocol CameraGifNavigator {
    func toMain()
    func toPlayer(url: URL, animated: Bool)
}

final class CameraGifNavigatorImpl: CameraGifNavigator, Injectable {
    struct Dependency: NavigatorType {
        let resolver: AppResolver
        let navigationController: UINavigationController
    }

    private let dependency: Dependency

    init(dependency: Dependency) {
        self.dependency = dependency
    }

    func toMain() {
        let viewController = dependency.resolver.resolveCameraGifViewController(navigator: self)
        dependency.navigationController.pushViewController(viewController, animated: true)
    }

    func toPlayer(url: URL, animated: Bool) {
        let navigator = dependency.resolver.resolvePlayerNavigatorImpl(navigationController: dependency.navigationController)
        navigator.toMain(url: url, animated: true)
    }
}
