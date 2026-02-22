import UIKit
import WebKit

class QuKanWebViewController: UIViewController {
    
    private var webView: WKWebView!
    private var loadingView: CyberLoadingView!
    private var progressView: UIProgressView!
    private var pageTitle: String = ""
    private var pageURL: String = ""
    private var themeColor: UIColor = Theme.electricBlue
    
    private var isDesktopMode: Bool = false
    
    func configure(title: String, url: String, themeColor: UIColor) {
        self.pageTitle = title
        self.pageURL = url
        self.themeColor = themeColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        loadWebView()
    }
    
    private func setupUI() {
        let gradientBg = GradientBackgroundView(frame: view.bounds)
        gradientBg.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(gradientBg)
        
        let webConfiguration = createWebViewConfiguration()
        
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.navigationDelegate = self
        webView.backgroundColor = .black
        webView.scrollView.backgroundColor = .black
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        loadingView = CyberLoadingView(frame: CGRect(x: 0, y: 0, width: 120, height: 120))
        loadingView.center = view.center
        loadingView.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin]
        view.addSubview(loadingView)
        
        progressView = UIProgressView(progressViewStyle: .bar)
        progressView.progressTintColor = themeColor
        progressView.trackTintColor = Theme.mutedGray.withAlphaComponent(0.3)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(progressView)
        
        NSLayoutConstraint.activate([
            progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 3)
        ])
        
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
    }
    
    private func createWebViewConfiguration() -> WKWebViewConfiguration {
        let config = WKWebViewConfiguration()
        
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        
        if #available(iOS 13.0, *) {
            config.defaultWebpagePreferences.allowsContentJavaScript = true
        }
        
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        preferences.javaScriptCanOpenWindowsAutomatically = true
        config.preferences = preferences
        
        let userContentController = WKUserContentController()
        
        let videoOptimizeScript = WKUserScript(
            source: videoOptimizationJS,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: false
        )
        userContentController.addUserScript(videoOptimizeScript)
        
        let adRemovalScript = WKUserScript(
            source: adRemovalJS,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: false
        )
        userContentController.addUserScript(adRemovalScript)
        
        config.userContentController = userContentController
        
        config.allowsAirPlayForMediaPlayback = true
        
        return config
    }
    
    private var videoOptimizationJS: String {
        return """
        (function() {
            // 视频播放器优化
            var videos = document.querySelectorAll('video');
            videos.forEach(function(video) {
                video.setAttribute('playsinline', '');
                video.setAttribute('webkit-playsinline', '');
                video.setAttribute('x5-video-player-type', 'h5');
                video.setAttribute('x5-video-player-fullscreen', 'true');
            });
            
            // 全屏视频容器
            var videoContainers = document.querySelectorAll('[id*="player"], [class*="player"], [id*="video"], [class*="video"]');
            videoContainers.forEach(function(container) {
                container.style.width = '100%';
                container.style.height = 'auto';
                container.style.minHeight = '200px';
            });
            
            // 触摸优化
            document.body.style.touchAction = 'manipulation';
            
            // 隐藏干扰元素
            var annoyingSelectors = [
                '.cookie-banner', '.cookie-consent', '#cookie-banner',
                '.popup-overlay', '.modal-overlay', '.ad-popup'
            ];
            annoyingSelectors.forEach(function(selector) {
                var elements = document.querySelectorAll(selector);
                elements.forEach(function(el) {
                    el.style.display = 'none';
                });
            });
        })();
        """
    }
    
    private var adRemovalJS: String {
        return """
        (function() {
            var adSelectors = [
                'iframe[src*="doubleclick"]',
                'iframe[src*="googlesyndication"]',
                '[class*="ad-"]',
                '[id*="ad-"]',
                '.banner-ad', '.top-ad', '.side-ad'
            ];
            
            function removeAds() {
                adSelectors.forEach(function(selector) {
                    try {
                        var elements = document.querySelectorAll(selector);
                        elements.forEach(function(el) {
                            el.style.display = 'none';
                        });
                    } catch(e) {}
                });
            }
            
            removeAds();
            
            var observer = new MutationObserver(function() {
                removeAds();
            });
            observer.observe(document.body, { childList: true, subtree: true });
        })();
        """
    }
    
    private func setupNavigationBar() {
        title = pageTitle
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        
        let moreButton = UIBarButtonItem(
            image: makeMoreIcon(),
            style: .plain,
            target: self,
            action: #selector(showMoreOptions)
        )
        moreButton.tintColor = Theme.brightWhite
        
        let refreshButton = UIBarButtonItem(
            image: makeRefreshIcon(),
            style: .plain,
            target: self,
            action: #selector(refreshAction)
        )
        refreshButton.tintColor = themeColor
        
        navigationItem.rightBarButtonItems = [moreButton, refreshButton]
    }
    
    private func makeMoreIcon() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 22, height: 22), false, 0)
        let context = UIGraphicsGetCurrentContext()
        context?.setStrokeColor(Theme.brightWhite.cgColor)
        context?.setLineWidth(2)
        context?.setLineCap(.round)
        for i in 0..<3 {
            let x: CGFloat = 5 + CGFloat(i) * 6
            context?.move(to: CGPoint(x: x, y: 11))
            context?.addLine(to: CGPoint(x: x + 1, y: 11))
        }
        context?.strokePath()
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    private func makeRefreshIcon() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 24, height: 24), false, 0)
        let context = UIGraphicsGetCurrentContext()
        context?.setStrokeColor(themeColor.cgColor)
        context?.setLineWidth(2.5)
        context?.addEllipse(in: CGRect(x: 3, y: 3, width: 18, height: 18))
        context?.move(to: CGPoint(x: 12, y: 0))
        context?.addLine(to: CGPoint(x: 12, y: 6))
        context?.strokePath()
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    @objc private func showMoreOptions() {
        let alert = UIAlertController(title: "浏览器工具", message: nil, preferredStyle: .actionSheet)
        
        let desktopTitle = isDesktopMode ? "切换移动版" : "切换桌面版"
        alert.addAction(UIAlertAction(title: desktopTitle, style: .default) { [weak self] _ in
            self?.toggleDesktopMode()
        })
        
        alert.addAction(UIAlertAction(title: "刷新页面", style: .default) { [weak self] _ in
            self?.webView.reload()
        })
        
        alert.addAction(UIAlertAction(title: "清除缓存", style: .default) { [weak self] _ in
            self?.clearCache()
        })
        
        alert.addAction(UIAlertAction(title: "分享链接", style: .default) { [weak self] _ in
            self?.shareAction()
        })
        
        alert.addAction(UIAlertAction(title: "在Safari中打开", style: .default) { [weak self] _ in
            self?.openInSafari()
        })
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        
        if let popover = alert.popoverPresentationController {
            popover.barButtonItem = navigationItem.rightBarButtonItems?.first
        }
        
        present(alert, animated: true)
    }
    
    private func toggleDesktopMode() {
        isDesktopMode.toggle()
        
        if isDesktopMode {
            webView.customUserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
        } else {
            webView.customUserAgent = nil
        }
        
        webView.reload()
    }
    
    private func clearCache() {
        let websiteDataTypes = WKWebsiteDataStore.allWebsiteDataTypes()
        let date = Date(timeIntervalSince1970: 0)
        
        WKWebsiteDataStore.default().removeData(ofTypes: websiteDataTypes, modifiedSince: date) { [weak self] in
            let alert = UIAlertController(title: "已清除", message: "缓存已清除，正在重新加载...", preferredStyle: .alert)
            self?.present(alert, animated: true)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                alert.dismiss(animated: true)
                self?.webView.reload()
            }
        }
    }
    
    private func openInSafari() {
        guard let url = webView.url ?? URL(string: pageURL) else { return }
        UIApplication.shared.open(url)
    }
    
    private func loadWebView() {
        loadingView.startAnimating()
        loadingView.isHidden = false
        
        if isDesktopMode {
            webView.customUserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
        }
        
        guard let url = URL(string: pageURL) else { return }
        
        var request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 60)
        request.addValue("text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", forHTTPHeaderField: "Accept")
        request.addValue("zh-CN,zh;q=0.9,en;q=0.8", forHTTPHeaderField: "Accept-Language")
        
        webView.load(request)
    }
    
    @objc private func refreshAction() {
        webView.reload()
    }
    
    @objc private func shareAction() {
        guard let url = webView.url else { return }
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        activityVC.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItems?.first
        present(activityVC, animated: true)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            let progress = Float(webView.estimatedProgress)
            progressView.setProgress(progress, animated: true)
            
            if progress >= 1.0 {
                UIView.animate(withDuration: 0.3, delay: 0.5, options: [], animations: {
                    self.progressView.alpha = 0
                }, completion: nil)
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        loadingView.center = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
    }
    
    deinit {
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
    }
}

extension QuKanWebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        loadingView.startAnimating()
        loadingView.isHidden = false
        progressView.setProgress(0, animated: false)
        progressView.alpha = 1
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loadingView.stopAnimating()
        UIView.animate(withDuration: 0.3) {
            self.loadingView.alpha = 0
        } completion: { _ in
            self.loadingView.isHidden = true
            self.loadingView.alpha = 1
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        loadingView.stopAnimating()
        loadingView.isHidden = true
        
        let alert = UIAlertController(title: "加载失败", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "重试", style: .default) { _ in
            self.loadWebView()
        })
        alert.addAction(UIAlertAction(title: "在Safari中打开", style: .default) { _ in
            if let url = URL(string: self.pageURL) {
                UIApplication.shared.open(url)
            }
        })
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        present(alert, animated: true)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url {
            let urlString = url.absoluteString
            
            let blockedDomains = ["doubleclick.net", "googlesyndication.com", "googleads.g.doubleclick.net"]
            for domain in blockedDomains {
                if urlString.contains(domain) {
                    decisionHandler(.cancel)
                    return
                }
            }
        }
        
        decisionHandler(.allow)
    }
}
