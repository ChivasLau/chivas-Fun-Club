import UIKit
import WebKit

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
    private var currentIndex = 0
    
    private var sidebarView: UIView!
    private var sidebarWidthConstraint: NSLayoutConstraint!
    private var toggleButton: UIButton!
    private var webView: WKWebView!
    private var siteButtons: [UIButton] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadSite(index: 0)
    }
    
    override var prefersStatusBarHidden: Bool { true }
    override var prefersHomeIndicatorAutoHidden: Bool { false }
    
    private func setupUI() {
        let gradientBg = GradientBackgroundView(frame: view.bounds)
        gradientBg.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(gradientBg)
        
        let topBar = UIView()
        topBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topBar)
        
        let titleLabel = UILabel()
        titleLabel.text = "🎬 趣影视"
        titleLabel.font = Theme.Font.bold(size: 22)
        titleLabel.textColor = Theme.brightWhite
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        topBar.addSubview(titleLabel)
        
        let webConfig = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfig)
        webView.backgroundColor = .clear
        webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Safari/605.1.15"
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
        
        setupSidebar()
        
        NSLayoutConstraint.activate([
            topBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topBar.heightAnchor.constraint(equalToConstant: 44),
            
            titleLabel.centerXAnchor.constraint(equalTo: topBar.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: topBar.centerYAnchor),
            
            webView.topAnchor.constraint(equalTo: topBar.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            toggleButton.topAnchor.constraint(equalTo: topBar.bottomAnchor, constant: 8),
            toggleButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            toggleButton.widthAnchor.constraint(equalToConstant: 44),
            toggleButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        title = "趣影视"
    }
    
    private func setupSidebar() {
        sidebarView = UIView()
        sidebarView.backgroundColor = Theme.cardBackground.withAlphaComponent(0.95)
        sidebarView.translatesAutoresizingMaskIntoConstraints = false
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
            sidebarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
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
    
    @objc private func siteTapped(_ sender: UIButton) {
        loadSite(index: sender.tag)
        if !isSidebarCollapsed {
            toggleSidebar()
        }
    }
}
