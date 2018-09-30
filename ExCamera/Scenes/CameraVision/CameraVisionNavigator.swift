import UIKit

protocol CameraVisionNavigator: PlayerPresentable {}

class DefaultCameraVisionNavigator: CameraVisionNavigator {
    internal let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
}
