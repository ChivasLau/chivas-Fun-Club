import UIKit

class QuSearchViewController: UIViewController {
    
    private var searchHistory: [String] = ["华仔趣玩社", "iOS工具", "免费游戏"]
    private var isSideBarOpen = false
    
    private var sideBarView: UIView!
    private var dimView: UIView!
    private var searchTextField: UITextField!
    private var historyStackView: UIStackView!
    
    private let searchTools: [(String, String, Bool, String?)] = [
        ("短剧搜索", "短搜搜", true, nil),
        ("视频搜索", "影迷搜", true, nil),
        ("视频搜索", "片搜搜", true, nil),
        ("文档搜索", "豆丁搜", true, nil),
        ("文档搜索", "智库搜", true, nil),
        ("云盘搜索", "盘搜搜", true, nil),
        ("云盘搜索", "云盘搜", true, nil)
    ]
    
    private var currentCategory = "全部"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = Theme.gradientTop
        
        let searchContainer = UIView()
        searchContainer.backgroundColor = Theme.cardBackground.withAlphaComponent(0.6)
        searchContainer.layer.cornerRadius = Theme.cornerRadius
        searchContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchContainer)
        
        searchTextField = UITextField()
        searchTextField.placeholder = "搜索你感兴趣的内容..."
        searchTextField.font = Theme.Font.regular(size: 16)
        searchTextField.textColor = Theme.brightWhite
        searchTextField.attributedPlaceholder = NSAttributedString(string: "搜索你感兴趣的内容...", attributes: [.foregroundColor: Theme.mutedGray])
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        searchTextField.returnKeyType = .search
        searchTextField.delegate = self
        searchContainer.addSubview(searchTextField)
        
        let categoryButton = UIButton(type: .system)
        categoryButton.setTitle("☰", for: .normal)
        categoryButton.titleLabel?.font = Theme.Font.bold(size: 20)
        categoryButton.setTitleColor(Theme.electricBlue, for: .normal)
        categoryButton.translatesAutoresizingMaskIntoConstraints = false
        categoryButton.addTarget(self, action: #selector(toggleSideBar), for: .touchUpInside)
        searchContainer.addSubview(categoryButton)
        
        let searchButton = UIButton(type: .system)
        searchButton.setTitle("搜索", for: .normal)
        searchButton.titleLabel?.font = Theme.Font.bold(size: 16)
        searchButton.setTitleColor(Theme.brightWhite, for: .normal)
        searchButton.backgroundColor = Theme.electricBlue
        searchButton.layer.cornerRadius = 8
        searchButton.translatesAutoresizingMaskIntoConstraints = false
        searchButton.addTarget(self, action: #selector(performSearch), for: .touchUpInside)
        searchContainer.addSubview(searchButton)
        
        NSLayoutConstraint.activate([
            searchTextField.leadingAnchor.constraint(equalTo: searchContainer.leadingAnchor, constant: 16),
            searchTextField.centerYAnchor.constraint(equalTo: searchContainer.centerYAnchor),
            
            categoryButton.leadingAnchor.constraint(equalTo: searchTextField.leadingAnchor),
            categoryButton.centerYAnchor.constraint(equalTo: searchContainer.centerYAnchor),
            categoryButton.widthAnchor.constraint(equalToConstant: 30),
            
            searchTextField.leadingAnchor.constraint(equalTo: categoryButton.trailingAnchor, constant: 8),
            
            searchButton.trailingAnchor.constraint(equalTo: searchContainer.trailingAnchor, constant: -12),
            searchButton.centerYAnchor.constraint(equalTo: searchContainer.centerYAnchor),
            searchButton.widthAnchor.constraint(equalToConstant: 60),
            searchButton.heightAnchor.constraint(equalToConstant: 36)
        ])
        
        let historyLabel = UILabel()
        historyLabel.text = "搜索历史"
        historyLabel.font = Theme.Font.bold(size: 18)
        historyLabel.textColor = Theme.brightWhite
        historyLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(historyLabel)
        
        let clearButton = UIButton(type: .system)
        clearButton.setTitle("清空", for: .normal)
        clearButton.titleLabel?.font = Theme.Font.regular(size: 14)
        clearButton.setTitleColor(Theme.mutedGray, for: .normal)
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        clearButton.addTarget(self, action: #selector(clearHistory), for: .touchUpInside)
        view.addSubview(clearButton)
        
        let historyContainer = UIView()
        historyContainer.backgroundColor = Theme.cardBackground.withAlphaComponent(0.6)
        historyContainer.layer.cornerRadius = Theme.cardCornerRadius
        historyContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(historyContainer)
        
        historyStackView = UIStackView()
        historyStackView.axis = .vertical
        historyStackView.spacing = 12
        historyStackView.translatesAutoresizingMaskIntoConstraints = false
        historyContainer.addSubview(historyStackView)
        
        updateHistoryViews()
        
        NSLayoutConstraint.activate([
            historyStackView.topAnchor.constraint(equalTo: historyContainer.topAnchor, constant: 16),
            historyStackView.leadingAnchor.constraint(equalTo: historyContainer.leadingAnchor, constant: 16),
            historyStackView.trailingAnchor.constraint(equalTo: historyContainer.trailingAnchor, constant: -16),
            historyStackView.bottomAnchor.constraint(equalTo: historyContainer.bottomAnchor, constant: -16)
        ])
        
        NSLayoutConstraint.activate([
            searchContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            searchContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            searchContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            searchContainer.heightAnchor.constraint(equalToConstant: 50),
            
            historyLabel.topAnchor.constraint(equalTo: searchContainer.bottomAnchor, constant: 24),
            historyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            clearButton.centerYAnchor.constraint(equalTo: historyLabel.centerYAnchor),
            clearButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            historyContainer.topAnchor.constraint(equalTo: historyLabel.bottomAnchor, constant: 12),
            historyContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            historyContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        setupSideBar()
        
        title = "趣搜索"
    }
    
    private func updateHistoryViews() {
        for subview in historyStackView.arrangedSubviews {
            subview.removeFromSuperview()
        }
        
        for keyword in searchHistory {
            let itemView = createHistoryItem(keyword: keyword)
            historyStackView.addArrangedSubview(itemView)
        }
    }
    
    private func createHistoryItem(keyword: String) -> UIView {
        let view = UIView()
        
        let iconLabel = UILabel()
        iconLabel.text = "🕐"
        iconLabel.font = UIFont.systemFont(ofSize: 16)
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(iconLabel)
        
        let keywordLabel = UILabel()
        keywordLabel.text = keyword
        keywordLabel.font = Theme.Font.regular(size: 16)
        keywordLabel.textColor = Theme.brightWhite
        keywordLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(keywordLabel)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(historyItemTapped(_:)))
        view.addGestureRecognizer(tapGesture)
        view.isUserInteractionEnabled = true
        view.tag = searchHistory.firstIndex(of: keyword) ?? 0
        
        NSLayoutConstraint.activate([
            iconLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            iconLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            keywordLabel.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: 12),
            keywordLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        return view
    }
    
    private func setupSideBar() {
        dimView = UIView()
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        dimView.alpha = 0
        dimView.translatesAutoresizingMaskIntoConstraints = false
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideSideBar))
        dimView.addGestureRecognizer(tapGesture)
        view.addSubview(dimView)
        
        NSLayoutConstraint.activate([
            dimView.topAnchor.constraint(equalTo: view.topAnchor),
            dimView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dimView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        sideBarView = UIView()
        sideBarView.backgroundColor = Theme.cardBackground
        sideBarView.layer.shadowColor = Theme.neonPink.cgColor
        sideBarView.layer.shadowOffset = CGSize(width: -4, height: 0)
        sideBarView.layer.shadowOpacity = 0.3
        sideBarView.layer.shadowRadius = 10
        sideBarView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sideBarView)
        
        let titleLabel = UILabel()
        titleLabel.text = "搜索工具"
        titleLabel.font = Theme.Font.bold(size: 20)
        titleLabel.textColor = Theme.brightWhite
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        sideBarView.addSubview(titleLabel)
        
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        sideBarView.addSubview(scrollView)
        
        let categoryStack = UIStackView()
        categoryStack.axis = .vertical
        categoryStack.spacing = 8
        categoryStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(categoryStack)
        
        var lastCategory = ""
        for (index, tool) in searchTools.enumerated() {
            if tool.0 != lastCategory {
                lastCategory = tool.0
                let categoryLabel = UILabel()
                categoryLabel.text = "— \(tool.0) —"
                categoryLabel.font = Theme.Font.bold(size: 14)
                categoryLabel.textColor = Theme.neonPink
                categoryLabel.translatesAutoresizingMaskIntoConstraints = false
                categoryStack.addArrangedSubview(categoryLabel)
            }
            let itemView = createSearchToolItem(name: tool.1, enabled: tool.2, index: index)
            categoryStack.addArrangedSubview(itemView)
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: sideBarView.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: sideBarView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: sideBarView.trailingAnchor, constant: -20),
            
            scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            scrollView.leadingAnchor.constraint(equalTo: sideBarView.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: sideBarView.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: sideBarView.bottomAnchor, constant: -20),
            
            categoryStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 8),
            categoryStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            categoryStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            categoryStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -8),
            categoryStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        ])
        
        NSLayoutConstraint.activate([
            sideBarView.topAnchor.constraint(equalTo: view.topAnchor),
            sideBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 280),
            sideBarView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            sideBarView.widthAnchor.constraint(equalToConstant: 280)
        ])
    }
    
    private func createSearchToolItem(name: String, enabled: Bool, index: Int) -> UIView {
        let view = UIView()
        
        let nameLabel = UILabel()
        nameLabel.text = name
        nameLabel.font = Theme.Font.bold(size: 16)
        nameLabel.textColor = enabled ? Theme.brightWhite : Theme.mutedGray
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        
        if enabled {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(searchToolTapped(_:)))
            view.addGestureRecognizer(tapGesture)
            view.isUserInteractionEnabled = true
            view.tag = index
        } else {
            let badgeLabel = UILabel()
            badgeLabel.text = "待开发"
            badgeLabel.font = Theme.Font.regular(size: 12)
            badgeLabel.textColor = Theme.mutedGray
            badgeLabel.backgroundColor = Theme.cardBackground
            badgeLabel.layer.cornerRadius = 4
            badgeLabel.clipsToBounds = true
            badgeLabel.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(badgeLabel)
            
            NSLayoutConstraint.activate([
                badgeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                badgeLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
        }
        
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            nameLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        return view
    }
    
    @objc private func toggleSideBar() {
        if isSideBarOpen {
            hideSideBar()
        } else {
            showSideBar()
        }
    }
    
    private func showSideBar() {
        isSideBarOpen = true
        UIView.animate(withDuration: 0.3) {
            self.sideBarView.transform = CGAffineTransform(translationX: -280, y: 0)
            self.dimView.alpha = 1
        }
    }
    
    @objc private func hideSideBar() {
        isSideBarOpen = false
        UIView.animate(withDuration: 0.3) {
            self.sideBarView.transform = .identity
            self.dimView.alpha = 0
        }
    }
    
    @objc private func searchToolTapped(_ gesture: UITapGestureRecognizer) {
        guard let index = gesture.view?.tag else { return }
        let tool = searchTools[index]
        hideSideBar()
        
        let alert = UIAlertController(title: tool.1, message: "正在使用「\(tool.1)」搜索...", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "好的", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func performSearch() {
        guard let keyword = searchTextField.text, !keyword.isEmpty else { return }
        
        if !searchHistory.contains(keyword) {
            searchHistory.insert(keyword, at: 0)
            if searchHistory.count > 10 {
                searchHistory.removeLast()
            }
            updateHistoryViews()
        }
        
        let alert = UIAlertController(title: "搜索", message: "正在搜索「\(keyword)」...", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "好的", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func historyItemTapped(_ gesture: UITapGestureRecognizer) {
        guard let index = gesture.view?.tag, index < searchHistory.count else { return }
        searchTextField.text = searchHistory[index]
        performSearch()
    }
    
    @objc private func clearHistory() {
        searchHistory.removeAll()
        updateHistoryViews()
    }
}

extension QuSearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        performSearch()
        return true
    }
}
