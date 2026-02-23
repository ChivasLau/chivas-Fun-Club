import UIKit

struct UsageItem: Codable {
    let category: String
    let name: String
    let icon: String
    let colorHex: String
    let action: String
    var usageCount: Int
    var lastUsed: Date
    
    var color: UIColor {
        return UIColor(hex: colorHex)
    }
}

class UsageTracker {
    static let shared = UsageTracker()
    private let usageKey = "usage_history"
    
    private var items: [UsageItem] = []
    
    init() {
        loadUsageData()
    }
    
    func recordUsage(category: String, name: String, icon: String, colorHex: String, action: String) {
        if let index = items.firstIndex(where: { $0.category == category && $0.name == name }) {
            items[index].usageCount += 1
            items[index].lastUsed = Date()
        } else {
            let item = UsageItem(
                category: category,
                name: name,
                icon: icon,
                colorHex: colorHex,
                action: action,
                usageCount: 1,
                lastUsed: Date()
            )
            items.append(item)
        }
        saveUsageData()
    }
    
    func getRecentItems(limit: Int = 10) -> [UsageItem] {
        return items
            .sorted { $0.lastUsed > $1.lastUsed }
            .prefix(limit)
            .map { $0 }
    }
    
    func getFrequentItems(limit: Int = 10) -> [UsageItem] {
        return items
            .sorted { $0.usageCount > $1.usageCount }
            .prefix(limit)
            .map { $0 }
    }
    
    func getItemsByCategory(_ category: String, limit: Int = 5) -> [UsageItem] {
        return items
            .filter { $0.category == category }
            .sorted { $0.usageCount > $1.usageCount }
            .prefix(limit)
            .map { $0 }
    }
    
    func hasUsageData() -> Bool {
        return !items.isEmpty
    }
    
    func clearAll() {
        items.removeAll()
        saveUsageData()
    }
    
    private func saveUsageData() {
        if let data = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(data, forKey: usageKey)
        }
    }
    
    private func loadUsageData() {
        guard let data = UserDefaults.standard.data(forKey: usageKey),
              let savedItems = try? JSONDecoder().decode([UsageItem].self, from: data) else {
            items = []
            return
        }
        items = savedItems
    }
}

class QuHomeViewController: UIViewController {
    
    private var scrollView: UIScrollView!
    private var contentStack: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refreshContent()
    }
    
    override var prefersStatusBarHidden: Bool { return true }
    override var prefersHomeIndicatorAutoHidden: Bool { return false }
    
    private func setupUI() {
        let gradientBg = GradientBackgroundView(frame: view.bounds)
        gradientBg.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(gradientBg)
        
        let headerStack = UIStackView()
        headerStack.axis = .vertical
        headerStack.spacing = 4
        headerStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerStack)
        
        let titleLabel = UILabel()
        titleLabel.text = "🏠 趣首页"
        titleLabel.font = Theme.Font.bold(size: 32)
        titleLabel.textColor = Theme.brightWhite
        titleLabel.textAlignment = .center
        headerStack.addArrangedSubview(titleLabel)
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = "你的使用习惯，智能记录"
        subtitleLabel.font = Theme.Font.regular(size: 14)
        subtitleLabel.textColor = Theme.mutedGray
        subtitleLabel.textAlignment = .center
        headerStack.addArrangedSubview(subtitleLabel)
        
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        contentStack = UIStackView()
        contentStack.axis = .vertical
        contentStack.spacing = 20
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)
        
        let tipView = UIView()
        tipView.backgroundColor = Theme.cardBackground.withAlphaComponent(0.4)
        tipView.layer.cornerRadius = 12
        tipView.translatesAutoresizingMaskIntoConstraints = false
        tipView.tag = 999
        
        let tipLabel = UILabel()
        tipLabel.text = "💡 使用应用后，常用的功能会自动出现在这里"
        tipLabel.font = Theme.Font.regular(size: 14)
        tipLabel.textColor = Theme.mutedGray
        tipLabel.textAlignment = .center
        tipLabel.translatesAutoresizingMaskIntoConstraints = false
        tipView.addSubview(tipLabel)
        
        NSLayoutConstraint.activate([
            tipLabel.topAnchor.constraint(equalTo: tipView.topAnchor, constant: 16),
            tipLabel.leadingAnchor.constraint(equalTo: tipView.leadingAnchor, constant: 16),
            tipLabel.trailingAnchor.constraint(equalTo: tipView.trailingAnchor, constant: -16),
            tipLabel.bottomAnchor.constraint(equalTo: tipView.bottomAnchor, constant: -16)
        ])
        
        contentStack.addArrangedSubview(tipView)
        
        NSLayoutConstraint.activate([
            headerStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            headerStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            scrollView.topAnchor.constraint(equalTo: headerStack.bottomAnchor, constant: 16),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20)
        ])
        
        title = "趣首页"
    }
    
    private func refreshContent() {
        for subview in contentStack.arrangedSubviews {
            if subview.tag != 999 {
                subview.removeFromSuperview()
            }
        }
        
        let hasData = UsageTracker.shared.hasUsageData()
        if let tipView = contentStack.viewWithTag(999) {
            tipView.isHidden = hasData
        }
        
        if !hasData {
            addQuickStartSection()
            return
        }
        
        let recentItems = UsageTracker.shared.getRecentItems(limit: 6)
        if !recentItems.isEmpty {
            let section = createItemSection(
                title: "⏰ 最近使用",
                items: recentItems,
                showCategory: true
            )
            contentStack.addArrangedSubview(section)
        }
        
        let frequentItems = UsageTracker.shared.getFrequentItems(limit: 8)
        if !frequentItems.isEmpty {
            let section = createItemSection(
                title: "🔥 常用功能",
                items: frequentItems,
                showCategory: true
            )
            contentStack.addArrangedSubview(section)
        }
        
        let categories = ["趣看趣读", "趣玩", "趣办", "趣学"]
        for category in categories {
            let categoryItems = UsageTracker.shared.getItemsByCategory(category, limit: 4)
            if !categoryItems.isEmpty {
                let section = createItemSection(
                    title: getCategoryTitle(category),
                    items: categoryItems,
                    showCategory: false
                )
                contentStack.addArrangedSubview(section)
            }
        }
    }
    
    private func addQuickStartSection() {
        let section = createQuickStartSection()
        contentStack.addArrangedSubview(section)
    }
    
    private func getCategoryTitle(_ category: String) -> String {
        switch category {
        case "趣看趣读": return "📺 趣看趣读"
        case "趣玩": return "🎮 趣玩"
        case "趣办": return "🤖 趣办"
        case "趣学": return "📚 趣学"
        default: return category
        }
    }
    
    private func createItemSection(title: String, items: [UsageItem], showCategory: Bool) -> UIView {
        let container = UIView()
        container.backgroundColor = Theme.cardBackground.withAlphaComponent(0.6)
        container.layer.cornerRadius = Theme.cardCornerRadius
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = Theme.Font.bold(size: 18)
        titleLabel.textColor = Theme.brightWhite
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(titleLabel)
        
        let gridStack = UIStackView()
        gridStack.axis = .horizontal
        gridStack.spacing = 12
        gridStack.distribution = .fillEqually
        gridStack.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(gridStack)
        
        for item in items {
            let itemView = createClickableItem(item: item, showCategory: showCategory)
            gridStack.addArrangedSubview(itemView)
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            
            gridStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            gridStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            gridStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            gridStack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16),
            gridStack.heightAnchor.constraint(greaterThanOrEqualToConstant: 90)
        ])
        
        return container
    }
    
    private func createClickableItem(item: UsageItem, showCategory: Bool) -> UIView {
        let view = UIView()
        view.backgroundColor = Theme.gradientTop.withAlphaComponent(0.5)
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 2
        view.layer.borderColor = item.color.withAlphaComponent(0.4).cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(itemTapped(_:)))
        view.addGestureRecognizer(tapGesture)
        view.isUserInteractionEnabled = true
        view.tag = contentStack.arrangedSubviews.count
        
        let iconLabel = UILabel()
        iconLabel.text = item.icon
        iconLabel.font = UIFont.systemFont(ofSize: 32)
        iconLabel.textAlignment = .center
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(iconLabel)
        
        let nameLabel = UILabel()
        nameLabel.text = item.name
        nameLabel.font = Theme.Font.bold(size: 12)
        nameLabel.textColor = Theme.brightWhite
        nameLabel.textAlignment = .center
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        
        if showCategory {
            let categoryLabel = UILabel()
            categoryLabel.text = item.category
            categoryLabel.font = Theme.Font.regular(size: 10)
            categoryLabel.textColor = item.color
            categoryLabel.textAlignment = .center
            categoryLabel.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(categoryLabel)
            
            NSLayoutConstraint.activate([
                iconLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
                iconLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                
                nameLabel.topAnchor.constraint(equalTo: iconLabel.bottomAnchor, constant: 4),
                nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                
                categoryLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2),
                categoryLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                categoryLabel.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -8)
            ])
        } else {
            NSLayoutConstraint.activate([
                iconLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 12),
                iconLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                
                nameLabel.topAnchor.constraint(equalTo: iconLabel.bottomAnchor, constant: 6),
                nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                nameLabel.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -12)
            ])
        }
        
        view.accessibilityLabel = item.action
        view.accessibilityHint = "\(item.category)|\(item.name)|\(item.icon)|\(item.colorHex)"
        
        return view
    }
    
    private func createQuickStartSection() -> UIView {
        let container = UIView()
        container.backgroundColor = Theme.cardBackground.withAlphaComponent(0.6)
        container.layer.cornerRadius = Theme.cardCornerRadius
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = "🚀 快速开始"
        titleLabel.font = Theme.Font.bold(size: 18)
        titleLabel.textColor = Theme.brightWhite
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(titleLabel)
        
        let descLabel = UILabel()
        descLabel.text = "点击下方分类开始探索"
        descLabel.font = Theme.Font.regular(size: 14)
        descLabel.textColor = Theme.mutedGray
        descLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(descLabel)
        
        let buttonStack = UIStackView()
        buttonStack.axis = .horizontal
        buttonStack.spacing = 12
        buttonStack.distribution = .fillEqually
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(buttonStack)
        
        let quickItems: [(String, String, UIColor, String)] = [
            ("📺 趣看趣读", "视频小说", UIColor(hex: "E74C3C"), "qukan"),
            ("🎮 趣玩", "游戏画板", UIColor(hex: "A855F7"), "quwan"),
            ("🤖 趣办", "AI工具", UIColor(hex: "00D4AA"), "quban"),
            ("📚 趣学", "幼儿启蒙", UIColor(hex: "4ECDC4"), "qulearn")
        ]
        
        for item in quickItems {
            let btn = UIButton(type: .system)
            btn.setTitle(item.0, for: .normal)
            btn.titleLabel?.font = Theme.Font.bold(size: 14)
            btn.setTitleColor(item.2, for: .normal)
            btn.backgroundColor = item.2.withAlphaComponent(0.2)
            btn.layer.cornerRadius = 12
            btn.layer.borderWidth = 2
            btn.layer.borderColor = item.2.withAlphaComponent(0.5).cgColor
            btn.translatesAutoresizingMaskIntoConstraints = false
            btn.addTarget(self, action: #selector(quickStartTapped(_:)), for: .touchUpInside)
            btn.accessibilityLabel = item.3
            buttonStack.addArrangedSubview(btn)
            
            NSLayoutConstraint.activate([
                btn.heightAnchor.constraint(equalToConstant: 60)
            ])
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            
            descLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            descLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            
            buttonStack.topAnchor.constraint(equalTo: descLabel.bottomAnchor, constant: 16),
            buttonStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            buttonStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            buttonStack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16)
        ])
        
        return container
    }
    
    @objc private func itemTapped(_ gesture: UITapGestureRecognizer) {
        guard let view = gesture.view,
              let action = view.accessibilityLabel,
              let hint = view.accessibilityHint else { return }
        
        let parts = hint.split(separator: "|").map { String($0) }
        guard parts.count >= 4 else { return }
        
        let category = parts[0]
        let name = parts[1]
        let icon = parts[2]
        let colorHex = parts[3]
        
        UsageTracker.shared.recordUsage(
            category: category,
            name: name,
            icon: icon,
            colorHex: colorHex,
            action: action
        )
        
        handleAction(action)
    }
    
    @objc private func quickStartTapped(_ sender: UIButton) {
        guard let action = sender.accessibilityLabel else { return }
        handleAction(action)
    }
    
    private func handleAction(_ action: String) {
        let vc: UIViewController?
        
        if action.hasPrefix("http") {
            let webVC = CommonWebViewController()
            webVC.configure(title: "网页", url: action, themeColor: Theme.electricBlue)
            navigationController?.pushViewController(webVC, animated: true)
            return
        }
        
        switch action {
        case "qukan":
            vc = QuKanQuDuViewController()
        case "quwan":
            vc = QuWanViewController()
        case "quban":
            vc = QuBanViewController()
        case "qulearn":
            vc = QuLearnViewController()
        case "drawing":
            vc = DrawingBoardViewController()
        case "poster":
            vc = PosterModeViewController()
        default:
            vc = nil
        }
        
        if let viewController = vc {
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
}
