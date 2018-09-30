import UIKit

protocol PlayerPresentable: NavigatorType {
    func toPlayer(url: URL, animated: Bool)
}

extension PlayerPresentable {
    func toPlayer(url: URL, animated: Bool) {
        let viewController = R.storyboard.playerViewController.playerViewController()!
        let navigationController = UINavigationController(rootViewController: viewController)
        let navigator = DefaultPlayerNavigator(navigationController: navigationController)
        viewController.viewModel = PlayerViewModel(navigator: navigator, url: url)
        self.navigationController.present(navigationController, animated: animated, completion: nil)
    }
}
