import UIKit

class QuSearchViewController: UIViewController {
    
    private var searchHistory: [String] = ["华仔趣玩社", "iOS工具", "免费游戏"]
    private var isSideBarOpen = false
    
    private var sideBarView: UIView!
    private var dimView: UIView!
    private var searchTextField: UITextField!
    private var historyStackView: UIStackView!
    private var scrollView: UIScrollView!
    
    private let searchTools: [(category: String, name: String, icon: String, color: UIColor)] = [
        ("短剧搜索", "短搜搜", "🎬", UIColor(hex: "FF6B6B")),
        ("视频搜索", "影迷搜", "🎥", UIColor(hex: "4ECDC4")),
        ("视频搜索", "片搜搜", "📺", UIColor(hex: "45B7D1")),
        ("文档搜索", "豆丁搜", "📄", UIColor(hex: "96CEB4")),
        ("文档搜索", "智库搜", "📚", UIColor(hex: "FFEAA7")),
        ("云盘搜索", "盘搜搜", "💾", UIColor(hex: "DDA0DD")),
        ("云盘搜索", "云盘搜", "☁️", UIColor(hex: "98D8C8"))
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    private func setupUI() {
        let gradientBg = GradientBackgroundView(frame: view.bounds)
        gradientBg.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(gradientBg)
        
        let titleLabel = UILabel()
        titleLabel.text = "🔍 趣搜索"
        titleLabel.font = Theme.Font.bold(size: 28)
        titleLabel.textColor = Theme.brightWhite
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        let searchContainer = UIView()
        searchContainer.backgroundColor = Theme.cardBackground.withAlphaComponent(0.8)
        searchContainer.layer.cornerRadius = Theme.cornerRadius
        searchContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchContainer)
        
        let menuButton = UIButton(type: .system)
        menuButton.setTitle("☰", for: .normal)
        menuButton.titleLabel?.font = Theme.Font.bold(size: 24)
        menuButton.setTitleColor(Theme.electricBlue, for: .normal)
        menuButton.translatesAutoresizingMaskIntoConstraints = false
        menuButton.addTarget(self, action: #selector(toggleSideBar), for: .touchUpInside)
        searchContainer.addSubview(menuButton)
        
        searchTextField = UITextField()
        searchTextField.placeholder = "搜索你感兴趣的内容..."
        searchTextField.font = Theme.Font.regular(size: 16)
        searchTextField.textColor = Theme.brightWhite
        searchTextField.attributedPlaceholder = NSAttributedString(
            string: "搜索你感兴趣的内容...",
            attributes: [.foregroundColor: Theme.mutedGray]
        )
        searchTextField.returnKeyType = .search
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        searchTextField.delegate = self
        searchContainer.addSubview(searchTextField)
        
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
            menuButton.leadingAnchor.constraint(equalTo: searchContainer.leadingAnchor, constant: 16),
            menuButton.centerYAnchor.constraint(equalTo: searchContainer.centerYAnchor),
            menuButton.widthAnchor.constraint(equalToConstant: 40),
            menuButton.heightAnchor.constraint(equalToConstant: 40),
            
            searchTextField.leadingAnchor.constraint(equalTo: menuButton.trailingAnchor, constant: 8),
            searchTextField.centerYAnchor.constraint(equalTo: searchContainer.centerYAnchor),
            
            searchButton.trailingAnchor.constraint(equalTo: searchContainer.trailingAnchor, constant: 12),
            searchButton.centerYAnchor.constraint(equalTo: searchContainer.centerYAnchor),
            searchButton.leadingAnchor.constraint(equalTo: searchTextField.trailingAnchor, constant: 12),
            searchButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 60),
            searchButton.heightAnchor.constraint(equalToConstant: 36)
        ])
        
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        let contentStack = UIStackView()
        contentStack.axis = .vertical
        contentStack.spacing = 20
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)
        
        let quickToolsCard = UIView()
        quickToolsCard.backgroundColor = Theme.cardBackground.withAlphaComponent(0.6)
        quickToolsCard.layer.cornerRadius = Theme.cardCornerRadius
        quickToolsCard.translatesAutoresizingMaskIntoConstraints = false
        contentStack.addArrangedSubview(quickToolsCard)
        
        let quickToolsTitle = UILabel()
        quickToolsTitle.text = "快捷搜索工具"
        quickToolsTitle.font = Theme.Font.bold(size: 18)
        quickToolsTitle.textColor = Theme.brightWhite
        quickToolsTitle.translatesAutoresizingMaskIntoConstraints = false
        quickToolsCard.addSubview(quickToolsTitle)
        
        let quickToolsStack = UIStackView()
        quickToolsStack.axis = .horizontal
        quickToolsStack.spacing = 12
        quickToolsStack.distribution = .fillEqually
        quickToolsStack.translatesAutoresizingMaskIntoConstraints = false
        quickToolsCard.addSubview(quickToolsStack)
        
        let quickTools = [
            ("🎬", "短搜搜", UIColor(hex: "FF6B6B")),
            ("🎥", "影迷搜", UIColor(hex: "4ECDC4")),
            ("📄", "豆丁搜", UIColor(hex: "96CEB4")),
            ("💾", "盘搜搜", UIColor(hex: "DDA0DD"))
        ]
        
        for (index, tool) in quickTools.enumerated() {
            let btn = createQuickToolButton(icon: tool.0, name: tool.1, color: tool.2, index: index)
            quickToolsStack.addArrangedSubview(btn)
        }
        
        NSLayoutConstraint.activate([
            quickToolsTitle.topAnchor.constraint(equalTo: quickToolsCard.topAnchor, constant: 16),
            quickToolsTitle.leadingAnchor.constraint(equalTo: quickToolsCard.leadingAnchor, constant: 16),
            quickToolsTitle.trailingAnchor.constraint(equalTo: quickToolsCard.trailingAnchor, constant: -16),
            
            quickToolsStack.topAnchor.constraint(equalTo: quickToolsTitle.bottomAnchor, constant: 16),
            quickToolsStack.leadingAnchor.constraint(equalTo: quickToolsCard.leadingAnchor, constant: 16),
            quickToolsStack.trailingAnchor.constraint(equalTo: quickToolsCard.trailingAnchor, constant: -16),
            quickToolsStack.bottomAnchor.constraint(equalTo: quickToolsCard.bottomAnchor, constant: -16),
            quickToolsStack.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        let historyCard = UIView()
        historyCard.backgroundColor = Theme.cardBackground.withAlphaComponent(0.6)
        historyCard.layer.cornerRadius = Theme.cardCornerRadius
        historyCard.translatesAutoresizingMaskIntoConstraints = false
        contentStack.addArrangedSubview(historyCard)
        
        let historyHeaderStack = UIStackView()
        historyHeaderStack.axis = .horizontal
        historyHeaderStack.translatesAutoresizingMaskIntoConstraints = false
        historyCard.addSubview(historyHeaderStack)
        
        let historyIconLabel = UILabel()
        historyIconLabel.text = "🕐"
        historyIconLabel.font = UIFont.systemFont(ofSize: 18)
        historyIconLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let historyTitleLabel = UILabel()
        historyTitleLabel.text = "搜索历史"
        historyTitleLabel.font = Theme.Font.bold(size: 18)
        historyTitleLabel.textColor = Theme.brightWhite
        historyTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let spacerView = UIView()
        spacerView.translatesAutoresizingMaskIntoConstraints = false
        
        let clearButton = UIButton(type: .system)
        clearButton.setTitle("清空", for: .normal)
        clearButton.titleLabel?.font = Theme.Font.regular(size: 14)
        clearButton.setTitleColor(Theme.mutedGray, for: .normal)
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        clearButton.addTarget(self, action: #selector(clearHistory), for: .touchUpInside)
        
        historyHeaderStack.addArrangedSubview(historyIconLabel)
        historyHeaderStack.addArrangedSubview(historyTitleLabel)
        historyHeaderStack.addArrangedSubview(spacerView)
        historyHeaderStack.addArrangedSubview(clearButton)
        
        historyStackView = UIStackView()
        historyStackView.axis = .vertical
        historyStackView.spacing = 12
        historyStackView.translatesAutoresizingMaskIntoConstraints = false
        historyCard.addSubview(historyStackView)
        
        NSLayoutConstraint.activate([
            historyHeaderStack.topAnchor.constraint(equalTo: historyCard.topAnchor, constant: 16),
            historyHeaderStack.leadingAnchor.constraint(equalTo: historyCard.leadingAnchor, constant: 16),
            historyHeaderStack.trailingAnchor.constraint(equalTo: historyCard.trailingAnchor, constant: -16),
            
            historyStackView.topAnchor.constraint(equalTo: historyHeaderStack.bottomAnchor, constant: 16),
            historyStackView.leadingAnchor.constraint(equalTo: historyCard.leadingAnchor, constant: 16),
            historyStackView.trailingAnchor.constraint(equalTo: historyCard.trailingAnchor, constant: -16),
            historyStackView.bottomAnchor.constraint(equalTo: historyCard.bottomAnchor, constant: -16)
        ])
        
        updateHistoryViews()
        
        let hotSearchCard = UIView()
        hotSearchCard.backgroundColor = Theme.cardBackground.withAlphaComponent(0.6)
        hotSearchCard.layer.cornerRadius = Theme.cardCornerRadius
        hotSearchCard.translatesAutoresizingMaskIntoConstraints = false
        contentStack.addArrangedSubview(hotSearchCard)
        
        let hotSearchTitle = UILabel()
        hotSearchTitle.text = "🔥 热门搜索"
        hotSearchTitle.font = Theme.Font.bold(size: 18)
        hotSearchTitle.textColor = Theme.brightWhite
        hotSearchTitle.translatesAutoresizingMaskIntoConstraints = false
        hotSearchCard.addSubview(hotSearchTitle)
        
        let hotTagsStack = UIStackView()
        hotTagsStack.axis = .horizontal
        hotTagsStack.spacing = 10
        hotTagsStack.alignment = .leading
        hotTagsStack.distribution = .fill
        hotTagsStack.translatesAutoresizingMaskIntoConstraints = false
        hotSearchCard.addSubview(hotTagsStack)
        
        let hotTags = ["热门电影", "最新短剧", "免费小说", "学习资料", "游戏攻略"]
        for tag in hotTags {
            let tagButton = UIButton(type: .system)
            tagButton.setTitle(tag, for: .normal)
            tagButton.titleLabel?.font = Theme.Font.regular(size: 14)
            tagButton.setTitleColor(Theme.brightWhite, for: .normal)
            tagButton.backgroundColor = Theme.cardBackground.withAlphaComponent(0.8)
            tagButton.layer.cornerRadius = 16
            tagButton.layer.borderWidth = 1
            tagButton.layer.borderColor = Theme.electricBlue.withAlphaComponent(0.5).cgColor
            tagButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
            tagButton.sizeToFit()
            tagButton.addTarget(self, action: #selector(hotTagTapped(_:)), for: .touchUpInside)
            hotTagsStack.addArrangedSubview(tagButton)
        }
        
        NSLayoutConstraint.activate([
            hotSearchTitle.topAnchor.constraint(equalTo: hotSearchCard.topAnchor, constant: 16),
            hotSearchTitle.leadingAnchor.constraint(equalTo: hotSearchCard.leadingAnchor, constant: 16),
            hotSearchTitle.trailingAnchor.constraint(equalTo: hotSearchCard.trailingAnchor, constant: -16),
            
            hotTagsStack.topAnchor.constraint(equalTo: hotSearchTitle.bottomAnchor, constant: 16),
            hotTagsStack.leadingAnchor.constraint(equalTo: hotSearchCard.leadingAnchor, constant: 16),
            hotTagsStack.trailingAnchor.constraint(lessThanOrEqualTo: hotSearchCard.trailingAnchor, constant: -16),
            hotTagsStack.bottomAnchor.constraint(equalTo: hotSearchCard.bottomAnchor, constant: -16)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            searchContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            searchContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            searchContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            searchContainer.heightAnchor.constraint(equalToConstant: 56),
            
            scrollView.topAnchor.constraint(equalTo: searchContainer.bottomAnchor, constant: 20),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 8),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        ])
        
        setupSideBar()
        
        title = "趣搜索"
    }
    
    private func createQuickToolButton(icon: String, name: String, color: UIColor, index: Int) -> UIButton {
        let button = UIButton(type: .system)
        button.backgroundColor = color.withAlphaComponent(0.2)
        button.layer.cornerRadius = 12
        button.layer.borderWidth = 2
        button.layer.borderColor = color.withAlphaComponent(0.5).cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tag = index
        button.addTarget(self, action: #selector(quickToolTapped(_:)), for: .touchUpInside)
        
        let iconLabel = UILabel()
        iconLabel.text = icon
        iconLabel.font = UIFont.systemFont(ofSize: 28)
        iconLabel.textAlignment = .center
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        button.addSubview(iconLabel)
        
        let nameLabel = UILabel()
        nameLabel.text = name
        nameLabel.font = Theme.Font.bold(size: 12)
        nameLabel.textColor = color
        nameLabel.textAlignment = .center
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        button.addSubview(nameLabel)
        
        NSLayoutConstraint.activate([
            iconLabel.topAnchor.constraint(equalTo: button.topAnchor, constant: 8),
            iconLabel.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            
            nameLabel.topAnchor.constraint(equalTo: iconLabel.bottomAnchor, constant: 4),
            nameLabel.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            nameLabel.bottomAnchor.constraint(lessThanOrEqualTo: button.bottomAnchor, constant: -4)
        ])
        
        return button
    }
    
    private func updateHistoryViews() {
        for subview in historyStackView.arrangedSubviews {
            subview.removeFromSuperview()
        }
        
        if searchHistory.isEmpty {
            let emptyLabel = UILabel()
            emptyLabel.text = "暂无搜索历史"
            emptyLabel.font = Theme.Font.regular(size: 14)
            emptyLabel.textColor = Theme.mutedGray
            emptyLabel.textAlignment = .center
            historyStackView.addArrangedSubview(emptyLabel)
        } else {
            for keyword in searchHistory {
                let itemView = createHistoryItem(keyword: keyword)
                historyStackView.addArrangedSubview(itemView)
            }
        }
    }
    
    private func createHistoryItem(keyword: String) -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
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
        
        let deleteButton = UIButton(type: .system)
        deleteButton.setTitle("×", for: .normal)
        deleteButton.titleLabel?.font = Theme.Font.bold(size: 18)
        deleteButton.setTitleColor(Theme.mutedGray, for: .normal)
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.tag = searchHistory.firstIndex(of: keyword) ?? 0
        deleteButton.addTarget(self, action: #selector(deleteHistoryItem(_:)), for: .touchUpInside)
        view.addSubview(deleteButton)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(historyItemTapped(_:)))
        view.addGestureRecognizer(tapGesture)
        view.isUserInteractionEnabled = true
        view.tag = searchHistory.firstIndex(of: keyword) ?? 0
        
        NSLayoutConstraint.activate([
            iconLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            iconLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            keywordLabel.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: 12),
            keywordLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            deleteButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            deleteButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            deleteButton.widthAnchor.constraint(equalToConstant: 30),
            deleteButton.heightAnchor.constraint(equalToConstant: 30),
            
            view.heightAnchor.constraint(equalToConstant: 36)
        ])
        
        return view
    }
    
    private func setupSideBar() {
        dimView = UIView()
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        dimView.alpha = 0
        dimView.isUserInteractionEnabled = false
        dimView.translatesAutoresizingMaskIntoConstraints = false
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
        
        let sideTitleLabel = UILabel()
        sideTitleLabel.text = "🔍 搜索工具"
        sideTitleLabel.font = Theme.Font.bold(size: 22)
        sideTitleLabel.textColor = Theme.brightWhite
        sideTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        sideBarView.addSubview(sideTitleLabel)
        
        let sideScrollView = UIScrollView()
        sideScrollView.translatesAutoresizingMaskIntoConstraints = false
        sideBarView.addSubview(sideScrollView)
        
        let sideStack = UIStackView()
        sideStack.axis = .vertical
        sideStack.spacing = 12
        sideStack.translatesAutoresizingMaskIntoConstraints = false
        sideScrollView.addSubview(sideStack)
        
        var lastCategory = ""
        for (index, tool) in searchTools.enumerated() {
            if tool.category != lastCategory {
                lastCategory = tool.category
                let categoryLabel = UILabel()
                categoryLabel.text = "—— \(tool.category) ——"
                categoryLabel.font = Theme.Font.bold(size: 14)
                categoryLabel.textColor = Theme.neonPink
                categoryLabel.textAlignment = .center
                categoryLabel.translatesAutoresizingMaskIntoConstraints = false
                sideStack.addArrangedSubview(categoryLabel)
            }
            
            let itemView = createSideBarItem(tool: tool, index: index)
            sideStack.addArrangedSubview(itemView)
        }
        
        NSLayoutConstraint.activate([
            sideTitleLabel.topAnchor.constraint(equalTo: sideBarView.topAnchor, constant: 24),
            sideTitleLabel.leadingAnchor.constraint(equalTo: sideBarView.leadingAnchor, constant: 20),
            sideTitleLabel.trailingAnchor.constraint(equalTo: sideBarView.trailingAnchor, constant: -20),
            
            sideScrollView.topAnchor.constraint(equalTo: sideTitleLabel.bottomAnchor, constant: 16),
            sideScrollView.leadingAnchor.constraint(equalTo: sideBarView.leadingAnchor),
            sideScrollView.trailingAnchor.constraint(equalTo: sideBarView.trailingAnchor),
            sideScrollView.bottomAnchor.constraint(equalTo: sideBarView.bottomAnchor, constant: -20),
            
            sideStack.topAnchor.constraint(equalTo: sideScrollView.topAnchor, constant: 8),
            sideStack.leadingAnchor.constraint(equalTo: sideScrollView.leadingAnchor, constant: 20),
            sideStack.trailingAnchor.constraint(equalTo: sideScrollView.trailingAnchor, constant: -20),
            sideStack.bottomAnchor.constraint(equalTo: sideScrollView.bottomAnchor, constant: -8),
            sideStack.widthAnchor.constraint(equalTo: sideScrollView.widthAnchor, constant: -40)
        ])
        
        NSLayoutConstraint.activate([
            sideBarView.topAnchor.constraint(equalTo: view.topAnchor),
            sideBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 280),
            sideBarView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            sideBarView.widthAnchor.constraint(equalToConstant: 280)
        ])
    }
    
    private func createSideBarItem(tool: (category: String, name: String, icon: String, color: UIColor), index: Int) -> UIView {
        let view = UIView()
        view.backgroundColor = Theme.cardBackground.withAlphaComponent(0.5)
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(searchToolTapped(_:)))
        view.addGestureRecognizer(tapGesture)
        view.isUserInteractionEnabled = true
        view.tag = index
        
        let iconLabel = UILabel()
        iconLabel.text = tool.icon
        iconLabel.font = UIFont.systemFont(ofSize: 24)
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(iconLabel)
        
        let nameLabel = UILabel()
        nameLabel.text = tool.name
        nameLabel.font = Theme.Font.bold(size: 16)
        nameLabel.textColor = tool.color
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        
        let arrowLabel = UILabel()
        arrowLabel.text = "›"
        arrowLabel.font = Theme.Font.bold(size: 20)
        arrowLabel.textColor = tool.color
        arrowLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(arrowLabel)
        
        NSLayoutConstraint.activate([
            iconLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            iconLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            iconLabel.widthAnchor.constraint(equalToConstant: 32),
            
            nameLabel.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: 12),
            nameLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            arrowLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            arrowLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            view.heightAnchor.constraint(equalToConstant: 50)
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
        dimView.isUserInteractionEnabled = true
        let tapToClose = UITapGestureRecognizer(target: self, action: #selector(hideSideBar))
        dimView.addGestureRecognizer(tapToClose)
        
        UIView.animate(withDuration: 0.3) {
            self.sideBarView.transform = CGAffineTransform(translationX: -280, y: 0)
            self.dimView.alpha = 1
        }
    }
    
    @objc private func hideSideBar() {
        isSideBarOpen = false
        dimView.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.3) {
            self.sideBarView.transform = .identity
            self.dimView.alpha = 0
        }
    }
    
    @objc private func quickToolTapped(_ sender: UIButton) {
        let index = sender.tag
        let tool = searchTools[index]
        showAlert(title: tool.name, message: "正在使用「\(tool.name)」搜索...")
    }
    
    @objc private func searchToolTapped(_ gesture: UITapGestureRecognizer) {
        guard let index = gesture.view?.tag else { return }
        let tool = searchTools[index]
        hideSideBar()
        showAlert(title: tool.name, message: "正在使用「\(tool.name)」搜索...")
    }
    
    @objc private func hotTagTapped(_ sender: UIButton) {
        guard let tag = sender.title(for: .normal) else { return }
        searchTextField.text = tag
        performSearch()
    }
    
    @objc private func performSearch() {
        guard let keyword = searchTextField.text, !keyword.isEmpty else {
            showAlert(title: "提示", message: "请输入搜索内容")
            return
        }
        
        if !searchHistory.contains(keyword) {
            searchHistory.insert(keyword, at: 0)
            if searchHistory.count > 10 {
                searchHistory.removeLast()
            }
            updateHistoryViews()
        }
        
        showAlert(title: "搜索", message: "正在搜索「\(keyword)」...")
    }
    
    @objc private func historyItemTapped(_ gesture: UITapGestureRecognizer) {
        guard let index = gesture.view?.tag, index < searchHistory.count else { return }
        searchTextField.text = searchHistory[index]
        performSearch()
    }
    
    @objc private func deleteHistoryItem(_ sender: UIButton) {
        let index = sender.tag
        if index < searchHistory.count {
            searchHistory.remove(at: index)
            updateHistoryViews()
        }
    }
    
    @objc private func clearHistory() {
        searchHistory.removeAll()
        updateHistoryViews()
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "好的", style: .default))
        present(alert, animated: true)
    }
}

extension QuSearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        performSearch()
        return true
    }
}
