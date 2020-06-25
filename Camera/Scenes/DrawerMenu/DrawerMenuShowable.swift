import UIKit

protocol DrawerMenuShowable: class {
    var drawerMenuController: DrawerMenuViewController! { get set }
    var view: UIView! { get set }
    var navigationController: UINavigationController? { get }
    func addChildViewController(_ childController: UIViewController)
    func viewController() -> UIViewController
}
