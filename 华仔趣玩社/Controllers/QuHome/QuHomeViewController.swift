import UIKit

class QuHomeViewController: UIViewController {
    
    private var recentItems: [(String, String, String, UIColor)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadRecentItems()
        setupUI()
    }
    
    private func loadRecentItems() {
        recentItems = [
            ("趣看趣读", "KK影视", "🎬", UIColor(hex: "E74C3C")),
            ("趣玩", "宝贝画板", "🎨", UIColor(hex: "A855F7")),
            ("趣玩", "4399小游戏", "🎮", UIColor(hex: "3498DB")),
            ("趣看趣读", "番茄小说", "📚", UIColor(hex: "FF5722")),
            ("趣玩", "贪吃蛇", "🐍", UIColor(hex: "27AE60")),
            ("AI工具", "豆包AI", "🤖", UIColor(hex: "00D4AA"))
        ]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func setupUI() {
        let gradientBg = GradientBackgroundView(frame: view.bounds)
        gradientBg.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(gradientBg)
        
        let titleLabel = UILabel()
        titleLabel.text = "趣首页"
        titleLabel.font = Theme.Font.bold(size: 32)
        titleLabel.textColor = Theme.brightWhite
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = "智能推荐 · 常用功能"
        subtitleLabel.font = Theme.Font.regular(size: 14)
        subtitleLabel.textColor = Theme.mutedGray
        subtitleLabel.textAlignment = .center
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(subtitleLabel)
        
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)
        
        let categories = ["趣看趣读", "趣玩", "AI工具", "趣办", "趣家", "趣学"]
        for category in categories {
            let categoryItems = recentItems.filter { $0.0 == category }
            if !categoryItems.isEmpty {
                let sectionView = createSectionView(title: category, items: categoryItems)
                stackView.addArrangedSubview(sectionView)
            }
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            scrollView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 20),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20)
        ])
        
        title = "趣首页"
    }
    
    private func createSectionView(title: String, items: [(String, String, String, UIColor)]) -> UIView {
        let container = UIView()
        container.backgroundColor = Theme.cardBackground.withAlphaComponent(0.6)
        container.layer.cornerRadius = Theme.cardCornerRadius
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = Theme.Font.bold(size: 20)
        titleLabel.textColor = Theme.brightWhite
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(titleLabel)
        
        let itemStack = UIStackView()
        itemStack.axis = .horizontal
        itemStack.spacing = 12
        itemStack.distribution = .fillEqually
        itemStack.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(itemStack)
        
        for item in items {
            let itemView = createItemView(name: item.1, icon: item.2, color: item.3)
            itemStack.addArrangedSubview(itemView)
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            
            itemStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            itemStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            itemStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            itemStack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16)
        ])
        
        return container
    }
    
    private func createItemView(name: String, icon: String, color: UIColor) -> UIView {
        let view = UIView()
        view.backgroundColor = Theme.gradientTop.withAlphaComponent(0.5)
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        view.layer.borderColor = color.withAlphaComponent(0.3).cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let iconLabel = UILabel()
        iconLabel.text = icon
        iconLabel.font = UIFont.systemFont(ofSize: 28)
        iconLabel.textAlignment = .center
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(iconLabel)
        
        let nameLabel = UILabel()
        nameLabel.text = name
        nameLabel.font = Theme.Font.regular(size: 12)
        nameLabel.textColor = Theme.brightWhite
        nameLabel.textAlignment = .center
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 80),
            
            iconLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            iconLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            nameLabel.topAnchor.constraint(equalTo: iconLabel.bottomAnchor, constant: 4),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 4),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -4)
        ])
        
        return view
    }
}
