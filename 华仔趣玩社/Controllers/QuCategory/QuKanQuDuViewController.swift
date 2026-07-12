import UIKit
import WebKit

// MARK: - 播放记录模型
struct PlaybackRecord: Codable {
    let id: String
    let title: String
    let url: String
    let timestamp: Date
    let siteName: String
}

class PlaybackHistory {
    private static let key = "playback_records"
    private static let maxRecords = 50
    
    static func load() -> [PlaybackRecord] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let records = try? JSONDecoder().decode([PlaybackRecord].self, from: data) else { return [] }
        return records.sorted { $0.timestamp > $1.timestamp }
    }
    
    static func add(title: String, url: String, siteName: String) {
        var records = load()
        let record = PlaybackRecord(id: UUID().uuidString, title: title, url: url, timestamp: Date(), siteName: siteName)
        records.insert(record, at: 0)
        if records.count > maxRecords { records = Array(records.prefix(maxRecords)) }
        if let data = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    
    static func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}

class QuKanQuDuViewController: UIViewController {
    
    private let movieSites: [(name: String, icon: String, url: String, color: UIColor)] = [
        ("布布追剧", "📺", "https://asd123sx23xdacsx.top/play/101230#sid=co&nid=82", UIColor(hex: "E74C3C")),
        ("可可影视", "🎬", "https://www.kkys1.com/", UIColor(hex: "3498DB")),
        ("全网影视资源搜索", "🔍", "https://xusou.cn/", UIColor(hex: "2ECC71")),
        ("柯南影视", "🕵️", "https://www.knvod.com/", UIColor(hex: "9B59B6")),
        ("努努影院", "🎥", "https://nnyy.la/", UIColor(hex: "F39C12")),
        ("猫影仓库", "📦", "https://www.ymck.pro/?ref=goyoii.com", UIColor(hex: "1ABC9C"))
    ]
    
    private var isSidebarCollapsed = false
    private var isRightPanelCollapsed = true
    private var currentIndex = 0
    
    private var sidebarView: UIView!
    private var sidebarWidthConstraint: NSLayoutConstraint!
    private var toggleButton: UIButton!
    private var webView: WKWebView!
    private var siteButtons: [UIButton] = []
    
    private var rightPanel: UIView!
    private var rightPanelWidthConstraint: NSLayoutConstraint!
    private var rightToggleButton: UIButton!
    private var historyTable: UITableView!
    private var playbackRecords: [PlaybackRecord] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        setupUI()
        loadSite(index: 0)
    }
    
    override var prefersStatusBarHidden: Bool { true }
    override var prefersHomeIndicatorAutoHidden: Bool { false }
    
    private func setupUI() {
        let gradientBg = GradientBackgroundView(frame: view.bounds)
        gradientBg.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(gradientBg)
        
        let webConfig = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfig)
        webView.backgroundColor = .clear
        webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Safari/605.1.15"
        webView.navigationDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        
        toggleButton = UIButton(type: .system)
        toggleButton.setTitle("☰", for: .normal)
        toggleButton.titleLabel?.font = Theme.Font.bold(size: 24)
        toggleButton.setTitleColor(Theme.electricBlue, for: .normal)
        toggleButton.backgroundColor = Theme.cardBackground.withAlphaComponent(0.8)
        toggleButton.layer.cornerRadius = 22
        toggleButton.translatesAutoresizingMaskIntoConstraints = false
        toggleButton.addTarget(self, action: #selector(toggleSidebar), for: .touchUpInside)
        view.addSubview(toggleButton)
        
        rightToggleButton = UIButton(type: .system)
        rightToggleButton.setTitle("📋", for: .normal)
        rightToggleButton.titleLabel?.font = Theme.Font.bold(size: 18)
        rightToggleButton.setTitleColor(Theme.neonPink, for: .normal)
        rightToggleButton.backgroundColor = Theme.cardBackground.withAlphaComponent(0.8)
        rightToggleButton.layer.cornerRadius = 22
        rightToggleButton.translatesAutoresizingMaskIntoConstraints = false
        rightToggleButton.addTarget(self, action: #selector(toggleRightPanel), for: .touchUpInside)
        view.addSubview(rightToggleButton)
        
        setupSidebar()
        setupRightPanel()
        
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            toggleButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            toggleButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            toggleButton.widthAnchor.constraint(equalToConstant: 44),
            toggleButton.heightAnchor.constraint(equalToConstant: 44),
            
            rightToggleButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            rightToggleButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            rightToggleButton.widthAnchor.constraint(equalToConstant: 44),
            rightToggleButton.heightAnchor.constraint(equalToConstant: 44),
        ])
    }
    
    private func setupSidebar() {
        sidebarView = UIView()
        sidebarView.backgroundColor = Theme.cardBackground.withAlphaComponent(0.95)
        sidebarView.translatesAutoresizingMaskIntoConstraints = false
        sidebarView.clipsToBounds = true
        view.addSubview(sidebarView)
        
        sidebarWidthConstraint = sidebarView.widthAnchor.constraint(equalToConstant: 220)
        
        let sideTitle = UILabel()
        sideTitle.text = "🎬 影视列表"
        sideTitle.font = Theme.Font.bold(size: 18)
        sideTitle.textColor = Theme.brightWhite
        sideTitle.translatesAutoresizingMaskIntoConstraints = false
        sidebarView.addSubview(sideTitle)
        
        let hideButton = UIButton(type: .system)
        hideButton.setTitle("◀ 收起", for: .normal)
        hideButton.titleLabel?.font = Theme.Font.regular(size: 14)
        hideButton.setTitleColor(Theme.mutedGray, for: .normal)
        hideButton.translatesAutoresizingMaskIntoConstraints = false
        hideButton.addTarget(self, action: #selector(toggleSidebar), for: .touchUpInside)
        sidebarView.addSubview(hideButton)
        
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        sidebarView.addSubview(scrollView)
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)
        
        for (index, site) in movieSites.enumerated() {
            let btn = UIButton(type: .system)
            btn.setTitle("\(site.icon)  \(site.name)", for: .normal)
            btn.titleLabel?.font = Theme.Font.regular(size: 15)
            btn.setTitleColor(Theme.brightWhite, for: .normal)
            btn.contentHorizontalAlignment = .left
            btn.backgroundColor = index == 0 ? site.color.withAlphaComponent(0.3) : .clear
            btn.layer.cornerRadius = 10
            btn.contentEdgeInsets = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)
            btn.translatesAutoresizingMaskIntoConstraints = false
            btn.tag = index
            btn.addTarget(self, action: #selector(siteTapped(_:)), for: .touchUpInside)
            stackView.addArrangedSubview(btn)
            siteButtons.append(btn)
        }
        
        let dimView = UIView()
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        dimView.translatesAutoresizingMaskIntoConstraints = false
        dimView.tag = 999
        let tapDim = UITapGestureRecognizer(target: self, action: #selector(toggleSidebar))
        dimView.addGestureRecognizer(tapDim)
        sidebarView.addSubview(dimView)
        
        NSLayoutConstraint.activate([
            sidebarView.topAnchor.constraint(equalTo: view.topAnchor),
            sidebarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sidebarView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            sidebarWidthConstraint,
            
            sideTitle.topAnchor.constraint(equalTo: sidebarView.topAnchor, constant: 60),
            sideTitle.leadingAnchor.constraint(equalTo: sidebarView.leadingAnchor, constant: 16),
            sideTitle.trailingAnchor.constraint(equalTo: sidebarView.trailingAnchor, constant: -16),
            
            hideButton.centerYAnchor.constraint(equalTo: sideTitle.centerYAnchor),
            hideButton.trailingAnchor.constraint(equalTo: sidebarView.trailingAnchor, constant: -16),
            
            scrollView.topAnchor.constraint(equalTo: sideTitle.bottomAnchor, constant: 16),
            scrollView.leadingAnchor.constraint(equalTo: sidebarView.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: sidebarView.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: sidebarView.bottomAnchor),
            
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 12),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -12),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -24),
            
            dimView.leadingAnchor.constraint(equalTo: sidebarView.trailingAnchor),
            dimView.topAnchor.constraint(equalTo: sidebarView.topAnchor),
            dimView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dimView.bottomAnchor.constraint(equalTo: sidebarView.bottomAnchor)
        ])
    }
    
    private func setupRightPanel() {
        rightPanel = UIView()
        rightPanel.backgroundColor = Theme.cardBackground.withAlphaComponent(0.95)
        rightPanel.translatesAutoresizingMaskIntoConstraints = false
        rightPanel.clipsToBounds = true
        view.addSubview(rightPanel)
        
        rightPanelWidthConstraint = rightPanel.widthAnchor.constraint(equalToConstant: 0)
        
        let headerLabel = UILabel()
        headerLabel.text = "📋 播放记录"
        headerLabel.font = Theme.Font.bold(size: 18)
        headerLabel.textColor = Theme.brightWhite
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        rightPanel.addSubview(headerLabel)
        
        let clearButton = UIButton(type: .system)
        clearButton.setTitle("清空", for: .normal)
        clearButton.titleLabel?.font = Theme.Font.regular(size: 13)
        clearButton.setTitleColor(Theme.mutedGray, for: .normal)
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        clearButton.addTarget(self, action: #selector(clearHistory), for: .touchUpInside)
        rightPanel.addSubview(clearButton)
        
        let hideButton = UIButton(type: .system)
        hideButton.setTitle("▶ 收起", for: .normal)
        hideButton.titleLabel?.font = Theme.Font.regular(size: 14)
        hideButton.setTitleColor(Theme.mutedGray, for: .normal)
        hideButton.translatesAutoresizingMaskIntoConstraints = false
        hideButton.addTarget(self, action: #selector(toggleRightPanel), for: .touchUpInside)
        rightPanel.addSubview(hideButton)
        
        playbackRecords = PlaybackHistory.load()
        historyTable = UITableView()
        historyTable.backgroundColor = .clear
        historyTable.separatorStyle = .none
        historyTable.dataSource = self
        historyTable.delegate = self
        historyTable.register(HistoryCell.self, forCellReuseIdentifier: "HistoryCell")
        historyTable.translatesAutoresizingMaskIntoConstraints = false
        rightPanel.addSubview(historyTable)
        
        NSLayoutConstraint.activate([
            rightPanel.topAnchor.constraint(equalTo: view.topAnchor),
            rightPanel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            rightPanel.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            rightPanelWidthConstraint,
            
            headerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            headerLabel.leadingAnchor.constraint(equalTo: rightPanel.leadingAnchor, constant: 16),
            
            clearButton.centerYAnchor.constraint(equalTo: headerLabel.centerYAnchor),
            clearButton.trailingAnchor.constraint(equalTo: hideButton.leadingAnchor, constant: -12),
            
            hideButton.centerYAnchor.constraint(equalTo: headerLabel.centerYAnchor),
            hideButton.trailingAnchor.constraint(equalTo: rightPanel.trailingAnchor, constant: -16),
            
            historyTable.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 12),
            historyTable.leadingAnchor.constraint(equalTo: rightPanel.leadingAnchor),
            historyTable.trailingAnchor.constraint(equalTo: rightPanel.trailingAnchor),
            historyTable.bottomAnchor.constraint(equalTo: rightPanel.bottomAnchor),
        ])
    }
    
    private func loadSite(index: Int) {
        guard index < movieSites.count else { return }
        currentIndex = index
        
        for (i, btn) in siteButtons.enumerated() {
            btn.backgroundColor = i == index ? movieSites[i].color.withAlphaComponent(0.3) : .clear
        }
        
        guard let url = URL(string: movieSites[index].url) else { return }
        var request = URLRequest(url: url)
        request.setValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Safari/605.1.15", forHTTPHeaderField: "User-Agent")
        webView.load(request)
    }
    
    @objc private func toggleSidebar() {
        isSidebarCollapsed.toggle()
        UIView.animate(withDuration: 0.3) {
            self.sidebarWidthConstraint.constant = self.isSidebarCollapsed ? 0 : 220
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func toggleRightPanel() {
        isRightPanelCollapsed.toggle()
        playbackRecords = PlaybackHistory.load()
        historyTable.reloadData()
        UIView.animate(withDuration: 0.3) {
            self.rightPanelWidthConstraint.constant = self.isRightPanelCollapsed ? 0 : 260
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func siteTapped(_ sender: UIButton) {
        loadSite(index: sender.tag)
        if !isSidebarCollapsed {
            toggleSidebar()
        }
    }
    
    @objc private func clearHistory() {
        PlaybackHistory.clear()
        playbackRecords = []
        historyTable.reloadData()
    }
}

// MARK: - WKNavigationDelegate
extension QuKanQuDuViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard let urlStr = webView.url?.absoluteString, !urlStr.isEmpty else { return }
        if currentIndex < movieSites.count {
            PlaybackHistory.add(title: movieSites[currentIndex].name, url: urlStr, siteName: movieSites[currentIndex].name)
            playbackRecords = PlaybackHistory.load()
            if !isRightPanelCollapsed {
                historyTable.reloadData()
            }
        }
    }
}

// MARK: - TableView
extension QuKanQuDuViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        playbackRecords.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath) as! HistoryCell
        let record = playbackRecords[indexPath.row]
        cell.configure(with: record)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let record = playbackRecords[indexPath.row]
        if let url = URL(string: record.url) {
            var req = URLRequest(url: url)
            req.setValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Safari/605.1.15", forHTTPHeaderField: "User-Agent")
            webView.load(req)
        }
    }
}

// MARK: - History Cell
class HistoryCell: UITableViewCell {
    private let titleLabel = UILabel()
    private let siteLabel = UILabel()
    private let timeLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = Theme.cardBackground.withAlphaComponent(0.4)
        selectionStyle = .none
        layer.cornerRadius = 8
        clipsToBounds = true
        
        titleLabel.font = Theme.Font.bold(size: 13)
        titleLabel.textColor = Theme.brightWhite
        titleLabel.numberOfLines = 2
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        siteLabel.font = Theme.Font.regular(size: 11)
        siteLabel.textColor = Theme.electricBlue
        siteLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(siteLabel)
        
        timeLabel.font = Theme.Font.regular(size: 10)
        timeLabel.textColor = Theme.mutedGray
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(timeLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            
            siteLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            siteLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            
            timeLabel.topAnchor.constraint(equalTo: siteLabel.bottomAnchor, constant: 2),
            timeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            timeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
        ])
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func configure(with record: PlaybackRecord) {
        titleLabel.text = record.title
        siteLabel.text = record.siteName
        let secs = Int(-record.timestamp.timeIntervalSinceNow)
        if secs < 60 { timeLabel.text = "刚刚" }
        else if secs < 3600 { timeLabel.text = "\(secs/60)分钟前" }
        else if secs < 86400 { timeLabel.text = "\(secs/3600)小时前" }
        else { timeLabel.text = "\(secs/86400)天前" }
    }
}
