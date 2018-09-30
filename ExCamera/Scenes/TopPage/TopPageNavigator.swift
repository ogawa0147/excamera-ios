import UIKit

protocol TopPageNavigator: NavigatorType {
    func toTopPage()
    func toCameraGif()
    func toCameraEffect()
    func toCameraFilter()
    func toCameraVision()
    func toARCamera()
    func toWallPaper()
}

class DefaultTopPageNavigator: TopPageNavigator {
    internal let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func toTopPage() {
        let viewController = R.storyboard.topPageViewController.topPageViewController()!
        viewController.viewModel = TopPageViewModel(navigator: self)
        navigationController.pushViewController(viewController, animated: true)
    }

    func toCameraGif() {
        let navigator = DefaultCameraGifNavigator(navigationController: navigationController)
        let viewController = R.storyboard.cameraGifViewController.cameraGifViewController()!
        viewController.viewModel = CameraGifViewModel(navigator: navigator)
        navigationController.pushViewController(viewController, animated: true)
    }

    func toCameraEffect() {
        let navigator = DefaultCameraEffectNavigator(navigationController: navigationController)
        let viewController = R.storyboard.cameraEffectViewController.cameraEffectViewController()!
        viewController.viewModel = CameraEffectViewModel(navigator: navigator)
        navigationController.pushViewController(viewController, animated: true)
    }

    func toCameraFilter() {
        let navigator = DefaultCameraFilterNavigator(navigationController: navigationController)
        let viewController = R.storyboard.cameraFilterViewController.cameraFilterViewController()!
        viewController.viewModel = CameraFilterViewModel(navigator: navigator)
        navigationController.pushViewController(viewController, animated: true)
    }

    func toCameraVision() {
        let navigator = DefaultCameraVisionNavigator(navigationController: navigationController)
        let viewController = R.storyboard.cameraVisionViewController.cameraVisionViewController()!
        viewController.viewModel = CameraVisionViewModel(navigator: navigator)
        navigationController.pushViewController(viewController, animated: true)
    }

    func toARCamera() {
        let navigator = DefaultARCameraNavigator(navigationController: navigationController)
        let viewController = R.storyboard.arCameraViewController.arCameraViewController()!
        viewController.viewModel = ARCameraViewModel(navigator: navigator)
        navigationController.pushViewController(viewController, animated: true)
    }

    func toWallPaper() {
        let navigator = DefaultWallPaperNavigator(navigationController: navigationController)
        let viewController = R.storyboard.wallPaperViewController.wallPaperViewController()!
        viewController.viewModel = WallPaperViewModel(navigator: navigator)
        navigationController.pushViewController(viewController, animated: true)
    }
}
