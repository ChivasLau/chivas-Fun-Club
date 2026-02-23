import UIKit

class JunkCleanViewController: UIViewController {
    
    private var junkItems: [(String, String, String)] = [
        ("应用缓存", "256 MB", "各应用产生的临时数据"),
        ("系统垃圾", "128 MB", "系统运行产生的冗余文件"),
        ("安装包", "512 MB", "下载后未清理的安装包"),
        ("日志文件", "64 MB", "应用和系统日志"),
        ("临时文件", "96 MB", "各类临时数据")
    ]
    
    private var totalSize: String = "1.0 GB"
    private var cleanButton: UIButton!
    
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
        
        let trashIcon = UILabel()
        trashIcon.text = "🗑️"
        trashIcon.font = UIFont.systemFont(ofSize: 50)
        trashIcon.textAlignment = .center
        trashIcon.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(trashIcon)
        
        let sizeLabel = UILabel()
        sizeLabel.text = totalSize
        sizeLabel.font = Theme.Font.bold(size: 36)
        sizeLabel.textColor = Theme.neonPink
        sizeLabel.textAlignment = .center
        sizeLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(sizeLabel)
        
        let descLabel = UILabel()
        descLabel.text = "可清理垃圾"
        descLabel.font = Theme.Font.regular(size: 14)
        descLabel.textColor = Theme.mutedGray
        descLabel.textAlignment = .center
        descLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(descLabel)
        
        NSLayoutConstraint.activate([
            trashIcon.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 24),
            trashIcon.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            
            sizeLabel.topAnchor.constraint(equalTo: trashIcon.bottomAnchor, constant: 12),
            sizeLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            
            descLabel.topAnchor.constraint(equalTo: sizeLabel.bottomAnchor, constant: 4),
            descLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            descLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -24)
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
        
        for item in junkItems {
            let itemView = createJunkItemView(title: item.0, size: item.1, desc: item.2)
            listStack.addArrangedSubview(itemView)
        }
        
        NSLayoutConstraint.activate([
            listStack.topAnchor.constraint(equalTo: listView.topAnchor, constant: 16),
            listStack.leadingAnchor.constraint(equalTo: listView.leadingAnchor, constant: 16),
            listStack.trailingAnchor.constraint(equalTo: listView.trailingAnchor, constant: -16),
            listStack.bottomAnchor.constraint(equalTo: listView.bottomAnchor, constant: -16)
        ])
        
        cleanButton = UIButton(type: .system)
        cleanButton.setTitle("一键清理", for: .normal)
        cleanButton.titleLabel?.font = Theme.Font.bold(size: 18)
        cleanButton.setTitleColor(Theme.brightWhite, for: .normal)
        cleanButton.backgroundColor = Theme.neonPink
        cleanButton.layer.cornerRadius = 12
        cleanButton.translatesAutoresizingMaskIntoConstraints = false
        cleanButton.addTarget(self, action: #selector(startClean), for: .touchUpInside)
        view.addSubview(cleanButton)
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            listView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 16),
            listView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            listView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            cleanButton.topAnchor.constraint(equalTo: listView.bottomAnchor, constant: 20),
            cleanButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            cleanButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            cleanButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        title = "垃圾清理"
    }
    
    private func createJunkItemView(title: String, size: String, desc: String) -> UIView {
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
        
        let sizeLabel = UILabel()
        sizeLabel.text = size
        sizeLabel.font = Theme.Font.bold(size: 16)
        sizeLabel.textColor = Theme.neonPink
        sizeLabel.textAlignment = .right
        sizeLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sizeLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor),
            
            descLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            descLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            
            sizeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            sizeLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        return view
    }
    
    @objc private func startClean() {
        cleanButton.setTitle("清理中...", for: .normal)
        cleanButton.backgroundColor = Theme.mutedGray
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.cleanButton.setTitle("清理完成", for: .normal)
            self?.cleanButton.backgroundColor = Theme.electricBlue
            
            let alert = UIAlertController(title: "清理完成", message: "已清理 \(self?.totalSize ?? "") 垃圾文件", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "好的", style: .default))
            self?.present(alert, animated: true)
        }
    }
}
