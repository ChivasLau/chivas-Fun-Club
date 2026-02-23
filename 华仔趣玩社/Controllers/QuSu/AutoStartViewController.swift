import UIKit

class AutoStartViewController: UIViewController {
    
    private var apps: [(String, Bool, String)] = [
        ("系统应用", true, "系统核心应用"),
        ("邮件", false, "后台刷新"),
        ("地图", true, "定位服务"),
        ("音乐", false, "后台播放"),
        ("照片", true, "后台刷新"),
        ("日历", true, "同步提醒"),
        ("提醒事项", true, "后台同步"),
        ("天气", true, "后台更新")
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
        iconLabel.text = "🚫"
        iconLabel.font = UIFont.systemFont(ofSize: 40)
        iconLabel.textAlignment = .center
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(iconLabel)
        
        let titleLabel = UILabel()
        titleLabel.text = "自启动管理"
        titleLabel.font = Theme.Font.bold(size: 20)
        titleLabel.textColor = Theme.brightWhite
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(titleLabel)
        
        let descLabel = UILabel()
        descLabel.text = "禁止应用自启动可减少后台耗电"
        descLabel.font = Theme.Font.regular(size: 13)
        descLabel.textColor = Theme.mutedGray
        descLabel.textAlignment = .center
        descLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(descLabel)
        
        NSLayoutConstraint.activate([
            iconLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 20),
            iconLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: iconLabel.bottomAnchor, constant: 8),
            titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            
            descLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            descLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            descLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -20)
        ])
        
        let listView = UIView()
        listView.backgroundColor = Theme.cardBackground.withAlphaComponent(0.6)
        listView.layer.cornerRadius = Theme.cardCornerRadius
        listView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(listView)
        
        let listStack = UIStackView()
        listStack.axis = .vertical
        listStack.spacing = 12
        listStack.translatesAutoresizingMaskIntoConstraints = false
        listView.addSubview(listStack)
        
        for (index, app) in apps.enumerated() {
            let itemView = createAppItemView(name: app.0, enabled: app.1, desc: app.2, index: index)
            listStack.addArrangedSubview(itemView)
        }
        
        NSLayoutConstraint.activate([
            listStack.topAnchor.constraint(equalTo: listView.topAnchor, constant: 16),
            listStack.leadingAnchor.constraint(equalTo: listView.leadingAnchor, constant: 16),
            listStack.trailingAnchor.constraint(equalTo: listView.trailingAnchor, constant: -16),
            listStack.bottomAnchor.constraint(equalTo: listView.bottomAnchor, constant: -16)
        ])
        
        let tipLabel = UILabel()
        tipLabel.text = "⚠️ 提示：系统限制，部分设置需要在系统设置中修改"
        tipLabel.font = Theme.Font.regular(size: 12)
        tipLabel.textColor = Theme.mutedGray
        tipLabel.textAlignment = .center
        tipLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tipLabel)
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            listView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 16),
            listView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            listView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            tipLabel.topAnchor.constraint(equalTo: listView.bottomAnchor, constant: 16),
            tipLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        title = "自启动管理"
    }
    
    private func createAppItemView(name: String, enabled: Bool, desc: String, index: Int) -> UIView {
        let view = UIView()
        
        let nameLabel = UILabel()
        nameLabel.text = name
        nameLabel.font = Theme.Font.bold(size: 16)
        nameLabel.textColor = Theme.brightWhite
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        
        let descLabel = UILabel()
        descLabel.text = desc
        descLabel.font = Theme.Font.regular(size: 12)
        descLabel.textColor = Theme.mutedGray
        descLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descLabel)
        
        let switchView = UISwitch()
        switchView.isOn = enabled
        switchView.onTintColor = Theme.electricBlue
        switchView.tag = index
        switchView.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
        switchView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(switchView)
        
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            nameLabel.topAnchor.constraint(equalTo: view.topAnchor),
            
            descLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            descLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2),
            
            switchView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            switchView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        return view
    }
    
    @objc private func switchChanged(_ sender: UISwitch) {
        let index = sender.tag
        if index < apps.count {
            apps[index].1 = sender.isOn
        }
    }
}
