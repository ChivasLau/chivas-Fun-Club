import UIKit

class QuWanHomeViewController: UIViewController {
    
    private let games: [(title: String, subtitle: String, url: String, icon: String, color: UIColor)] = [
        ("宝贝画板", "自由绘画 & 填色乐园", "drawing", "🎨", UIColor(hex: "A855F7")),
        
        ("星野游戏", "精选H5小游戏", "https://xingye.me/game/index.php", "🌟", UIColor(hex: "F39C12")),
        ("iox小游戏", "休闲益智游戏", "https://ioxapp.com/", "🎯", UIColor(hex: "2ECC71")),
        
        ("4399小游戏", "经典网页游戏", "https://www.4399.com/", "🎮", UIColor(hex: "E74C3C")),
        ("7k7k小游戏", "休闲游戏平台", "https://www.7k7k.com/", "🎲", UIColor(hex: "3498DB")),
        
        ("遥控车模拟", "3D遥控车驾驶", "https://bruno-simon.com/", "🚗", UIColor(hex: "1ABC9C")),
        ("贪吃蛇大作战", "经典贪吃蛇", "http://slither.io/", "🐍", UIColor(hex: "27AE60")),
        
        ("Poki游戏", "国际免费游戏", "https://poki.com/", "🕹️", UIColor(hex: "9B59B6")),
        ("CrazyGames", "疯狂游戏", "https://www.crazygames.com/", "🎪", UIColor(hex: "E91E63"))
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
        titleLabel.font = Theme.Font.bold(size: 28)
        titleLabel.textColor = Theme.brightWhite
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = "选择你想玩的游戏"
        subtitleLabel.font = Theme.Font.regular(size: 14)
        subtitleLabel.textColor = Theme.mutedGray
        subtitleLabel.textAlignment = .center
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(subtitleLabel)
        
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)
        
        for game in games {
            let card = createGameCard(game: game)
            stackView.addArrangedSubview(card)
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            scrollView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 20),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20)
        ])
        
        title = "趣玩"
    }
    
    private func createGameCard(game: (title: String, subtitle: String, url: String, icon: String, color: UIColor)) -> UIView {
        let cardColor = game.color
        
        let card = UIView()
        card.backgroundColor = Theme.cardBackground.withAlphaComponent(0.6)
        card.layer.cornerRadius = Theme.cardCornerRadius
        card.layer.shadowColor = cardColor.cgColor
        card.layer.shadowOffset = CGSize(width: 0, height: 3)
        card.layer.shadowOpacity = 0.3
        card.layer.shadowRadius = 8
        card.translatesAutoresizingMaskIntoConstraints = false
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cardTapped(_:)))
        card.addGestureRecognizer(tapGesture)
        card.tag = games.firstIndex(where: { $0.title == game.title }) ?? 0
        card.isUserInteractionEnabled = true
        
        let iconLabel = UILabel()
        iconLabel.text = game.icon
        iconLabel.font = UIFont.systemFont(ofSize: 36)
        iconLabel.textAlignment = .center
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(iconLabel)
        
        let titleLabel = UILabel()
        titleLabel.text = game.title
        titleLabel.font = Theme.Font.bold(size: 18)
        titleLabel.textColor = Theme.brightWhite
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(titleLabel)
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = game.subtitle
        subtitleLabel.font = Theme.Font.regular(size: 12)
        subtitleLabel.textColor = cardColor
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(subtitleLabel)
        
        let arrowLabel = UILabel()
        arrowLabel.text = "›"
        arrowLabel.font = Theme.Font.bold(size: 24)
        arrowLabel.textColor = cardColor
        arrowLabel.textAlignment = .right
        arrowLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(arrowLabel)
        
        NSLayoutConstraint.activate([
            card.heightAnchor.constraint(equalToConstant: 80),
            
            iconLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            iconLabel.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            iconLabel.widthAnchor.constraint(equalToConstant: 50),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 18),
            
            subtitleLabel.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: 12),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            
            arrowLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
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
