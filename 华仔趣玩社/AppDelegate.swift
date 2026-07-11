import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        UIApplication.shared.isIdleTimerDisabled = true
        
        if UserDefaults.standard.string(forKey: "agnes_api_key")?.isEmpty ?? true {
            UserDefaults.standard.set("sk-C7SNm9gXYgUUxA6jlgB2iIve2lMbdeopLu4cQz56685iA8eX", forKey: "agnes_api_key")
        }
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let tabBarController = MainTabBarController()
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
        
        return true
    }
}
