import UIKit

class QuSuViewController: UIViewController {
    
    private let features: [(title: String, subtitle: String, icon: String, color: UIColor)] = [
        ("系统体检", "全面扫描设备状态", "🔍", UIColor(hex: "00D4AA")),
        ("垃圾清理", "缓存、垃圾、安装包清理", "🗑️", UIColor(hex: "FF6B6B")),
        ("内存加速", "释放运行内存", "⚡", UIColor(hex: "FFE66D")),
        ("修复优化", "系统异常修复", "🔧", UIColor(hex: "4ECDC4")),
        ("设备信息", "型号、系统、存储状态", "📱", UIColor(hex: "A855F7")),
        ("自启动管理", "禁止应用自启动", "🚫", UIColor(hex: "F39C12"))
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
        titleLabel.text = "趣速"
        titleLabel.font = Theme.Font.bold(size: 36)
        titleLabel.textColor = Theme.brightWhite
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = "一键优化，畅快体验"
        subtitleLabel.font = Theme.Font.regular(size: 16)
        subtitleLabel.textColor = Theme.mutedGray
        subtitleLabel.textAlignment = .center
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(subtitleLabel)
        
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)
        
        for (index, feature) in features.enumerated() {
            let card = createFeatureCard(feature: feature, index: index)
            stackView.addArrangedSubview(card)
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            scrollView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 24),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20)
        ])
        
        title = "趣速"
    }
    
    private func createFeatureCard(feature: (title: String, subtitle: String, icon: String, color: UIColor), index: Int) -> UIView {
        let card = UIView()
        card.backgroundColor = Theme.cardBackground.withAlphaComponent(0.6)
        card.layer.cornerRadius = Theme.cardCornerRadius
        card.layer.shadowColor = feature.color.cgColor
        card.layer.shadowOffset = CGSize(width: 0, height: 4)
        card.layer.shadowOpacity = 0.3
        card.layer.shadowRadius = 10
        card.translatesAutoresizingMaskIntoConstraints = false
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(featureTapped(_:)))
        card.addGestureRecognizer(tapGesture)
        card.tag = index
        card.isUserInteractionEnabled = true
        
        let iconLabel = UILabel()
        iconLabel.text = feature.icon
        iconLabel.font = UIFont.systemFont(ofSize: 40)
        iconLabel.textAlignment = .center
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(iconLabel)
        
        let titleLabel = UILabel()
        titleLabel.text = feature.title
        titleLabel.font = Theme.Font.bold(size: 20)
        titleLabel.textColor = Theme.brightWhite
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(titleLabel)
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = feature.subtitle
        subtitleLabel.font = Theme.Font.regular(size: 13)
        subtitleLabel.textColor = feature.color
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(subtitleLabel)
        
        let arrowLabel = UILabel()
        arrowLabel.text = "›"
        arrowLabel.font = Theme.Font.bold(size: 24)
        arrowLabel.textColor = feature.color
        arrowLabel.textAlignment = .right
        arrowLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(arrowLabel)
        
        NSLayoutConstraint.activate([
            card.heightAnchor.constraint(equalToConstant: 90),
            
            iconLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            iconLabel.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            iconLabel.widthAnchor.constraint(equalToConstant: 50),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 20),
            
            subtitleLabel.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: 16),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            
            arrowLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            arrowLabel.centerYAnchor.constraint(equalTo: card.centerYAnchor)
        ])
        
        return card
    }
    
    @objc private func featureTapped(_ gesture: UITapGestureRecognizer) {
        guard let index = gesture.view?.tag else { return }
        
        switch index {
        case 0:
            let vc = SystemCheckViewController()
            navigationController?.pushViewController(vc, animated: true)
        case 1:
            let vc = JunkCleanViewController()
            navigationController?.pushViewController(vc, animated: true)
        case 2:
            let vc = MemoryBoostViewController()
            navigationController?.pushViewController(vc, animated: true)
        case 3:
            let vc = RepairOptimizeViewController()
            navigationController?.pushViewController(vc, animated: true)
        case 4:
            let vc = DeviceInfoViewController()
            navigationController?.pushViewController(vc, animated: true)
        case 5:
            let vc = AutoStartViewController()
            navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }
    }
}
