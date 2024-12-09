import UIKit

@UIApplicationMain
class DNAppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var bridge: DNBridge?

    func application(_ application: UIApplication,
                    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        let rootViewController = DNRootViewController()
        window?.rootViewController = rootViewController
        window?.makeKeyAndVisible()

        bridge = DNBridge(rootViewController: rootViewController)
        return true
    }
}
