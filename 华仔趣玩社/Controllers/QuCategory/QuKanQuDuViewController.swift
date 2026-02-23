import UIKit

class QuKanQuDuViewController: UIViewController {
    
    private let items: [(String, String, String, UIColor)] = [
        ("视频网站", "快看影视", "🎬", UIColor(hex: "E74C3C")),
        ("视频网站", "KK影视", "📺", UIColor(hex: "3498DB")),
        ("视频网站", "Kimi影视", "🎥", UIColor(hex: "9B59B6")),
        ("短剧", "红果果短剧", "🎭", UIColor(hex: "FF6B6B")),
        ("短剧", "一刻短剧", "🎬", UIColor(hex: "4ECDC4")),
        ("短剧", "短剧屋", "📺", UIColor(hex: "A855F7")),
        ("短剧", "Dailymotion", "🎥", UIColor(hex: "F39C12")),
        ("小说", "番茄小说", "📚", UIColor(hex: "FF5722")),
        ("小说", "番茄作家", "✍️", UIColor(hex: "E91E63"))
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
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
        
        let categories = ["视频网站", "短剧", "小说"]
        for category in categories {
            let categoryItems = items.filter { $0.0 == category }
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
    
    private func createSectionView(title: String, items: [(String, String, String, UIColor)]) -> UIView {
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
        
        for item in items {
            let itemView = createItemView(name: item.1, icon: item.2, color: item.3)
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
    
    private func createItemView(name: String, icon: String, color: UIColor) -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
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
}
