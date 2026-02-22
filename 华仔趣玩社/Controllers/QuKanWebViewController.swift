import UIKit
import WebKit

class QuKanWebViewController: UIViewController {
    
    private var webView: WKWebView!
    private var loadingView: CyberLoadingView!
    private var progressView: UIProgressView!
    private var pageTitle: String = ""
    private var pageURL: String = ""
    private var themeColor: UIColor = Theme.electricBlue
    
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
        
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.allowsInlineMediaPlayback = true
        
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.navigationDelegate = self
        webView.backgroundColor = .white
        webView.scrollView.backgroundColor = .white
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
    
    private func setupNavigationBar() {
        title = pageTitle
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        
        let refreshButton = UIBarButtonItem(
            image: makeRefreshIcon(),
            style: .plain,
            target: self,
            action: #selector(refreshAction)
        )
        refreshButton.tintColor = themeColor
        
        let shareButton = UIBarButtonItem(
            image: makeShareIcon(),
            style: .plain,
            target: self,
            action: #selector(shareAction)
        )
        shareButton.tintColor = Theme.neonPink
        
        navigationItem.rightBarButtonItems = [shareButton, refreshButton]
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
    
    private func makeShareIcon() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 24, height: 24), false, 0)
        let context = UIGraphicsGetCurrentContext()
        context?.setStrokeColor(Theme.neonPink.cgColor)
        context?.setLineWidth(2.5)
        context?.move(to: CGPoint(x: 12, y: 3))
        context?.addLine(to: CGPoint(x: 12, y: 14))
        context?.move(to: CGPoint(x: 6, y: 9))
        context?.addLine(to: CGPoint(x: 12, y: 3))
        context?.addLine(to: CGPoint(x: 18, y: 9))
        context?.move(to: CGPoint(x: 5, y: 14))
        context?.addLine(to: CGPoint(x: 5, y: 21))
        context?.addLine(to: CGPoint(x: 19, y: 21))
        context?.addLine(to: CGPoint(x: 19, y: 14))
        context?.strokePath()
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    private func loadWebView() {
        loadingView.startAnimating()
        loadingView.isHidden = false
        
        guard let url = URL(string: pageURL) else { return }
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 30)
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
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        present(alert, animated: true)
    }
}
