import UIKit
import DIKit

protocol VideoNavigator {
    func toMain()
}

final class VideoNavigatorImpl: VideoNavigator, Injectable {
    struct Dependency: NavigatorType {
        let resolver: AppResolver
        let navigationController: UINavigationController
    }

    private let dependency: Dependency

    init(dependency: Dependency) {
        self.dependency = dependency
    }

    func toMain() {
        let viewController = dependency.resolver.resolveVideoViewController(navigator: self)
        dependency.navigationController.pushViewController(viewController, animated: true)
    }
}
