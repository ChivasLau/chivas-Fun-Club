import UIKit
import WebKit

class CommonWebViewController: UIViewController {
    
    private var webView: WKWebView!
    private var urlString: String = ""
    private var pageTitle: String = ""
    private var themeColor: UIColor = Theme.electricBlue
    
    private var progressView: UIProgressView!
    private var loadingLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadURL()
    }
    
    func configure(title: String, url: String, themeColor: UIColor? = nil) {
        self.pageTitle = title
        self.urlString = url
        if let color = themeColor {
            self.themeColor = color
        }
    }
    
    private func setupUI() {
        view.backgroundColor = Theme.gradientTop
        
        let gradientBg = GradientBackgroundView(frame: view.bounds)
        gradientBg.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(gradientBg)
        
        let navBar = UIView()
        navBar.backgroundColor = Theme.cardBackground.withAlphaComponent(0.9)
        navBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(navBar)
        
        let backButton = UIButton(type: .system)
        backButton.setTitle("‹ 返回", for: .normal)
        backButton.titleLabel?.font = Theme.Font.bold(size: 18)
        backButton.setTitleColor(themeColor, for: .normal)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        navBar.addSubview(backButton)
        
        let titleLabel = UILabel()
        titleLabel.text = pageTitle
        titleLabel.font = Theme.Font.bold(size: 18)
        titleLabel.textColor = Theme.brightWhite
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        navBar.addSubview(titleLabel)
        
        let refreshButton = UIButton(type: .system)
        refreshButton.setTitle("↻", for: .normal)
        refreshButton.titleLabel?.font = Theme.Font.bold(size: 22)
        refreshButton.setTitleColor(themeColor, for: .normal)
        refreshButton.translatesAutoresizingMaskIntoConstraints = false
        refreshButton.addTarget(self, action: #selector(refreshPage), for: .touchUpInside)
        navBar.addSubview(refreshButton)
        
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.progressTintColor = themeColor
        progressView.trackTintColor = Theme.cardBackground
        progressView.progress = 0
        progressView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(progressView)
        
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        webView.navigationDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        
        loadingLabel = UILabel()
        loadingLabel.text = "加载中..."
        loadingLabel.font = Theme.Font.regular(size: 16)
        loadingLabel.textColor = Theme.mutedGray
        loadingLabel.textAlignment = .center
        loadingLabel.isHidden = false
        loadingLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingLabel)
        
        NSLayoutConstraint.activate([
            navBar.topAnchor.constraint(equalTo: view.topAnchor),
            navBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navBar.heightAnchor.constraint(equalToConstant: 88),
            
            backButton.leadingAnchor.constraint(equalTo: navBar.leadingAnchor, constant: 16),
            backButton.bottomAnchor.constraint(equalTo: navBar.bottomAnchor, constant: -8),
            
            titleLabel.centerXAnchor.constraint(equalTo: navBar.centerXAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: navBar.bottomAnchor, constant: -8),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: backButton.trailingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: refreshButton.leadingAnchor, constant: -16),
            
            refreshButton.trailingAnchor.constraint(equalTo: navBar.trailingAnchor, constant: -16),
            refreshButton.bottomAnchor.constraint(equalTo: navBar.bottomAnchor, constant: -8),
            
            progressView.topAnchor.constraint(equalTo: navBar.bottomAnchor),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            webView.topAnchor.constraint(equalTo: progressView.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            loadingLabel.centerXAnchor.constraint(equalTo: webView.centerXAnchor),
            loadingLabel.centerYAnchor.constraint(equalTo: webView.centerYAnchor)
        ])
        
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
    }
    
    private func loadURL() {
        guard let url = URL(string: urlString) else {
            loadingLabel.text = "无效的URL"
            return
        }
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    @objc private func goBack() {
        if webView.canGoBack {
            webView.goBack()
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @objc private func refreshPage() {
        webView.reload()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            progressView.progress = Float(webView.estimatedProgress)
            if webView.estimatedProgress >= 1.0 {
                UIView.animate(withDuration: 0.3, delay: 0.3, options: .curveEaseOut, animations: {
                    self.progressView.alpha = 0
                }, completion: { _ in
                    self.progressView.progress = 0
                    self.progressView.alpha = 1
                })
            }
        }
    }
    
    deinit {
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
    }
}

extension CommonWebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        loadingLabel.isHidden = false
        progressView.progress = 0
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loadingLabel.isHidden = true
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        loadingLabel.text = "加载失败"
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        loadingLabel.text = "加载失败: \(error.localizedDescription)"
    }
}
