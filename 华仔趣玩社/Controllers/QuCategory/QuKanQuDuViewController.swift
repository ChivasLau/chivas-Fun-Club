import UIKit

class QuKanQuDuViewController: UIViewController {
    
    private let items: [(category: String, name: String, icon: String, color: UIColor, url: String)] = [
        ("视频网站", "快看影视", "🎬", UIColor(hex: "E74C3C"), "https://www.kuaikanys.com/"),
        ("视频网站", "KK影视", "📺", UIColor(hex: "3498DB"), "https://www.kkys03.com/"),
        ("视频网站", "Kimi影视", "🎥", UIColor(hex: "9B59B6"), "https://kimi.ai/"),
        ("儿童视频", "麦咕卡通", "🧸", UIColor(hex: "FF9800"), "https://www.maijitv.com/"),
        ("儿童视频", "哔哩哔哩", "📱", UIColor(hex: "00A1D6"), "https://www.bilibili.com/"),
        ("儿童视频", "央视影音", "📡", UIColor(hex: "C41230"), "https://tv.cctv.com/"),
        ("短剧", "红果果短剧", "🎭", UIColor(hex: "FF6B6B"), "https://www.hongguoguo.tv/"),
        ("短剧", "一刻短剧", "🎬", UIColor(hex: "4ECDC4"), "https://www.yike.tv/"),
        ("短剧", "短剧屋", "📺", UIColor(hex: "A855F7"), "https://www.djys.tv/"),
        ("短剧", "Dailymotion", "🎥", UIColor(hex: "F39C12"), "https://www.dailymotion.com/kchow125"),
        ("小说", "番茄小说", "📚", UIColor(hex: "FF5722"), "https://fanqienovel.com/"),
        ("小说", "番茄作家", "✍️", UIColor(hex: "E91E63"), "https://ifanqienovel.com/")
    ]
    
    private let categories = ["视频网站", "儿童视频", "短剧", "小说"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return false
    }
    
    private func setupUI() {
        let gradientBg = GradientBackgroundView(frame: view.bounds)
        gradientBg.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(gradientBg)
        
        let titleLabel = UILabel()
        titleLabel.text = "趣看趣读"
        titleLabel.font = Theme.Font.bold(size: 28)
        titleLabel.textColor = Theme.brightWhite
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)
        
        for category in categories {
            let categoryItems = items.filter { $0.category == category }
            let sectionView = createSectionView(title: category, items: categoryItems)
            stackView.addArrangedSubview(sectionView)
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20)
        ])
        
        title = "趣看趣读"
    }
    
    private func createSectionView(title: String, items: [(category: String, name: String, icon: String, color: UIColor, url: String)]) -> UIView {
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
        
        let itemStack = UIStackView()
        itemStack.axis = .vertical
        itemStack.spacing = 12
        itemStack.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(itemStack)
        
        for (index, item) in items.enumerated() {
            let itemView = createItemView(name: item.name, icon: item.icon, color: item.color, url: item.url, index: index)
            itemStack.addArrangedSubview(itemView)
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            
            itemStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            itemStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            itemStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            itemStack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16)
        ])
        
        return container
    }
    
    private func createItemView(name: String, icon: String, color: UIColor, url: String, index: Int) -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(itemTapped(_:)))
        view.addGestureRecognizer(tapGesture)
        view.isUserInteractionEnabled = true
        view.tag = items.firstIndex { $0.name == name } ?? 0
        
        let iconLabel = UILabel()
        iconLabel.text = icon
        iconLabel.font = UIFont.systemFont(ofSize: 24)
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(iconLabel)
        
        let nameLabel = UILabel()
        nameLabel.text = name
        nameLabel.font = Theme.Font.bold(size: 16)
        nameLabel.textColor = Theme.brightWhite
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        
        let arrowLabel = UILabel()
        arrowLabel.text = "›"
        arrowLabel.font = Theme.Font.bold(size: 20)
        arrowLabel.textColor = color
        arrowLabel.textAlignment = .right
        arrowLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(arrowLabel)
        
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 50),
            
            iconLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            iconLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            iconLabel.widthAnchor.constraint(equalToConstant: 36),
            
            nameLabel.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: 12),
            nameLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            arrowLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            arrowLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        return view
    }
    
    @objc private func itemTapped(_ gesture: UITapGestureRecognizer) {
        guard let index = gesture.view?.tag, index < items.count else { return }
        let item = items[index]
        
        UsageTracker.shared.recordUsage(
            category: item.category,
            name: item.name,
            icon: item.icon,
            colorHex: item.color.hexString,
            action: item.url
        )
        
        let webVC = CommonWebViewController()
        webVC.configure(title: item.name, url: item.url, themeColor: item.color)
        navigationController?.pushViewController(webVC, animated: true)
    }
}

extension UIColor {
    var hexString: String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        return String(format: "%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
    }
}
