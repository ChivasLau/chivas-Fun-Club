import UIKit

class QuDuViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        let gradientBg = GradientBackgroundView(frame: view.bounds)
        gradientBg.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(gradientBg)
        
        let cardView = UIView()
        cardView.backgroundColor = Theme.cardBackground.withAlphaComponent(0.6)
        cardView.layer.cornerRadius = Theme.cardCornerRadius
        cardView.layer.shadowColor = Theme.brightWhite.cgColor
        cardView.layer.shadowOffset = CGSize(width: 0, height: 4)
        cardView.layer.shadowOpacity = 0.2
        cardView.layer.shadowRadius = 12
        cardView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cardView)
        
        let iconLabel = UILabel()
        iconLabel.text = "📖"
        iconLabel.font = UIFont.systemFont(ofSize: 64)
        iconLabel.textAlignment = .center
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(iconLabel)
        
        let titleLabel = UILabel()
        titleLabel.text = "趣读"
        titleLabel.textColor = Theme.brightWhite
        titleLabel.font = Theme.Font.bold(size: 28)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(titleLabel)
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = "即将上线\n敬请期待"
        subtitleLabel.textColor = Theme.mutedGray
        subtitleLabel.font = Theme.Font.regular(size: 16)
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            cardView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cardView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            cardView.widthAnchor.constraint(equalToConstant: 280),
            cardView.heightAnchor.constraint(equalToConstant: 200),
            
            iconLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 24),
            iconLabel.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: iconLabel.bottomAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            subtitleLabel.centerXAnchor.constraint(equalTo: cardView.centerXAnchor)
        ])
        
        title = "趣读"
    }
}
