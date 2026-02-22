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
        tabBar.unselectedItemTintColor = Theme.mutedGray
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
    }
    
    private func setupViewControllers() {
        let quKan = UINavigationController(rootViewController: QuKanViewController())
        quKan.tabBarItem = UITabBarItem(
            title: "趣看",
            image: UIImage(named: "tab_qukan"),
            selectedImage: UIImage(named: "tab_qukan_selected")
        )
        if quKan.tabBarItem.image == nil {
            quKan.tabBarItem = UITabBarItem(title: "趣看", image: nil, tag: 0)
            quKan.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        }
        
        let quWan = UINavigationController(rootViewController: QuWanViewController())
        quWan.tabBarItem = UITabBarItem(title: "趣玩", image: nil, tag: 1)
        
        let quZuo = UINavigationController(rootViewController: QuZuoViewController())
        quZuo.tabBarItem = UITabBarItem(title: "趣做", image: nil, tag: 2)
        
        let quDu = UINavigationController(rootViewController: QuDuViewController())
        quDu.tabBarItem = UITabBarItem(title: "趣读", image: nil, tag: 3)
        
        viewControllers = [quKan, quWan, quZuo, quDu]
        
        setupNavigationBarAppearance()
    }
    
    private func setupNavigationBarAppearance() {
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
        UINavigationBar.appearance().tintColor = Theme.electricBlue
    }
}
