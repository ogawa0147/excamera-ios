import UIKit
import DIKit

protocol ARCameraNavigator {
    func toMain()
}

final class ARCameraNavigatorImpl: ARCameraNavigator, Injectable {
    struct Dependency: NavigatorType {
        let resolver: AppResolver
        let navigationController: UINavigationController
    }

    private let dependency: Dependency

    init(dependency: Dependency) {
        self.dependency = dependency
    }

    func toMain() {
        let viewController = dependency.resolver.resolveARCameraViewController(navigator: self)
        dependency.navigationController.pushViewController(viewController, animated: true)
    }
}
