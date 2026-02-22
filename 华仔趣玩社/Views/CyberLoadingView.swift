import UIKit

class CyberLoadingView: UIView {
    
    private let ringLayer = CAShapeLayer()
    private let glowRingLayer = CAShapeLayer()
    private let pulsingLayer = CAShapeLayer()
    private let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = .clear
        
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius: CGFloat = min(bounds.width, bounds.height) / 2 - 20
        
        let ringPath = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: -CGFloat.pi / 2,
            endAngle: CGFloat.pi * 1.5,
            clockwise: true
        )
        
        pulsingLayer.path = ringPath.cgPath
        pulsingLayer.fillColor = UIColor.clear.cgColor
        pulsingLayer.strokeColor = Theme.electricBlue.withAlphaComponent(0.3).cgColor
        pulsingLayer.lineWidth = 8
        pulsingLayer.lineCap = .round
        layer.addSublayer(pulsingLayer)
        
        ringLayer.path = ringPath.cgPath
        ringLayer.fillColor = UIColor.clear.cgColor
        ringLayer.strokeColor = Theme.electricBlue.cgColor
        ringLayer.lineWidth = 4
        ringLayer.lineCap = .round
        ringLayer.strokeEnd = 0.3
        layer.addSublayer(ringLayer)
        
        glowRingLayer.path = ringPath.cgPath
        glowRingLayer.fillColor = UIColor.clear.cgColor
        glowRingLayer.strokeColor = Theme.neonPink.cgColor
        glowRingLayer.lineWidth = 2
        glowRingLayer.lineCap = .round
        glowRingLayer.strokeEnd = 0.15
        layer.addSublayer(glowRingLayer)
        
        label.text = "加载中..."
        label.textColor = Theme.brightWhite
        label.font = Theme.Font.bold(size: 16)
        label.textAlignment = .center
        label.sizeToFit()
        label.center = center
        addSubview(label)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius: CGFloat = min(bounds.width, bounds.height) / 2 - 20
        
        let ringPath = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: -CGFloat.pi / 2,
            endAngle: CGFloat.pi * 1.5,
            clockwise: true
        )
        
        pulsingLayer.path = ringPath.cgPath
        ringLayer.path = ringPath.cgPath
        glowRingLayer.path = ringPath.cgPath
        
        label.center = center
    }
    
    func startAnimating() {
        let rotation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.fromValue = 0
        rotation.toValue = CGFloat.pi * 2
        rotation.duration = 1.5
        rotation.repeatCount = .infinity
        ringLayer.add(rotation, forKey: "rotation")
        
        let glowRotation = CABasicAnimation(keyPath: "transform.rotation.z")
        glowRotation.fromValue = 0
        glowRotation.toValue = -CGFloat.pi * 2
        glowRotation.duration = 2.0
        glowRotation.repeatCount = .infinity
        glowRingLayer.add(glowRotation, forKey: "glowRotation")
        
        let pulse = CABasicAnimation(keyPath: "transform.scale")
        pulse.fromValue = 1.0
        pulse.toValue = 1.1
        pulse.duration = 0.8
        pulse.autoreverses = true
        pulse.repeatCount = .infinity
        pulsingLayer.add(pulse, forKey: "pulse")
        
        let opacity = CABasicAnimation(keyPath: "opacity")
        opacity.fromValue = 0.3
        opacity.toValue = 0.8
        opacity.duration = 0.8
        opacity.autoreverses = true
        opacity.repeatCount = .infinity
        pulsingLayer.add(opacity, forKey: "opacity")
    }
    
    func stopAnimating() {
        ringLayer.removeAllAnimations()
        glowRingLayer.removeAllAnimations()
        pulsingLayer.removeAllAnimations()
    }
}
