import UIKit
import WebKit

class QuKanViewController: UIViewController {
    
    private var webView: WKWebView!
    private var loadingView: CyberLoadingView!
    private var progressView: UIProgressView!
    private let targetURL = "https://www.kkys1.com/"
    
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
        webConfiguration.mediaTypesRequiringUserActionForPlayback = []
        
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.navigationDelegate = self
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        webView.layer.cornerRadius = Theme.cornerRadius
        webView.clipsToBounds = true
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8)
        ])
        
        loadingView = CyberLoadingView(frame: CGRect(x: 0, y: 0, width: 120, height: 120))
        loadingView.center = view.center
        loadingView.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin]
        view.addSubview(loadingView)
        
        progressView = UIProgressView(progressViewStyle: .bar)
        progressView.progressTintColor = Theme.electricBlue
        progressView.trackTintColor = Theme.mutedGray.withAlphaComponent(0.3)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(progressView)
        
        NSLayoutConstraint.activate([
            progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 2)
        ])
        
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
    }
    
    private func setupNavigationBar() {
        title = "趣看"
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        
        let refreshButton = UIBarButtonItem(
            image: UIImage(systemName: "arrow.clockwise") ?? makeRefreshIcon(),
            style: .plain,
            target: self,
            action: #selector(refreshAction)
        )
        refreshButton.tintColor = Theme.neonPink
        
        let shareButton = UIBarButtonItem(
            image: UIImage(systemName: "square.and.arrow.up") ?? makeShareIcon(),
            style: .plain,
            target: self,
            action: #selector(shareAction)
        )
        shareButton.tintColor = Theme.electricBlue
        
        navigationItem.rightBarButtonItems = [shareButton, refreshButton]
    }
    
    private func makeRefreshIcon() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 22, height: 22), false, 0)
        let context = UIGraphicsGetCurrentContext()
        context?.setStrokeColor(Theme.neonPink.cgColor)
        context?.setLineWidth(2)
        context?.addEllipse(in: CGRect(x: 3, y: 3, width: 16, height: 16))
        context?.move(to: CGPoint(x: 11, y: 0))
        context?.addLine(to: CGPoint(x: 11, y: 6))
        context?.strokePath()
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    private func makeShareIcon() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 22, height: 22), false, 0)
        let context = UIGraphicsGetCurrentContext()
        context?.setStrokeColor(Theme.electricBlue.cgColor)
        context?.setLineWidth(2)
        context?.move(to: CGPoint(x: 11, y: 3))
        context?.addLine(to: CGPoint(x: 11, y: 13))
        context?.move(to: CGPoint(x: 6, y: 8))
        context?.addLine(to: CGPoint(x: 11, y: 3))
        context?.addLine(to: CGPoint(x: 16, y: 8))
        context?.move(to: CGPoint(x: 5, y: 12))
        context?.addLine(to: CGPoint(x: 5, y: 19))
        context?.addLine(to: CGPoint(x: 17, y: 19))
        context?.addLine(to: CGPoint(x: 17, y: 12))
        context?.strokePath()
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    private func loadWebView() {
        loadingView.startAnimating()
        loadingView.isHidden = false
        
        guard let url = URL(string: targetURL) else { return }
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

extension QuKanViewController: WKNavigationDelegate {
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
