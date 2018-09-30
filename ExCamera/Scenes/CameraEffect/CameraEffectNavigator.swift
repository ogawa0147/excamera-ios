import UIKit

protocol CameraEffectNavigator: PlayerPresentable {}

class DefaultCameraEffectNavigator: CameraEffectNavigator {
    internal let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
}
