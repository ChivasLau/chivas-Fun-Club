import UIKit

struct Theme {
    static let gradientTop = UIColor(hex: "12122B")
    static let gradientBottom = UIColor(hex: "3A2465")
    
    static let neonPink = UIColor(hex: "FF88CC")
    static let electricBlue = UIColor(hex: "44AAFF")
    static let brightWhite = UIColor(hex: "FFFFFF")
    static let mutedGray = UIColor(hex: "8E8E93")
    static let cardBackground = UIColor(hex: "1E1E3F")
    
    static let cornerRadius: CGFloat = 16
    static let cardCornerRadius: CGFloat = 24
    
    struct Font {
        static func bold(size: CGFloat) -> UIFont {
            return UIFont.boldSystemFont(ofSize: size)
        }
        
        static func regular(size: CGFloat) -> UIFont {
            return UIFont.systemFont(ofSize: size)
        }
    }
    
    static func applyGradient(to view: UIView) {
        let gradient = CAGradientLayer()
        gradient.colors = [gradientTop.cgColor, gradientBottom.cgColor]
        gradient.locations = [0.0, 1.0]
        gradient.frame = view.bounds
        view.layer.insertSublayer(gradient, at: 0)
    }
    
    static func applyCardStyle(to view: UIView) {
        view.layer.cornerRadius = cardCornerRadius
        view.layer.shadowColor = neonPink.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowOpacity = 0.3
        view.layer.shadowRadius = 12
        view.backgroundColor = cardBackground.withAlphaComponent(0.6)
    }
}
