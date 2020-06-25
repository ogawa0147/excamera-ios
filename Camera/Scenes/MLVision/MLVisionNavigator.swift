import UIKit
import DIKit

protocol MLVisionNavigator {
    func toMain()
}

final class MLVisionNavigatorImpl: MLVisionNavigator, Injectable {
    struct Dependency: NavigatorType {
        let resolver: AppResolver
        let navigationController: UINavigationController
    }

    private let dependency: Dependency

    init(dependency: Dependency) {
        self.dependency = dependency
    }

    func toMain() {
        let viewController = dependency.resolver.resolveMLVisionViewController(navigator: self)
        dependency.navigationController.pushViewController(viewController, animated: true)
    }
}
