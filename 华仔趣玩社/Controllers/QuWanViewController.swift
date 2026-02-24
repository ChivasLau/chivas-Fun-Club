import UIKit

class QuWanViewController: UIViewController {
    
    private let games: [(String, String, String, UIColor, String)] = [
        ("宝贝画板", "自由绘画 & 填色乐园", "🎨", UIColor(hex: "A855F7"), "drawing"),
        ("海报设计", "海报编辑 & 图片合成", "🖼️", UIColor(hex: "00D4AA"), "poster"),
        
        ("FRVR", "即点即玩游戏", "🎯", UIColor(hex: "FF6B6B"), "https://frvr.com/"),
        ("Jigsaw Planet", "在线拼图游戏", "🧩", UIColor(hex: "4ECDC4"), "https://www.jigsawplanet.com/"),
        ("Hextris", "六边形俄罗斯方块", "⬡", UIColor(hex: "FFE66D"), "https://hextris.io/"),
        ("Lines FRVR", "连点成线益智", "📏", UIColor(hex: "F39C12"), "https://lines.frvr.com/"),
        ("Tetris", "经典俄罗斯方块", "🎮", UIColor(hex: "E74C3C"), "https://chvin.github.io/react-tetris/"),
        ("Minesweeper", "经典扫雷游戏", "💣", UIColor(hex: "95E1D3"), "https://minesweeperplay.online/"),
        ("Game.Hullqin", "20+桌游联机", "🎲", UIColor(hex: "DDA0DD"), "https://game.hullqin.cn/"),
        ("Bloxd.io", "我的世界风格", "🏗️", UIColor(hex: "27AE60"), "https://bloxd.io/"),
        
        ("星野游戏", "H5小游戏", "🌟", UIColor(hex: "F39C12"), "https://xingye.me/game/index.php"),
        ("iox小游戏", "休闲益智", "🎯", UIColor(hex: "2ECC71"), "https://ioxapp.com/"),
        ("4399小游戏", "经典网页游戏", "🎮", UIColor(hex: "E74C3C"), "https://www.4399.com/"),
        ("7k7k小游戏", "休闲游戏平台", "🎲", UIColor(hex: "3498DB"), "https://www.7k7k.com/"),
        ("遥控车模拟", "3D遥控车驾驶", "🚗", UIColor(hex: "1ABC9C"), "https://bruno-simon.com/"),
        ("贪吃蛇大作战", "经典贪吃蛇", "🐍", UIColor(hex: "27AE60"), "http://slither.io/"),
        ("Poki游戏", "国际免费游戏", "🕹️", UIColor(hex: "9B59B6"), "https://poki.com/"),
        ("CrazyGames", "疯狂游戏", "🎪", UIColor(hex: "E91E63"), "https://www.crazygames.com/")
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
        
        let backButton = UIButton(type: .system)
        backButton.setTitle("‹ 返回", for: .normal)
        backButton.titleLabel?.font = Theme.Font.bold(size: 18)
        backButton.setTitleColor(Theme.electricBlue, for: .normal)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        view.addSubview(backButton)
        
        let titleLabel = UILabel()
        titleLabel.text = "趣玩"
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
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)
        
        for (index, game) in games.enumerated() {
            let card = createGameCard(name: game.0, subtitle: game.1, icon: game.2, color: game.3, index: index)
            stackView.addArrangedSubview(card)
        }
        
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20)
        ])
        
        title = "趣玩"
    }
    
    private func createGameCard(name: String, subtitle: String, icon: String, color: UIColor, index: Int) -> UIView {
        let card = UIView()
        card.backgroundColor = Theme.cardBackground.withAlphaComponent(0.6)
        card.layer.cornerRadius = Theme.cornerRadius
        card.layer.shadowColor = color.cgColor
        card.layer.shadowOffset = CGSize(width: 0, height: 2)
        card.layer.shadowOpacity = 0.3
        card.layer.shadowRadius = 6
        card.translatesAutoresizingMaskIntoConstraints = false
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(gameTapped(_:)))
        card.addGestureRecognizer(tapGesture)
        card.tag = index
        card.isUserInteractionEnabled = true
        
        let iconLabel = UILabel()
        iconLabel.text = icon
        iconLabel.font = UIFont.systemFont(ofSize: 28)
        iconLabel.textAlignment = .center
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(iconLabel)
        
        let nameLabel = UILabel()
        nameLabel.text = name
        nameLabel.font = Theme.Font.bold(size: 16)
        nameLabel.textColor = Theme.brightWhite
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(nameLabel)
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.font = Theme.Font.regular(size: 12)
        subtitleLabel.textColor = color
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(subtitleLabel)
        
        let arrowLabel = UILabel()
        arrowLabel.text = "›"
        arrowLabel.font = Theme.Font.bold(size: 20)
        arrowLabel.textColor = color
        arrowLabel.textAlignment = .right
        arrowLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(arrowLabel)
        
        NSLayoutConstraint.activate([
            card.heightAnchor.constraint(equalToConstant: 70),
            
            iconLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            iconLabel.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            iconLabel.widthAnchor.constraint(equalToConstant: 36),
            
            nameLabel.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: 12),
            nameLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            
            subtitleLabel.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: 12),
            subtitleLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2),
            
            arrowLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            arrowLabel.centerYAnchor.constraint(equalTo: card.centerYAnchor)
        ])
        
        return card
    }
    
    @objc private func goBack() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func gameTapped(_ gesture: UITapGestureRecognizer) {
        guard let index = gesture.view?.tag else { return }
        let game = games[index]
        
        if game.4 == "drawing" {
            let drawingVC = DrawingBoardViewController()
            navigationController?.pushViewController(drawingVC, animated: true)
        } else if game.4 == "poster" {
            let posterVC = PosterModeViewController()
            navigationController?.pushViewController(posterVC, animated: true)
        } else {
            let webVC = QuWanWebViewController()
            webVC.configure(title: game.0, url: game.4, themeColor: game.3)
            navigationController?.pushViewController(webVC, animated: true)
        }
    }
}
