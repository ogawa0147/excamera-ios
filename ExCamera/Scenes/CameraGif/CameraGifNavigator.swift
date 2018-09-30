import UIKit

protocol CameraGifNavigator: PlayerPresentable {}

class DefaultCameraGifNavigator: CameraGifNavigator {
    internal let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
}
