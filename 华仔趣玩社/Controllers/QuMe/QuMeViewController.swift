import UIKit

class QuMeViewController: UIViewController {
    
    private let menuItems: [(String, String, Bool)] = [
        ("个人信息", "👤", true),
        ("我的收藏", "⭐", true),
        ("使用历史", "📋", true),
        ("系统设置", "⚙️", true),
        ("检查更新", "🔄", true),
        ("帮助与反馈", "💬", true),
        ("关于华仔趣玩社", "ℹ️", true)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = Theme.gradientTop
        
        let headerView = UIView()
        headerView.backgroundColor = Theme.cardBackground.withAlphaComponent(0.6)
        headerView.layer.cornerRadius = Theme.cardCornerRadius
        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)
        
        let avatarView = UIView()
        avatarView.backgroundColor = Theme.electricBlue
        avatarView.layer.cornerRadius = 40
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(avatarView)
        
        let avatarLabel = UILabel()
        avatarLabel.text = "华"
        avatarLabel.font = Theme.Font.bold(size: 28)
        avatarLabel.textColor = Theme.brightWhite
        avatarLabel.textAlignment = .center
        avatarLabel.translatesAutoresizingMaskIntoConstraints = false
        avatarView.addSubview(avatarLabel)
        
        NSLayoutConstraint.activate([
            avatarLabel.centerXAnchor.constraint(equalTo: avatarView.centerXAnchor),
            avatarLabel.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor)
        ])
        
        let nameLabel = UILabel()
        nameLabel.text = "华仔趣玩社用户"
        nameLabel.font = Theme.Font.bold(size: 20)
        nameLabel.textColor = Theme.brightWhite
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(nameLabel)
        
        let descLabel = UILabel()
        descLabel.text = "欢迎来到趣玩世界"
        descLabel.font = Theme.Font.regular(size: 14)
        descLabel.textColor = Theme.mutedGray
        descLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(descLabel)
        
        NSLayoutConstraint.activate([
            avatarView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 24),
            avatarView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            avatarView.widthAnchor.constraint(equalToConstant: 80),
            avatarView.heightAnchor.constraint(equalToConstant: 80),
            
            nameLabel.topAnchor.constraint(equalTo: avatarView.bottomAnchor, constant: 16),
            nameLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            
            descLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            descLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            descLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -24)
        ])
        
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        let menuStack = UIStackView()
        menuStack.axis = .vertical
        menuStack.spacing = 12
        menuStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(menuStack)
        
        for (index, item) in menuItems.enumerated() {
            let menuItem = createMenuItem(title: item.0, icon: item.1, enabled: item.2, index: index)
            menuStack.addArrangedSubview(menuItem)
        }
        
        NSLayoutConstraint.activate([
            menuStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            menuStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            menuStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            menuStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40),
            menuStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20)
        ])
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            scrollView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 16),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        title = "趣我"
    }
    
    private func createMenuItem(title: String, icon: String, enabled: Bool, index: Int) -> UIView {
        let card = UIView()
        card.backgroundColor = enabled ? Theme.cardBackground.withAlphaComponent(0.6) : Theme.cardBackground.withAlphaComponent(0.3)
        card.layer.cornerRadius = 12
        card.translatesAutoresizingMaskIntoConstraints = false
        
        let iconLabel = UILabel()
        iconLabel.text = icon
        iconLabel.font = UIFont.systemFont(ofSize: 24)
        iconLabel.textAlignment = .center
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(iconLabel)
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = Theme.Font.bold(size: 16)
        titleLabel.textColor = enabled ? Theme.brightWhite : Theme.mutedGray
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(titleLabel)
        
        let arrowLabel = UILabel()
        arrowLabel.text = "›"
        arrowLabel.font = Theme.Font.bold(size: 20)
        arrowLabel.textColor = enabled ? Theme.electricBlue : Theme.mutedGray
        arrowLabel.textAlignment = .right
        arrowLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(arrowLabel)
        
        if enabled {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(menuItemTapped(_:)))
            card.addGestureRecognizer(tapGesture)
            card.isUserInteractionEnabled = true
            card.tag = index
        }
        
        NSLayoutConstraint.activate([
            card.heightAnchor.constraint(equalToConstant: 60),
            
            iconLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            iconLabel.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            iconLabel.widthAnchor.constraint(equalToConstant: 30),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: 12),
            titleLabel.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            
            arrowLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            arrowLabel.centerYAnchor.constraint(equalTo: card.centerYAnchor)
        ])
        
        return card
    }
    
    @objc private func menuItemTapped(_ gesture: UITapGestureRecognizer) {
        guard let index = gesture.view?.tag else { return }
        
        let item = menuItems[index]
        
        switch index {
        case 0:
            showAlert(title: item.0, message: "个人信息功能开发中")
        case 1:
            showAlert(title: item.0, message: "我的收藏功能开发中")
        case 2:
            showAlert(title: item.0, message: "使用历史功能开发中")
        case 3:
            showAlert(title: item.0, message: "系统设置功能开发中")
        case 4:
            showAlert(title: item.0, message: "当前已是最新版本 v1.0.0")
        case 5:
            showAlert(title: item.0, message: "帮助与反馈功能开发中")
        case 6:
            showAbout()
        default:
            break
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "好的", style: .default))
        present(alert, animated: true)
    }
    
    private func showAbout() {
        let alert = UIAlertController(
            title: "关于华仔趣玩社",
            message: """
            版本: 1.0.0
            适配: iPad Air 1代 (iOS 12+)
            
            一款专为iPad打造的工具箱应用
            趣看 · 趣玩 · 趣速 · 趣搜索
            
            © 2026 华仔趣玩社
            """,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "好的", style: .default))
        present(alert, animated: true)
    }
}
