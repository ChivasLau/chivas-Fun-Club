import UIKit

class AIToolsViewController: UIViewController {
    
    private let tools: [(title: String, subtitle: String, url: String, icon: String, color: UIColor)] = [
        ("豆包AI", "抖音旗下AI助手", "https://www.doubao.com/chat/?channel=dyK7x", "🤖", UIColor(hex: "00D4AA")),
        ("智谱AI", "清华技术视频生成", "https://chatglm.cn/video?utm_source=ai-bot.cn&lang=zh", "🧠", UIColor(hex: "6366F1"))
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
        titleLabel.text = "AI工具箱"
        titleLabel.font = Theme.Font.bold(size: 32)
        titleLabel.textColor = Theme.brightWhite
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = "智能助手，创意无限"
        subtitleLabel.font = Theme.Font.regular(size: 16)
        subtitleLabel.textColor = Theme.mutedGray
        subtitleLabel.textAlignment = .center
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(subtitleLabel)
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        for tool in tools {
            let card = createToolCard(tool: tool)
            stackView.addArrangedSubview(card)
        }
        
        let tipLabel = UILabel()
        tipLabel.text = "💡 提示：登录后会自动保存状态"
        tipLabel.font = Theme.Font.regular(size: 14)
        tipLabel.textColor = Theme.mutedGray
        tipLabel.textAlignment = .center
        tipLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tipLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            stackView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 60),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: tipLabel.topAnchor, constant: -30),
            
            tipLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            tipLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        title = "AI工具"
    }
    
    private func createToolCard(tool: (title: String, subtitle: String, url: String, icon: String, color: UIColor)) -> UIView {
        let cardColor = tool.color
        
        let card = UIView()
        card.backgroundColor = Theme.cardBackground.withAlphaComponent(0.6)
        card.layer.cornerRadius = Theme.cardCornerRadius
        card.layer.shadowColor = cardColor.cgColor
        card.layer.shadowOffset = CGSize(width: 0, height: 4)
        card.layer.shadowOpacity = 0.4
        card.layer.shadowRadius = 12
        card.translatesAutoresizingMaskIntoConstraints = false
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cardTapped(_:)))
        card.addGestureRecognizer(tapGesture)
        card.tag = tools.firstIndex(where: { $0.title == tool.title }) ?? 0
        card.isUserInteractionEnabled = true
        
        let iconLabel = UILabel()
        iconLabel.text = tool.icon
        iconLabel.font = UIFont.systemFont(ofSize: 56)
        iconLabel.textAlignment = .center
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(iconLabel)
        
        let titleLabel = UILabel()
        titleLabel.text = tool.title
        titleLabel.font = Theme.Font.bold(size: 26)
        titleLabel.textColor = Theme.brightWhite
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(titleLabel)
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = tool.subtitle
        subtitleLabel.font = Theme.Font.regular(size: 15)
        subtitleLabel.textColor = cardColor
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(subtitleLabel)
        
        let arrowLabel = UILabel()
        arrowLabel.text = "›"
        arrowLabel.font = Theme.Font.bold(size: 32)
        arrowLabel.textColor = cardColor
        arrowLabel.textAlignment = .right
        arrowLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(arrowLabel)
        
        NSLayoutConstraint.activate([
            card.heightAnchor.constraint(equalToConstant: 130),
            
            iconLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 24),
            iconLabel.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            iconLabel.widthAnchor.constraint(equalToConstant: 70),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: 20),
            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 32),
            
            subtitleLabel.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: 20),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            
            arrowLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -24),
            arrowLabel.centerYAnchor.constraint(equalTo: card.centerYAnchor)
        ])
        
        return card
    }
    
    @objc private func cardTapped(_ gesture: UITapGestureRecognizer) {
        guard let index = gesture.view?.tag else { return }
        let tool = tools[index]
        
        let webVC = AIWebViewViewController()
        webVC.configure(title: tool.title, url: tool.url, themeColor: tool.color)
        navigationController?.pushViewController(webVC, animated: true)
    }
}
