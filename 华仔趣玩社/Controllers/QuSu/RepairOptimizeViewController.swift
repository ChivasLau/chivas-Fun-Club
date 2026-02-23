import UIKit

class RepairOptimizeViewController: UIViewController {
    
    private var repairItems: [(String, String, Bool)] = [
        ("修复系统异常", "检测并修复系统问题", false),
        ("优化应用卡顿", "清理应用卡顿问题", false),
        ("修复网络问题", "检测网络连接状态", false),
        ("清理冗余进程", "关闭不必要的后台进程", false),
        ("优化存储空间", "整理碎片化存储", false),
        ("提升设备稳定性", "系统稳定性优化", false)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = Theme.gradientTop
        
        let headerView = UIView()
        headerView.backgroundColor = Theme.cardBackground.withAlphaComponent(0.6)
        headerView.layer.cornerRadius = Theme.cardCornerRadius
        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)
        
        let iconLabel = UILabel()
        iconLabel.text = "🔧"
        iconLabel.font = UIFont.systemFont(ofSize: 50)
        iconLabel.textAlignment = .center
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(iconLabel)
        
        let titleLabel = UILabel()
        titleLabel.text = "修复优化"
        titleLabel.font = Theme.Font.bold(size: 24)
        titleLabel.textColor = Theme.brightWhite
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(titleLabel)
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = "一键修复系统问题，提升设备性能"
        subtitleLabel.font = Theme.Font.regular(size: 14)
        subtitleLabel.textColor = Theme.mutedGray
        subtitleLabel.textAlignment = .center
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            iconLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 24),
            iconLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: iconLabel.bottomAnchor, constant: 12),
            titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            subtitleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -24)
        ])
        
        let listView = UIView()
        listView.backgroundColor = Theme.cardBackground.withAlphaComponent(0.6)
        listView.layer.cornerRadius = Theme.cardCornerRadius
        listView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(listView)
        
        let listStack = UIStackView()
        listStack.axis = .vertical
        listStack.spacing = 16
        listStack.translatesAutoresizingMaskIntoConstraints = false
        listView.addSubview(listStack)
        
        for item in repairItems {
            let itemView = createRepairItemView(title: item.0, desc: item.1)
            listStack.addArrangedSubview(itemView)
        }
        
        NSLayoutConstraint.activate([
            listStack.topAnchor.constraint(equalTo: listView.topAnchor, constant: 16),
            listStack.leadingAnchor.constraint(equalTo: listView.leadingAnchor, constant: 16),
            listStack.trailingAnchor.constraint(equalTo: listView.trailingAnchor, constant: -16),
            listStack.bottomAnchor.constraint(equalTo: listView.bottomAnchor, constant: -16)
        ])
        
        let repairButton = UIButton(type: .system)
        repairButton.setTitle("一键修复优化", for: .normal)
        repairButton.titleLabel?.font = Theme.Font.bold(size: 18)
        repairButton.setTitleColor(Theme.brightWhite, for: .normal)
        repairButton.backgroundColor = Theme.neonPink
        repairButton.layer.cornerRadius = 12
        repairButton.translatesAutoresizingMaskIntoConstraints = false
        repairButton.addTarget(self, action: #selector(startRepair), for: .touchUpInside)
        view.addSubview(repairButton)
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            listView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 16),
            listView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            listView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            repairButton.topAnchor.constraint(equalTo: listView.bottomAnchor, constant: 20),
            repairButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            repairButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            repairButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        title = "修复优化"
    }
    
    private func createRepairItemView(title: String, desc: String) -> UIView {
        let view = UIView()
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = Theme.Font.bold(size: 16)
        titleLabel.textColor = Theme.brightWhite
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        let descLabel = UILabel()
        descLabel.text = desc
        descLabel.font = Theme.Font.regular(size: 12)
        descLabel.textColor = Theme.mutedGray
        descLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descLabel)
        
        let statusLabel = UILabel()
        statusLabel.text = "○"
        statusLabel.font = Theme.Font.bold(size: 16)
        statusLabel.textColor = Theme.electricBlue
        statusLabel.textAlignment = .right
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(statusLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor),
            
            descLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            descLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            statusLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        return view
    }
    
    @objc private func startRepair(_ sender: UIButton) {
        sender.setTitle("修复中...", for: .normal)
        sender.backgroundColor = Theme.mutedGray
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            sender.setTitle("修复完成", for: .normal)
            sender.backgroundColor = Theme.electricBlue
            
            let alert = UIAlertController(title: "修复完成", message: "已优化系统，设备运行更稳定", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "好的", style: .default))
            self.present(alert, animated: true)
        }
    }
}
