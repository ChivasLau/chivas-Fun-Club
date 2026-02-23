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
        let quHome = UINavigationController(rootViewController: QuHomeViewController())
        quHome.tabBarItem = UITabBarItem(title: "趣首页", image: nil, tag: 0)
        
        let quCategory = UINavigationController(rootViewController: QuCategoryViewController())
        quCategory.tabBarItem = UITabBarItem(title: "趣分类", image: nil, tag: 1)
        
        let quSearch = UINavigationController(rootViewController: QuSearchViewController())
        quSearch.tabBarItem = UITabBarItem(title: "趣搜索", image: nil, tag: 2)
        
        let quMe = UINavigationController(rootViewController: QuMeViewController())
        quMe.tabBarItem = UITabBarItem(title: "趣我", image: nil, tag: 3)
        
        viewControllers = [quHome, quCategory, quSearch, quMe]
    }
}
