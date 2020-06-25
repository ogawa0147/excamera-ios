import UIKit
import Firebase
import FirebaseCrashlytics
import Environments
import Logger

final class Application {

    static let shared = Application()
    private let appResolver = AppResolverImpl()

    private init() {
        #if DEVELOPMENT
        Environments.shared.setEnviroment(.development)
        LogConfigure.shared.enable()
        #else
        Environments.shared.setEnviroment(.production)
        LogConfigure.shared.disable()
        #endif
    }

    func makeLaunchWindow(_ window: UIWindow?) {
        let navigationController = UINavigationController()
        let navigator = appResolver.resolveTopPageNavigatorImpl(navigationController: navigationController)
        navigator.toMain()
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }

    func configureFirebaseApp() {
        let options = FirebaseOptions(contentsOfFile: Constants.GoogleService.plistPath)!
        FirebaseApp.configure(options: options)
    }

    func configureAppearance() {
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        UINavigationBar.appearance().shadowImage = UIImage()
    }
}
