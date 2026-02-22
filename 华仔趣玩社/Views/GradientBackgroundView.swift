import UIKit

class GradientBackgroundView: UIView {
    
    private var gradientLayer: CAGradientLayer?
    private var glowLayer: CAGradientLayer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradient()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGradient()
    }
    
    private func setupGradient() {
        gradientLayer = CAGradientLayer()
        gradientLayer?.colors = [Theme.gradientTop.cgColor, Theme.gradientBottom.cgColor]
        gradientLayer?.locations = [0.0, 1.0]
        layer.insertSublayer(gradientLayer!, at: 0)
        
        setupGlow()
    }
    
    private func setupGlow() {
        glowLayer = CAGradientLayer()
        glowLayer?.colors = [
            Theme.electricBlue.withAlphaComponent(0.15).cgColor,
            UIColor.clear.cgColor
        ]
        glowLayer?.locations = [0.0, 1.0]
        glowLayer?.startPoint = CGPoint(x: 0.5, y: 0)
        glowLayer?.endPoint = CGPoint(x: 0.5, y: 0.5)
        layer.insertSublayer(glowLayer!, at: 1)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer?.frame = bounds
        glowLayer?.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height * 0.4)
    }
}
