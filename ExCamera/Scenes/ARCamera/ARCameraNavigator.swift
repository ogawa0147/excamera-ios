import UIKit

protocol ARCameraNavigator: NavigatorType {}

class DefaultARCameraNavigator: ARCameraNavigator {
    internal let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
}
