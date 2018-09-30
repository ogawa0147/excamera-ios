import UIKit

protocol WallPaperNavigator: NavigatorType {
    func toPlayer(url: URL, animated: Bool)
}

class DefaultWallPaperNavigator: WallPaperNavigator {
    internal let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func toPlayer(url: URL, animated: Bool) {
        let viewController = R.storyboard.playerViewController.playerViewController()!
        let navigationController = UINavigationController(rootViewController: viewController)
        let navigator = DefaultPlayerNavigator(navigationController: navigationController)
        viewController.viewModel = PlayerViewModel(navigator: navigator, url: url)
        self.navigationController.present(navigationController, animated: animated, completion: nil)
    }
}
