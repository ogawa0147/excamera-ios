import UIKit
import DIKit

protocol YoutubePlayerNavigator {
    func toMain()
}

final class YoutubePlayerNavigatorImpl: YoutubePlayerNavigator, Injectable {
    struct Dependency: NavigatorType {
        let resolver: AppResolver
        let navigationController: UINavigationController
    }

    private let dependency: Dependency

    init(dependency: Dependency) {
        self.dependency = dependency
    }

    func toMain() {
        let viewController = dependency.resolver.resolveYoutubePlayerViewController(navigator: self)
        dependency.navigationController.pushViewController(viewController, animated: true)
    }
}
