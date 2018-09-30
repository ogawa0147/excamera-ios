import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        Application.shared.configureFabric()
        Application.shared.configureAppearance()
        Application.shared.configureMainInterface(in: window)
        self.window = window
        return true
    }
}
