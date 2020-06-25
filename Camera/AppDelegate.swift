import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    override init() {
        super.init()
    }

    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        return true
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Application.shared.configureAppearance()
        Application.shared.configureFirebaseApp()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        Application.shared.makeLaunchWindow(window)
    }

    // is called when a scene has been disconnected from the app (Note that it can reconnect later on.)
    func sceneDidDisconnect(_ scene: UIScene) {
    }

    // is called when the user starts interacting with a scene, such as selecting it from the app switcher
    func sceneDidBecomeActive(_ scene: UIScene) {
    }

    // is called when the user stops interacting with a scene, for example by switching to another scene
    func sceneWillResignActive(_ scene: UIScene) {
    }

    // is called when a scene enters the foreground, i.e. starts or resumes from a background state
    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    // is called when a scene enters the background, i.e. the app is minimized but still present in the background
    func sceneDidEnterBackground(_ scene: UIScene) {
    }
}
