import UIKit

class QuWanHomeViewController: UIViewController {
    
    private let games: [(title: String, subtitle: String, url: String, icon: String, color: UIColor)] = [
        ("Poki", "免费在线游戏", "https://poki.com/", "🎮", UIColor(hex: "FF6B6B")),
        ("CrazyGames", "疯狂游戏", "https://www.crazygames.com/", "🎯", UIColor(hex: "4ECDC4")),
        ("宝贝画板", "自由绘画 & 填色乐园", "drawing", "🎨", UIColor(hex: "A855F7"))
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
        titleLabel.text = "趣玩乐园"
        titleLabel.font = Theme.Font.bold(size: 32)
        titleLabel.textColor = Theme.brightWhite
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = "选择你想玩的游戏"
        subtitleLabel.font = Theme.Font.regular(size: 16)
        subtitleLabel.textColor = Theme.mutedGray
        subtitleLabel.textAlignment = .center
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(subtitleLabel)
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        for game in games {
            let card = createGameCard(game: game)
            stackView.addArrangedSubview(card)
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            stackView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 40),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40)
        ])
        
        title = "趣玩"
    }
    
    private func createGameCard(game: (title: String, subtitle: String, url: String, icon: String, color: UIColor)) -> UIView {
        let cardColor = game.color
        
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
        card.tag = games.firstIndex(where: { $0.title == game.title }) ?? 0
        card.isUserInteractionEnabled = true
        
        let iconLabel = UILabel()
        iconLabel.text = game.icon
        iconLabel.font = UIFont.systemFont(ofSize: 48)
        iconLabel.textAlignment = .center
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(iconLabel)
        
        let titleLabel = UILabel()
        titleLabel.text = game.title
        titleLabel.font = Theme.Font.bold(size: 24)
        titleLabel.textColor = Theme.brightWhite
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(titleLabel)
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = game.subtitle
        subtitleLabel.font = Theme.Font.regular(size: 14)
        subtitleLabel.textColor = cardColor
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(subtitleLabel)
        
        let arrowLabel = UILabel()
        arrowLabel.text = "›"
        arrowLabel.font = Theme.Font.bold(size: 28)
        arrowLabel.textColor = cardColor
        arrowLabel.textAlignment = .right
        arrowLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(arrowLabel)
        
        NSLayoutConstraint.activate([
            card.heightAnchor.constraint(equalToConstant: 100),
            
            iconLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            iconLabel.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            iconLabel.widthAnchor.constraint(equalToConstant: 60),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 24),
            
            subtitleLabel.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: 16),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            
            arrowLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            arrowLabel.centerYAnchor.constraint(equalTo: card.centerYAnchor)
        ])
        
        return card
    }
    
    @objc private func cardTapped(_ gesture: UITapGestureRecognizer) {
        guard let index = gesture.view?.tag else { return }
        let game = games[index]
        
        if game.url == "drawing" {
            let drawingVC = DrawingBoardViewController()
            navigationController?.pushViewController(drawingVC, animated: true)
        } else {
            let webVC = QuWanWebViewController()
            webVC.configure(title: game.title, url: game.url, themeColor: game.color)
            navigationController?.pushViewController(webVC, animated: true)
        }
    }
}
