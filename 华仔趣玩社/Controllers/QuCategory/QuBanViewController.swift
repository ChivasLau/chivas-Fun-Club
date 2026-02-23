import UIKit

class QuBanViewController: UIViewController {
    
    private let items: [(String, String, UIColor, String)] = [
        ("豆包AI", "🤖", UIColor(hex: "00D4AA"), "https://www.doubao.com/chat/?channel=dyK7x"),
        ("智谱AI", "🧠", UIColor(hex: "6366F1"), "https://chatglm.cn/video?utm_source=ai-bot.cn&lang=zh")
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
        titleLabel.text = "趣办"
        titleLabel.font = Theme.Font.bold(size: 28)
        titleLabel.textColor = Theme.brightWhite
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        for (index, item) in items.enumerated() {
            let card = createItemCard(name: item.0, icon: item.1, color: item.2, index: index)
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
        
        title = "趣办"
    }
    
    private func createItemCard(name: String, icon: String, color: UIColor, index: Int) -> UIView {
        let card = UIView()
        card.backgroundColor = Theme.cardBackground.withAlphaComponent(0.6)
        card.layer.cornerRadius = Theme.cardCornerRadius
        card.layer.shadowColor = color.cgColor
        card.layer.shadowOffset = CGSize(width: 0, height: 4)
        card.layer.shadowOpacity = 0.4
        card.layer.shadowRadius = 12
        card.translatesAutoresizingMaskIntoConstraints = false
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(itemTapped(_:)))
        card.addGestureRecognizer(tapGesture)
        card.tag = index
        card.isUserInteractionEnabled = true
        
        let iconLabel = UILabel()
        iconLabel.text = icon
        iconLabel.font = UIFont.systemFont(ofSize: 40)
        iconLabel.textAlignment = .center
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(iconLabel)
        
        let nameLabel = UILabel()
        nameLabel.text = name
        nameLabel.font = Theme.Font.bold(size: 22)
        nameLabel.textColor = Theme.brightWhite
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(nameLabel)
        
        let arrowLabel = UILabel()
        arrowLabel.text = "›"
        arrowLabel.font = Theme.Font.bold(size: 28)
        arrowLabel.textColor = color
        arrowLabel.textAlignment = .right
        arrowLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(arrowLabel)
        
        NSLayoutConstraint.activate([
            card.heightAnchor.constraint(equalToConstant: 100),
            
            iconLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            iconLabel.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            iconLabel.widthAnchor.constraint(equalToConstant: 50),
            
            nameLabel.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: 16),
            nameLabel.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            
            arrowLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            arrowLabel.centerYAnchor.constraint(equalTo: card.centerYAnchor)
        ])
        
        return card
    }
    
    @objc private func itemTapped(_ gesture: UITapGestureRecognizer) {
        guard let index = gesture.view?.tag else { return }
        let item = items[index]
        
        let webVC = CommonWebViewController()
        webVC.configure(title: item.0, url: item.3, themeColor: item.2)
        navigationController?.pushViewController(webVC, animated: true)
    }
}
