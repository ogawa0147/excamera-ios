import UIKit
import DIKit

protocol TopPageNavigator {
    func toMain()
    func toCameraGif()
    func toCameraEffect()
    func toCameraFilter()
    func toCameraVision()
    func toARCamera()
    func toWallPaper()
}

final class TopPageNavigatorImpl: TopPageNavigator, Injectable {
    struct Dependency: NavigatorType {
        let resolver: AppResolver
        let navigationController: UINavigationController
    }

    private let dependency: Dependency

    init(dependency: Dependency) {
        self.dependency = dependency
    }

    func toMain() {
        let viewController = dependency.resolver.resolveTopPageViewController(navigator: self)
        dependency.navigationController.pushViewController(viewController, animated: true)
    }

    func toCameraGif() {
        let navigator = dependency.resolver.resolveCameraGifNavigatorImpl(navigationController: dependency.navigationController)
        navigator.toMain()
    }

    func toCameraEffect() {
        let navigator = dependency.resolver.resolveCameraEffectNavigatorImpl(navigationController: dependency.navigationController)
        navigator.toMain()
    }

    func toCameraFilter() {
        let navigator = dependency.resolver.resolveCameraFilterNavigatorImpl(navigationController: dependency.navigationController)
        navigator.toMain()
    }

    func toCameraVision() {
        let navigator = dependency.resolver.resolveCameraVisionNavigatorImpl(navigationController: dependency.navigationController)
        navigator.toMain()
    }

    func toARCamera() {
        let navigator = dependency.resolver.resolveARCameraNavigatorImpl(navigationController: dependency.navigationController)
        navigator.toMain()
    }

    func toWallPaper() {
        let navigator = dependency.resolver.resolveWallPaperNavigatorImpl(navigationController: dependency.navigationController)
        navigator.toMain()
    }
}
