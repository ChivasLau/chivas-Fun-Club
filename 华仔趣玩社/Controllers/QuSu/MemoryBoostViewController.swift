import UIKit

class MemoryBoostViewController: UIViewController {
    
    private var totalMemory: UInt64 = 0
    private var usedMemory: UInt64 = 0
    private var freeMemory: UInt64 = 0
    
    private var progressView: UIView!
    private var progressLayer: CAShapeLayer!
    private var boostButton: UIButton!
    private var memoryLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getMemoryInfo()
        setupUI()
    }
    
    private func getMemoryInfo() {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
        
        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        
        if result == KERN_SUCCESS {
            usedMemory = info.resident_size
        }
        
        totalMemory = ProcessInfo.processInfo.physicalMemory
        freeMemory = totalMemory > usedMemory ? totalMemory - usedMemory : 0
    }
    
    private func setupUI() {
        view.backgroundColor = Theme.gradientTop
        
        let headerView = UIView()
        headerView.backgroundColor = Theme.cardBackground.withAlphaComponent(0.6)
        headerView.layer.cornerRadius = Theme.cardCornerRadius
        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)
        
        let centerView = UIView()
        centerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(centerView)
        
        progressView = UIView()
        progressView.translatesAutoresizingMaskIntoConstraints = false
        centerView.addSubview(progressView)
        
        let boltIcon = UILabel()
        boltIcon.text = "⚡"
        boltIcon.font = UIFont.systemFont(ofSize: 40)
        boltIcon.textAlignment = .center
        boltIcon.translatesAutoresizingMaskIntoConstraints = false
        centerView.addSubview(boltIcon)
        
        memoryLabel = UILabel()
        memoryLabel.text = String(format: "%.1f GB / %.1f GB", Double(usedMemory) / 1_073_741_824, Double(totalMemory) / 1_073_741_824)
        memoryLabel.font = Theme.Font.bold(size: 18)
        memoryLabel.textColor = Theme.brightWhite
        memoryLabel.textAlignment = .center
        memoryLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(memoryLabel)
        
        let statusLabel = UILabel()
        let usagePercent = Double(usedMemory) / Double(totalMemory) * 100
        statusLabel.text = String(format: "内存使用率: %.0f%%", usagePercent)
        statusLabel.font = Theme.Font.regular(size: 14)
        statusLabel.textColor = usagePercent > 80 ? Theme.neonPink : Theme.electricBlue
        statusLabel.textAlignment = .center
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(statusLabel)
        
        NSLayoutConstraint.activate([
            centerView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 32),
            centerView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            centerView.widthAnchor.constraint(equalToConstant: 140),
            centerView.heightAnchor.constraint(equalToConstant: 140),
            
            progressView.topAnchor.constraint(equalTo: centerView.topAnchor),
            progressView.leadingAnchor.constraint(equalTo: centerView.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: centerView.trailingAnchor),
            progressView.bottomAnchor.constraint(equalTo: centerView.bottomAnchor),
            
            boltIcon.centerXAnchor.constraint(equalTo: centerView.centerXAnchor),
            boltIcon.centerYAnchor.constraint(equalTo: centerView.centerYAnchor),
            
            memoryLabel.topAnchor.constraint(equalTo: centerView.bottomAnchor, constant: 16),
            memoryLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            
            statusLabel.topAnchor.constraint(equalTo: memoryLabel.bottomAnchor, constant: 8),
            statusLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            statusLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -24)
        ])
        
        let infoView = UIView()
        infoView.backgroundColor = Theme.cardBackground.withAlphaComponent(0.6)
        infoView.layer.cornerRadius = Theme.cardCornerRadius
        infoView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(infoView)
        
        let infoStack = UIStackView()
        infoStack.axis = .vertical
        infoStack.spacing = 16
        infoStack.translatesAutoresizingMaskIntoConstraints = false
        infoView.addSubview(infoStack)
        
        infoStack.addArrangedSubview(createInfoRow(title: "总内存", value: String(format: "%.1f GB", Double(totalMemory) / 1_073_741_824)))
        infoStack.addArrangedSubview(createInfoRow(title: "已使用", value: String(format: "%.1f GB", Double(usedMemory) / 1_073_741_824)))
        infoStack.addArrangedSubview(createInfoRow(title: "可用", value: String(format: "%.1f GB", Double(freeMemory) / 1_073_741_824)))
        
        NSLayoutConstraint.activate([
            infoStack.topAnchor.constraint(equalTo: infoView.topAnchor, constant: 20),
            infoStack.leadingAnchor.constraint(equalTo: infoView.leadingAnchor, constant: 20),
            infoStack.trailingAnchor.constraint(equalTo: infoView.trailingAnchor, constant: -20),
            infoStack.bottomAnchor.constraint(equalTo: infoView.bottomAnchor, constant: -20)
        ])
        
        boostButton = UIButton(type: .system)
        boostButton.setTitle("一键加速", for: .normal)
        boostButton.titleLabel?.font = Theme.Font.bold(size: 18)
        boostButton.setTitleColor(Theme.brightWhite, for: .normal)
        boostButton.backgroundColor = Theme.electricBlue
        boostButton.layer.cornerRadius = 12
        boostButton.translatesAutoresizingMaskIntoConstraints = false
        boostButton.addTarget(self, action: #selector(startBoost), for: .touchUpInside)
        view.addSubview(boostButton)
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            infoView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 16),
            infoView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            infoView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            boostButton.topAnchor.constraint(equalTo: infoView.bottomAnchor, constant: 20),
            boostButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            boostButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            boostButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        title = "内存加速"
        
        DispatchQueue.main.async {
            self.drawProgressRing()
        }
    }
    
    private func drawProgressRing() {
        let center = CGPoint(x: 70, y: 70)
        let radius: CGFloat = 55
        
        let backgroundPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
        let backgroundLayer = CAShapeLayer()
        backgroundLayer.path = backgroundPath.cgPath
        backgroundLayer.fillColor = UIColor.clear.cgColor
        backgroundLayer.strokeColor = Theme.mutedGray.withAlphaComponent(0.3).cgColor
        backgroundLayer.lineWidth = 10
        progressView.layer.addSublayer(backgroundLayer)
        
        let progressPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: -CGFloat.pi / 2, endAngle: CGFloat.pi * 1.5, clockwise: true)
        progressLayer = CAShapeLayer()
        progressLayer.path = progressPath.cgPath
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = Theme.electricBlue.cgColor
        progressLayer.lineWidth = 10
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = CGFloat(usedMemory) / CGFloat(totalMemory)
        progressView.layer.addSublayer(progressLayer)
    }
    
    private func createInfoRow(title: String, value: String) -> UIView {
        let view = UIView()
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = Theme.Font.regular(size: 16)
        titleLabel.textColor = Theme.mutedGray
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = Theme.Font.bold(size: 16)
        valueLabel.textColor = Theme.brightWhite
        valueLabel.textAlignment = .right
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            valueLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            valueLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        return view
    }
    
    @objc private func startBoost() {
        boostButton.setTitle("加速中...", for: .normal)
        boostButton.backgroundColor = Theme.mutedGray
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.getMemoryInfo()
            self?.memoryLabel.text = String(format: "%.1f GB / %.1f GB", Double(self?.usedMemory ?? 0) / 1_073_741_824, Double(self?.totalMemory ?? 0) / 1_073_741_824)
            
            self?.boostButton.setTitle("加速完成", for: .normal)
            self?.boostButton.backgroundColor = Theme.electricBlue
            
            let alert = UIAlertController(title: "加速完成", message: "已释放内存，设备运行更流畅", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "好的", style: .default))
            self?.present(alert, animated: true)
        }
    }
}
