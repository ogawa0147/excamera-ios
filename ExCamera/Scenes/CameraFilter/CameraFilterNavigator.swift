import UIKit

protocol CameraFilterNavigator: PlayerPresentable {}

class DefaultCameraFilterNavigator: CameraFilterNavigator {
    internal let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
}
