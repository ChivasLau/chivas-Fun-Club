import UIKit

class QuJiaViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        let gradientBg = GradientBackgroundView(frame: view.bounds)
        gradientBg.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(gradientBg)
        
        let titleLabel = UILabel()
        titleLabel.text = "趣家"
        titleLabel.font = Theme.Font.bold(size: 28)
        titleLabel.textColor = Theme.brightWhite
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        let container = UIView()
        container.backgroundColor = Theme.cardBackground.withAlphaComponent(0.6)
        container.layer.cornerRadius = Theme.cardCornerRadius
        container.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(container)
        
        let iconLabel = UILabel()
        iconLabel.text = "🏠"
        iconLabel.font = UIFont.systemFont(ofSize: 60)
        iconLabel.textAlignment = .center
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(iconLabel)
        
        let statusLabel = UILabel()
        statusLabel.text = "待开发"
        statusLabel.font = Theme.Font.bold(size: 24)
        statusLabel.textColor = Theme.mutedGray
        statusLabel.textAlignment = .center
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(statusLabel)
        
        let descLabel = UILabel()
        descLabel.text = "家庭生活服务功能即将上线"
        descLabel.font = Theme.Font.regular(size: 14)
        descLabel.textColor = Theme.mutedGray
        descLabel.textAlignment = .center
        descLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(descLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            container.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            container.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            container.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            iconLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 40),
            iconLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            
            statusLabel.topAnchor.constraint(equalTo: iconLabel.bottomAnchor, constant: 20),
            statusLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            
            descLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 8),
            descLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            descLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -40)
        ])
        
        title = "趣家"
    }
}
