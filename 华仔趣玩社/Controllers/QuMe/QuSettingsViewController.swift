import UIKit

class QuSettingsViewController: UIViewController {
    
    private let apiTextField = UITextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadSavedKey()
    }
    
    override var prefersStatusBarHidden: Bool { true }
    
    private func setupUI() {
        view.backgroundColor = Theme.gradientTop
        
        let gradientBg = GradientBackgroundView(frame: view.bounds)
        gradientBg.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(gradientBg)
        
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        let titleLabel = UILabel()
        titleLabel.text = "⚙️ 系统设置"
        titleLabel.font = Theme.Font.bold(size: 28)
        titleLabel.textColor = Theme.brightWhite
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        let apiCard = UIView()
        apiCard.backgroundColor = Theme.cardBackground.withAlphaComponent(0.6)
        apiCard.layer.cornerRadius = 16
        apiCard.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(apiCard)
        
        let apiTitle = UILabel()
        apiTitle.text = "AGNES API 密钥"
        apiTitle.font = Theme.Font.bold(size: 18)
        apiTitle.textColor = Theme.brightWhite
        apiTitle.translatesAutoresizingMaskIntoConstraints = false
        apiCard.addSubview(apiTitle)
        
        let apiDesc = UILabel()
        apiDesc.text = "用于 趣AI 的图片、视频生成功能\n可在 https://agnes-ai.com 获取"
        apiDesc.font = Theme.Font.regular(size: 13)
        apiDesc.textColor = Theme.mutedGray
        apiDesc.numberOfLines = 0
        apiDesc.translatesAutoresizingMaskIntoConstraints = false
        apiCard.addSubview(apiDesc)
        
        apiTextField.attributedPlaceholder = NSAttributedString(string: "输入你的 Agnes API Key", attributes: [.foregroundColor: Theme.mutedGray])
        apiTextField.font = Theme.Font.regular(size: 15)
        apiTextField.textColor = Theme.brightWhite
        apiTextField.backgroundColor = Theme.cardBackground.withAlphaComponent(0.5)
        apiTextField.layer.cornerRadius = 12
        apiTextField.borderStyle = .none
        apiTextField.autocorrectionType = .no
        apiTextField.autocapitalizationType = .none
        apiTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
        apiTextField.leftViewMode = .always
        apiTextField.translatesAutoresizingMaskIntoConstraints = false
        apiCard.addSubview(apiTextField)
        
        let saveButton = UIButton(type: .system)
        saveButton.setTitle("💾 保存", for: .normal)
        saveButton.titleLabel?.font = Theme.Font.bold(size: 16)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.backgroundColor = Theme.electricBlue
        saveButton.layer.cornerRadius = 14
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.addTarget(self, action: #selector(saveKey), for: .touchUpInside)
        apiCard.addSubview(saveButton)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            apiCard.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            apiCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            apiCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            apiTitle.topAnchor.constraint(equalTo: apiCard.topAnchor, constant: 20),
            apiTitle.leadingAnchor.constraint(equalTo: apiCard.leadingAnchor, constant: 16),
            apiTitle.trailingAnchor.constraint(equalTo: apiCard.trailingAnchor, constant: -16),
            
            apiDesc.topAnchor.constraint(equalTo: apiTitle.bottomAnchor, constant: 6),
            apiDesc.leadingAnchor.constraint(equalTo: apiCard.leadingAnchor, constant: 16),
            apiDesc.trailingAnchor.constraint(equalTo: apiCard.trailingAnchor, constant: -16),
            
            apiTextField.topAnchor.constraint(equalTo: apiDesc.bottomAnchor, constant: 12),
            apiTextField.leadingAnchor.constraint(equalTo: apiCard.leadingAnchor, constant: 16),
            apiTextField.trailingAnchor.constraint(equalTo: apiCard.trailingAnchor, constant: -16),
            apiTextField.heightAnchor.constraint(equalToConstant: 44),
            
            saveButton.topAnchor.constraint(equalTo: apiTextField.bottomAnchor, constant: 16),
            saveButton.leadingAnchor.constraint(equalTo: apiCard.leadingAnchor, constant: 16),
            saveButton.trailingAnchor.constraint(equalTo: apiCard.trailingAnchor, constant: -16),
            saveButton.heightAnchor.constraint(equalToConstant: 44),
            saveButton.bottomAnchor.constraint(equalTo: apiCard.bottomAnchor, constant: -20),
        ])
        
        scrollView.keyboardDismissMode = .onDrag
    }
    
    private func loadSavedKey() {
        let saved = UserDefaults.standard.string(forKey: "agnes_api_key") ?? ""
        if saved.isEmpty {
            let defaultKey = "sk-C7SNm9gXYgUUxA6jlgB2iIve2lMbdeopLu4cQz56685iA8eX"
            apiTextField.text = defaultKey
            UserDefaults.standard.set(defaultKey, forKey: "agnes_api_key")
        } else {
            apiTextField.text = saved
        }
    }
    
    @objc private func saveKey() {
        let key = apiTextField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        guard !key.isEmpty else {
            let alert = UIAlertController(title: "提示", message: "请输入 API Key", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "好的", style: .default))
            present(alert, animated: true)
            return
        }
        UserDefaults.standard.set(key, forKey: "agnes_api_key")
        let alert = UIAlertController(title: "✅ 已保存", message: "AGNES API 密钥已保存成功", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "好的", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}
