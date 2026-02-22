import UIKit

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
        setupViewControllers()
    }
    
    private func setupAppearance() {
        let gradientBg = GradientBackgroundView(frame: view.bounds)
        view.insertSubview(gradientBg, at: 0)
        
        tabBar.barTintColor = Theme.cardBackground.withAlphaComponent(0.9)
        tabBar.tintColor = Theme.electricBlue
        tabBar.isTranslucent = true
        tabBar.layer.borderWidth = 0.5
        tabBar.layer.borderColor = Theme.neonPink.withAlphaComponent(0.3).cgColor
        
        if #available(iOS 13.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithTransparentBackground()
            appearance.backgroundColor = Theme.cardBackground.withAlphaComponent(0.9)
            appearance.stackedLayoutAppearance.selected.iconColor = Theme.electricBlue
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
                .foregroundColor: Theme.electricBlue
            ]
            appearance.stackedLayoutAppearance.normal.iconColor = Theme.mutedGray
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                .foregroundColor: Theme.mutedGray
            ]
            tabBar.standardAppearance = appearance
            if #available(iOS 15.0, *) {
                tabBar.scrollEdgeAppearance = appearance
            }
        }
        
        if #available(iOS 13.0, *) {
            let navAppearance = UINavigationBarAppearance()
            navAppearance.configureWithTransparentBackground()
            navAppearance.backgroundColor = UIColor.clear
            navAppearance.titleTextAttributes = [
                .foregroundColor: Theme.brightWhite,
                .font: Theme.Font.bold(size: 18)
            ]
            navAppearance.largeTitleTextAttributes = [
                .foregroundColor: Theme.brightWhite,
                .font: Theme.Font.bold(size: 34)
            ]
            UINavigationBar.appearance().standardAppearance = navAppearance
            UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
        } else {
            UINavigationBar.appearance().isTranslucent = true
            UINavigationBar.appearance().titleTextAttributes = [
                .foregroundColor: Theme.brightWhite,
                .font: Theme.Font.bold(size: 18)
            ]
        }
        UINavigationBar.appearance().tintColor = Theme.electricBlue
    }
    
    private func setupViewControllers() {
        let quKan = UINavigationController(rootViewController: QuKanViewController())
        quKan.tabBarItem = UITabBarItem(title: "趣看", image: nil, tag: 0)
        
        let quWan = UINavigationController(rootViewController: QuWanViewController())
        quWan.tabBarItem = UITabBarItem(title: "趣玩", image: nil, tag: 1)
        
        let aiTools = UINavigationController(rootViewController: AIToolsViewController())
        aiTools.tabBarItem = UITabBarItem(title: "AI", image: nil, tag: 2)
        
        let quZuo = UINavigationController(rootViewController: QuZuoViewController())
        quZuo.tabBarItem = UITabBarItem(title: "趣做", image: nil, tag: 3)
        
        let quDu = UINavigationController(rootViewController: QuDuViewController())
        quDu.tabBarItem = UITabBarItem(title: "趣读", image: nil, tag: 4)
        
        viewControllers = [quKan, quWan, aiTools, quZuo, quDu]
    }
}
