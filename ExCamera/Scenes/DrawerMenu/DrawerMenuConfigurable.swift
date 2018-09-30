import UIKit

protocol DrawerMenuConfigurable: NavigatorType {
    func configureDrawerMenu(viewController: DrawerMenuShowable)
}

extension DrawerMenuConfigurable {
    func configureDrawerMenu(viewController: DrawerMenuShowable) {
        let drawerMenuController = R.storyboard.drawerMenuViewController.drawerMenuViewController()!
        viewController.drawerMenuController = drawerMenuController
        viewController.addChildViewController(drawerMenuController)
        viewController.view.addSubview(drawerMenuController.view)
        drawerMenuController.didMove(toParent: viewController.viewController())
        drawerMenuController.view.bringSubviewToFront(viewController.navigationController!.view)
    }
}
