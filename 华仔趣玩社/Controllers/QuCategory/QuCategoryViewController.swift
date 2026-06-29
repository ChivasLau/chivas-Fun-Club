import UIKit

class QuCategoryViewController: UIViewController {
    
    private let categories: [(String, String, UIColor)] = [
        ("趣玩", "游戏 · 画板 · 娱乐", UIColor(hex: "3498DB")),
        ("趣办", "AI工具 · 效率工具", UIColor(hex: "9B59B6")),
        ("趣家", "家庭 · 生活服务", UIColor(hex: "F39C12")),
        ("趣学", "幼儿启蒙 · 学习工具", UIColor(hex: "00D4AA"))
    ]
    
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
        titleLabel.text = "趣分类"
        titleLabel.font = Theme.Font.bold(size: 32)
        titleLabel.textColor = Theme.brightWhite
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        for (index, category) in categories.enumerated() {
            let card = createCategoryCard(title: category.0, icon: category.1, color: category.2, index: index)
            stackView.addArrangedSubview(card)
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 32),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
        
        title = "趣分类"
    }
    
    private func createCategoryCard(title: String, icon: String, color: UIColor, index: Int) -> UIView {
        let card = UIView()
        card.backgroundColor = Theme.cardBackground.withAlphaComponent(0.6)
        card.layer.cornerRadius = Theme.cardCornerRadius
        card.layer.shadowColor = color.cgColor
        card.layer.shadowOffset = CGSize(width: 0, height: 4)
        card.layer.shadowOpacity = 0.4
        card.layer.shadowRadius = 12
        card.translatesAutoresizingMaskIntoConstraints = false
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(categoryTapped(_:)))
        card.addGestureRecognizer(tapGesture)
        card.tag = index
        card.isUserInteractionEnabled = true
        
        let iconLabel = UILabel()
        iconLabel.text = getCategoryIcon(for: index)
        iconLabel.font = UIFont.systemFont(ofSize: 48)
        iconLabel.textAlignment = .center
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(iconLabel)
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = Theme.Font.bold(size: 26)
        titleLabel.textColor = Theme.brightWhite
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(titleLabel)
        
        let arrowLabel = UILabel()
        arrowLabel.text = "›"
        arrowLabel.font = Theme.Font.bold(size: 32)
        arrowLabel.textColor = color
        arrowLabel.textAlignment = .right
        arrowLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(arrowLabel)
        
        NSLayoutConstraint.activate([
            card.heightAnchor.constraint(equalToConstant: 110),
            
            iconLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 24),
            iconLabel.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            iconLabel.widthAnchor.constraint(equalToConstant: 60),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: 20),
            titleLabel.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            
            arrowLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -24),
            arrowLabel.centerYAnchor.constraint(equalTo: card.centerYAnchor)
        ])
        
        return card
    }
    
    private func getCategoryIcon(for index: Int) -> String {
        let icons = ["🎮", "🤖", "🏠", "📖"]
        return icons[index]
    }
    
    @objc private func categoryTapped(_ gesture: UITapGestureRecognizer) {
        guard let index = gesture.view?.tag else { return }
        
        switch index {
        case 0:
            let vc = QuWanViewController()
            navigationController?.pushViewController(vc, animated: true)
        case 1:
            let vc = QuBanViewController()
            navigationController?.pushViewController(vc, animated: true)
        case 2:
            let vc = QuJiaViewController()
            navigationController?.pushViewController(vc, animated: true)
        case 3:
            let vc = QuLearnViewController()
            navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }
    }
}
