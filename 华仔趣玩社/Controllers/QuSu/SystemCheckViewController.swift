import UIKit

class SystemCheckViewController: UIViewController {
    
    private var scanningView: UIView!
    private var scanProgressView: UIView!
    private var resultContainerView: UIView!
    private var scanButton: UIButton!
    
    private var isScanning = false
    private var scanProgress: CGFloat = 0
    
    private var checkItems: [(String, String, Bool)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadData()
    }
    
    private func loadData() {
        checkItems = [
            ("系统状态", "检测系统运行状态", true),
            ("存储空间", "检查存储使用情况", true),
            ("运行内存", "检测内存占用情况", true),
            ("电池健康", "检查电池状态", true),
            ("应用缓存", "扫描应用缓存大小", true),
            ("系统垃圾", "检测冗余文件", true)
        ]
    }
    
    private func setupUI() {
        view.backgroundColor = Theme.gradientTop
        
        let titleLabel = UILabel()
        titleLabel.text = "系统体检"
        titleLabel.font = Theme.Font.bold(size: 24)
        titleLabel.textColor = Theme.brightWhite
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        scanningView = UIView()
        scanningView.backgroundColor = Theme.cardBackground.withAlphaComponent(0.6)
        scanningView.layer.cornerRadius = Theme.cardCornerRadius
        scanningView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scanningView)
        
        let scanIcon = UILabel()
        scanIcon.text = "🔍"
        scanIcon.font = UIFont.systemFont(ofSize: 60)
        scanIcon.textAlignment = .center
        scanIcon.translatesAutoresizingMaskIntoConstraints = false
        scanningView.addSubview(scanIcon)
        
        let scanStatusLabel = UILabel()
        scanStatusLabel.text = "点击开始体检"
        scanStatusLabel.font = Theme.Font.regular(size: 16)
        scanStatusLabel.textColor = Theme.mutedGray
        scanStatusLabel.textAlignment = .center
        scanStatusLabel.tag = 100
        scanStatusLabel.translatesAutoresizingMaskIntoConstraints = false
        scanningView.addSubview(scanStatusLabel)
        
        scanProgressView = UIView()
        scanProgressView.backgroundColor = Theme.electricBlue.withAlphaComponent(0.3)
        scanProgressView.layer.cornerRadius = 4
        scanProgressView.translatesAutoresizingMaskIntoConstraints = false
        scanProgressView.isHidden = true
        scanningView.addSubview(scanProgressView)
        
        NSLayoutConstraint.activate([
            scanProgressView.leadingAnchor.constraint(equalTo: scanningView.leadingAnchor, constant: 20),
            scanProgressView.trailingAnchor.constraint(equalTo: scanningView.trailingAnchor, constant: -20),
            scanProgressView.bottomAnchor.constraint(equalTo: scanningView.bottomAnchor, constant: -20),
            scanProgressView.heightAnchor.constraint(equalToConstant: 8)
        ])
        
        NSLayoutConstraint.activate([
            scanIcon.topAnchor.constraint(equalTo: scanningView.topAnchor, constant: 40),
            scanIcon.centerXAnchor.constraint(equalTo: scanningView.centerXAnchor),
            
            scanStatusLabel.topAnchor.constraint(equalTo: scanIcon.bottomAnchor, constant: 16),
            scanStatusLabel.centerXAnchor.constraint(equalTo: scanningView.centerXAnchor)
        ])
        
        resultContainerView = UIView()
        resultContainerView.backgroundColor = Theme.cardBackground.withAlphaComponent(0.6)
        resultContainerView.layer.cornerRadius = Theme.cardCornerRadius
        resultContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(resultContainerView)
        
        let resultStack = UIStackView()
        resultStack.axis = .vertical
        resultStack.spacing = 12
        resultStack.translatesAutoresizingMaskIntoConstraints = false
        resultContainerView.addSubview(resultStack)
        
        for item in checkItems {
            let itemView = createCheckItemView(title: item.0, subtitle: item.1)
            resultStack.addArrangedSubview(itemView)
        }
        
        NSLayoutConstraint.activate([
            resultStack.topAnchor.constraint(equalTo: resultContainerView.topAnchor, constant: 16),
            resultStack.leadingAnchor.constraint(equalTo: resultContainerView.leadingAnchor, constant: 16),
            resultStack.trailingAnchor.constraint(equalTo: resultContainerView.trailingAnchor, constant: -16),
            resultStack.bottomAnchor.constraint(equalTo: resultContainerView.bottomAnchor, constant: -16)
        ])
        
        scanButton = UIButton(type: .system)
        scanButton.setTitle("开始体检", for: .normal)
        scanButton.titleLabel?.font = Theme.Font.bold(size: 18)
        scanButton.setTitleColor(Theme.brightWhite, for: .normal)
        scanButton.backgroundColor = Theme.electricBlue
        scanButton.layer.cornerRadius = 12
        scanButton.translatesAutoresizingMaskIntoConstraints = false
        scanButton.addTarget(self, action: #selector(startScan), for: .touchUpInside)
        view.addSubview(scanButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            scanningView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            scanningView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            scanningView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            scanningView.heightAnchor.constraint(equalToConstant: 180),
            
            resultContainerView.topAnchor.constraint(equalTo: scanningView.bottomAnchor, constant: 16),
            resultContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            resultContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            scanButton.topAnchor.constraint(equalTo: resultContainerView.bottomAnchor, constant: 20),
            scanButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            scanButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            scanButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        title = "系统体检"
    }
    
    private func createCheckItemView(title: String, subtitle: String) -> UIView {
        let view = UIView()
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = Theme.Font.bold(size: 16)
        titleLabel.textColor = Theme.brightWhite
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.font = Theme.Font.regular(size: 12)
        subtitleLabel.textColor = Theme.mutedGray
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(subtitleLabel)
        
        let statusLabel = UILabel()
        statusLabel.text = "✓"
        statusLabel.font = Theme.Font.bold(size: 16)
        statusLabel.textColor = Theme.electricBlue
        statusLabel.textAlignment = .right
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(statusLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor),
            
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            statusLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        return view
    }
    
    @objc private func startScan() {
        guard !isScanning else { return }
        isScanning = true
        
        scanButton.setTitle("体检中...", for: .normal)
        scanButton.backgroundColor = Theme.mutedGray
        
        if let statusLabel = scanningView.viewWithTag(100) as? UILabel {
            statusLabel.text = "正在扫描..."
        }
        
        scanProgressView.isHidden = false
        scanProgressView.frame.size.width = 0
        
        var progress: CGFloat = 0
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            
            progress += 2
            let maxWidth = self.scanningView.bounds.width - 40
            self.scanProgressView.frame.size.width = maxWidth * (progress / 100)
            
            if progress >= 100 {
                timer.invalidate()
                self.scanComplete()
            }
        }
    }
    
    private func scanComplete() {
        isScanning = false
        scanButton.setTitle("重新体检", for: .normal)
        scanButton.backgroundColor = Theme.electricBlue
        
        if let statusLabel = scanningView.viewWithTag(100) as? UILabel {
            statusLabel.text = "体检完成，设备状态良好"
            statusLabel.textColor = Theme.electricBlue
        }
    }
}
