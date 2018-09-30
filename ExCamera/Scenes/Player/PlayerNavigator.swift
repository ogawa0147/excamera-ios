import UIKit

protocol PlayerNavigator: NavigatorType {}

class DefaultPlayerNavigator: PlayerNavigator {
    internal let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
}
