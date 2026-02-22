import UIKit

class QuKanViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let homeVC = QuKanHomeViewController()
        addChild(homeVC)
        view.addSubview(homeVC.view)
        homeVC.view.frame = view.bounds
        homeVC.didMove(toParent: self)
        
        title = "趣看"
    }
}

class QuKanHomeViewController: UIViewController {
    
    private let websites: [(title: String, subtitle: String, url: String, icon: String, color: UIColor)] = [
        ("快看影视", "热门影视在线观看", "https://www.kuaikaw.cn/", "🎬", UIColor(hex: "E74C3C")),
        ("KK影视", "高清视频资源站", "https://www.kkys1.com/", "📺", UIColor(hex: "3498DB")),
        ("Kimi影视", "精选视频内容", "https://kimivod.com/vod/125313/1-1.html", "🎥", UIColor(hex: "9B59B6"))
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
        titleLabel.text = "趣看天地"
        titleLabel.font = Theme.Font.bold(size: 32)
        titleLabel.textColor = Theme.brightWhite
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = "选择你想看的视频网站"
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
        
        for site in websites {
            let card = createSiteCard(site: site)
            stackView.addArrangedSubview(card)
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            stackView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 50),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40)
        ])
        
        title = "趣看"
    }
    
    private func createSiteCard(site: (title: String, subtitle: String, url: String, icon: String, color: UIColor)) -> UIView {
        let cardColor = site.color
        
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
        card.tag = websites.firstIndex(where: { $0.title == site.title }) ?? 0
        card.isUserInteractionEnabled = true
        
        let iconLabel = UILabel()
        iconLabel.text = site.icon
        iconLabel.font = UIFont.systemFont(ofSize: 56)
        iconLabel.textAlignment = .center
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(iconLabel)
        
        let titleLabel = UILabel()
        titleLabel.text = site.title
        titleLabel.font = Theme.Font.bold(size: 26)
        titleLabel.textColor = Theme.brightWhite
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(titleLabel)
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = site.subtitle
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
            card.heightAnchor.constraint(equalToConstant: 120),
            
            iconLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 24),
            iconLabel.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            iconLabel.widthAnchor.constraint(equalToConstant: 70),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: 20),
            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 28),
            
            subtitleLabel.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: 20),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            
            arrowLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -24),
            arrowLabel.centerYAnchor.constraint(equalTo: card.centerYAnchor)
        ])
        
        return card
    }
    
    @objc private func cardTapped(_ gesture: UITapGestureRecognizer) {
        guard let index = gesture.view?.tag else { return }
        let site = websites[index]
        
        let webVC = QuKanWebViewController()
        webVC.configure(title: site.title, url: site.url, themeColor: site.color)
        navigationController?.pushViewController(webVC, animated: true)
    }
}
