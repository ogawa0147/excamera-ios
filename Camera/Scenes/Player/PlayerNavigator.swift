import UIKit
import DIKit

protocol PlayerNavigator {
    func toMain(url: URL, animated: Bool)
}

final class PlayerNavigatorImpl: PlayerNavigator, Injectable {
    struct Dependency: NavigatorType {
        let resolver: AppResolver
        let navigationController: UINavigationController
    }

    private let dependency: Dependency

    init(dependency: Dependency) {
        self.dependency = dependency
    }

    func toMain(url: URL, animated: Bool) {
        let viewController = dependency.resolver.resolvePlayerViewController(navigator: self, url: url)
        let navigationController = UINavigationController(rootViewController: viewController)
        dependency.navigationController.present(navigationController, animated: animated, completion: nil)
    }
}
