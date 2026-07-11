import UIKit

enum AIMode: String, CaseIterable {
    case shortDrama = "剧情短片"
    case imageGen = "图片生成"
    case videoGen = "视频生成"
}

struct ChatMessage {
    let id: String
    let text: String
    let isUser: Bool
    var image: UIImage?
    var videoURL: String?
    let isLoading: Bool
    let timestamp: Date
    
    init(id: String = UUID().uuidString, text: String, isUser: Bool, image: UIImage? = nil, videoURL: String? = nil, isLoading: Bool = false, timestamp: Date = Date()) {
        self.id = id
        self.text = text
        self.isUser = isUser
        self.image = image
        self.videoURL = videoURL
        self.isLoading = isLoading
        self.timestamp = timestamp
    }
}

class QuAIViewController: UIViewController {
    
    private var messages: [ChatMessage] = []
    private let tableView = UITableView()
    private let bottomBar = UIView()
    private let modeButton = UIButton()
    private let imageModelButton = UIButton()
    private let videoModelButton = UIButton()
    private let textField = UITextField()
    private let sendButton = UIButton()
    
    private var currentMode: AIMode = .shortDrama
    private var currentImageModel = "agnes-image-2.0-flash"
    private var currentVideoModel = "agnes-video-v2.0"
    
    private let imageModels = ["agnes-image-2.0-flash", "agnes-image-2.1-flash"]
    private let videoModels = ["agnes-video-v2.0"]
    
    private var isGenerating = false
    
    private var apiKey: String {
        UserDefaults.standard.string(forKey: "agnes_api_key") ?? ""
    }
    
    private let baseURL = "https://apihub.agnes-ai.com/v1"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override var prefersStatusBarHidden: Bool { true }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    private func setupUI() {
        let gradientBg = GradientBackgroundView(frame: view.bounds)
        gradientBg.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(gradientBg)
        
        let titleLabel = UILabel()
        titleLabel.text = "🤖 趣AI"
        titleLabel.font = Theme.Font.bold(size: 28)
        titleLabel.textColor = Theme.brightWhite
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ChatMessageCell.self, forCellReuseIdentifier: "ChatCell")
        tableView.keyboardDismissMode = .interactive
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        bottomBar.backgroundColor = Theme.cardBackground.withAlphaComponent(0.92)
        bottomBar.layer.cornerRadius = 16
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bottomBar)
        
        setupBottomBar()
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomBar.topAnchor, constant: -8),
            
            bottomBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            bottomBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            bottomBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
        ])
        
        addMessage(ChatMessage(text: "你好！选择模式输入想法，我来帮你创作 🚀", isUser: false))
    }
    
    private func setupBottomBar() {
        modeButton.setTitle("▼ \(currentMode.rawValue)", for: .normal)
        modeButton.titleLabel?.font = Theme.Font.bold(size: 13)
        modeButton.setTitleColor(Theme.electricBlue, for: .normal)
        modeButton.backgroundColor = Theme.cardBackground.withAlphaComponent(0.5)
        modeButton.layer.cornerRadius = 14
        modeButton.contentEdgeInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
        modeButton.addTarget(self, action: #selector(showModePicker), for: .touchUpInside)
        modeButton.translatesAutoresizingMaskIntoConstraints = false
        bottomBar.addSubview(modeButton)
        
        imageModelButton.setTitle(currentImageModel, for: .normal)
        imageModelButton.titleLabel?.font = Theme.Font.regular(size: 11)
        imageModelButton.setTitleColor(Theme.brightWhite, for: .normal)
        imageModelButton.backgroundColor = Theme.cardBackground.withAlphaComponent(0.5)
        imageModelButton.layer.cornerRadius = 14
        imageModelButton.contentEdgeInsets = UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 10)
        imageModelButton.addTarget(self, action: #selector(showImageModelPicker), for: .touchUpInside)
        imageModelButton.translatesAutoresizingMaskIntoConstraints = false
        bottomBar.addSubview(imageModelButton)
        
        videoModelButton.setTitle(currentVideoModel, for: .normal)
        videoModelButton.titleLabel?.font = Theme.Font.regular(size: 11)
        videoModelButton.setTitleColor(Theme.brightWhite, for: .normal)
        videoModelButton.backgroundColor = Theme.cardBackground.withAlphaComponent(0.5)
        videoModelButton.layer.cornerRadius = 14
        videoModelButton.contentEdgeInsets = UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 10)
        videoModelButton.addTarget(self, action: #selector(showVideoModelPicker), for: .touchUpInside)
        videoModelButton.translatesAutoresizingMaskIntoConstraints = false
        bottomBar.addSubview(videoModelButton)
        
        textField.attributedPlaceholder = NSAttributedString(string: "输入你的想法...", attributes: [.foregroundColor: Theme.mutedGray])
        textField.font = Theme.Font.regular(size: 15)
        textField.textColor = Theme.brightWhite
        textField.backgroundColor = Theme.cardBackground.withAlphaComponent(0.5)
        textField.layer.cornerRadius = 20
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftViewMode = .always
        textField.returnKeyType = .send
        textField.delegate = self
        textField.translatesAutoresizingMaskIntoConstraints = false
        bottomBar.addSubview(textField)
        
        sendButton.setTitle("➤", for: .normal)
        sendButton.titleLabel?.font = Theme.Font.bold(size: 20)
        sendButton.setTitleColor(.white, for: .normal)
        sendButton.backgroundColor = Theme.electricBlue
        sendButton.layer.cornerRadius = 20
        sendButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        bottomBar.addSubview(sendButton)
        
        NSLayoutConstraint.activate([
            modeButton.topAnchor.constraint(equalTo: bottomBar.topAnchor, constant: 8),
            modeButton.leadingAnchor.constraint(equalTo: bottomBar.leadingAnchor, constant: 8),
            
            imageModelButton.topAnchor.constraint(equalTo: bottomBar.topAnchor, constant: 8),
            imageModelButton.trailingAnchor.constraint(equalTo: videoModelButton.leadingAnchor, constant: -6),
            
            videoModelButton.topAnchor.constraint(equalTo: bottomBar.topAnchor, constant: 8),
            videoModelButton.trailingAnchor.constraint(equalTo: bottomBar.trailingAnchor, constant: -8),
            
            textField.topAnchor.constraint(equalTo: modeButton.bottomAnchor, constant: 8),
            textField.leadingAnchor.constraint(equalTo: bottomBar.leadingAnchor, constant: 8),
            textField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -8),
            textField.heightAnchor.constraint(equalToConstant: 40),
            textField.bottomAnchor.constraint(equalTo: bottomBar.bottomAnchor, constant: -8),
            
            sendButton.trailingAnchor.constraint(equalTo: bottomBar.trailingAnchor, constant: -8),
            sendButton.centerYAnchor.constraint(equalTo: textField.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 40),
            sendButton.heightAnchor.constraint(equalToConstant: 40),
        ])
    }
    
    // MARK: - Mode / Model Pickers
    
    @objc private func showModePicker() {
        let alert = UIAlertController(title: "选择模式", message: nil, preferredStyle: .actionSheet)
        for mode in AIMode.allCases {
            alert.addAction(UIAlertAction(title: mode.rawValue, style: .default, handler: { [weak self] _ in
                self?.currentMode = mode
                self?.modeButton.setTitle("▼ \(mode.rawValue)", for: .normal)
                self?.updateModelVisibility()
            }))
        }
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        if let popover = alert.popoverPresentationController {
            popover.sourceView = modeButton
            popover.sourceRect = modeButton.bounds
        }
        present(alert, animated: true)
    }
    
    @objc private func showImageModelPicker() {
        let alert = UIAlertController(title: "选择图片模型", message: nil, preferredStyle: .actionSheet)
        for model in imageModels {
            let mark = model == currentImageModel ? "✓ " : ""
            alert.addAction(UIAlertAction(title: "\(mark)\(model)", style: .default, handler: { [weak self] _ in
                self?.currentImageModel = model
                self?.imageModelButton.setTitle(model, for: .normal)
            }))
        }
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        if let popover = alert.popoverPresentationController {
            popover.sourceView = imageModelButton
            popover.sourceRect = imageModelButton.bounds
        }
        present(alert, animated: true)
    }
    
    @objc private func showVideoModelPicker() {
        let alert = UIAlertController(title: "选择视频模型", message: nil, preferredStyle: .actionSheet)
        for model in videoModels {
            let mark = model == currentVideoModel ? "✓ " : ""
            alert.addAction(UIAlertAction(title: "\(mark)\(model)", style: .default, handler: { [weak self] _ in
                self?.currentVideoModel = model
                self?.videoModelButton.setTitle(model, for: .normal)
            }))
        }
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        if let popover = alert.popoverPresentationController {
            popover.sourceView = videoModelButton
            popover.sourceRect = videoModelButton.bounds
        }
        present(alert, animated: true)
    }
    
    private func updateModelVisibility() {
        let dimColor = Theme.mutedGray
        switch currentMode {
        case .imageGen:
            videoModelButton.setTitleColor(dimColor, for: .normal)
            videoModelButton.alpha = 0.4
            imageModelButton.setTitleColor(Theme.brightWhite, for: .normal)
            imageModelButton.alpha = 1.0
        case .videoGen, .shortDrama:
            videoModelButton.setTitleColor(Theme.brightWhite, for: .normal)
            videoModelButton.alpha = 1.0
            imageModelButton.setTitleColor(Theme.brightWhite, for: .normal)
            imageModelButton.alpha = 1.0
        }
    }
    
    // MARK: - Send Message
    
    @objc private func sendMessage() {
        guard let text = textField.text?.trimmingCharacters(in: .whitespaces), !text.isEmpty, !isGenerating else { return }
        guard !apiKey.isEmpty else {
            showToast("请先在 趣我 → 系统设置 中配置 API Key")
            return
        }
        textField.text = ""
        textField.resignFirstResponder()
        
        let userMsg = ChatMessage(text: text, isUser: true)
        addMessage(userMsg)
        
        let loadingMsg = ChatMessage(text: currentMode == .shortDrama ? "🎬 正在创作剧情短片..." : "🤔 正在思考...", isUser: false, isLoading: true)
        addMessage(loadingMsg)
        isGenerating = true
        scrollToBottom()
        
        switch currentMode {
        case .imageGen:
            generateImage(prompt: text, loadingId: loadingMsg.id)
        case .videoGen:
            generateVideo(prompt: text, loadingId: loadingMsg.id)
        case .shortDrama:
            generateShortDrama(prompt: text, loadingId: loadingMsg.id)
        }
    }
    
    private func addMessage(_ msg: ChatMessage) {
        messages.append(msg)
        tableView.reloadData()
        scrollToBottom()
    }
    
    private func updateMessage(id: String, image: UIImage? = nil, videoURL: String? = nil, text: String? = nil, isLoading: Bool = false) {
        if let idx = messages.firstIndex(where: { $0.id == id }) {
            var msg = messages[idx]
            if let img = image { msg.image = img }
            if let url = videoURL { msg.videoURL = url }
            if let t = text { 
                var newMsg = ChatMessage(id: msg.id, text: t, isUser: msg.isUser, image: msg.image, videoURL: msg.videoURL, isLoading: isLoading, timestamp: msg.timestamp)
                messages[idx] = newMsg
            } else {
                messages[idx] = msg
            }
            tableView.reloadData()
            scrollToBottom()
        }
    }
    
    private func scrollToBottom() {
        guard !messages.isEmpty else { return }
        let idx = IndexPath(row: messages.count - 1, section: 0)
        tableView.scrollToRow(at: idx, at: .bottom, animated: true)
    }
    
    // MARK: - API Calls
    
    private func generateImage(prompt: String, loadingId: String) {
        guard let url = URL(string: "\(baseURL)/images/generations") else { return }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = ["model": currentImageModel, "prompt": prompt, "n": 1]
        req.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: req) { [weak self] data, _, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isGenerating = false
                if let data = data, let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let dataArr = json["data"] as? [[String: Any]], let first = dataArr.first,
                   let urlStr = first["url"] as? String, let imgUrl = URL(string: urlStr) {
                    URLSession.shared.dataTask(with: imgUrl) { imgData, _, _ in
                        DispatchQueue.main.async {
                            if let imgData = imgData, let image = UIImage(data: imgData) {
                                self.updateMessage(id: loadingId, image: image, text: "✅ 图片生成完成", isLoading: false)
                            } else {
                                self.updateMessage(id: loadingId, text: "❌ 图片下载失败", isLoading: false)
                            }
                        }
                    }.resume()
                } else {
                    let errMsg = (data.flatMap { try? JSONSerialization.jsonObject(with: $0) as? [String: Any] })?["error"] as? String ?? "生成失败"
                    self.updateMessage(id: loadingId, text: "❌ \(errMsg)", isLoading: false)
                }
            }
        }.resume()
    }
    
    private func generateVideo(prompt: String, loadingId: String) {
        guard let url = URL(string: "\(baseURL)/video/generations") else { return }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = ["model": currentVideoModel, "prompt": prompt, "n": 1]
        req.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: req) { [weak self] data, _, error in
            guard let self = self else { return }
            if let data = data, let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let taskId = json["id"] as? String {
                self.pollVideoTask(taskId: taskId, loadingId: loadingId)
            } else {
                DispatchQueue.main.async {
                    let errMsg = (data.flatMap { try? JSONSerialization.jsonObject(with: $0) as? [String: Any] })?["error"] as? String ?? "请求失败"
                    self.isGenerating = false
                    self.updateMessage(id: loadingId, text: "❌ \(errMsg)", isLoading: false)
                }
            }
        }.resume()
    }
    
    private func pollVideoTask(taskId: String, loadingId: String) {
        guard let url = URL(string: "\(baseURL)/video/generations/\(taskId)") else { return }
        var req = URLRequest(url: url)
        req.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        func poll() {
            URLSession.shared.dataTask(with: req) { [weak self] data, _, _ in
                guard let self = self else { return }
                if let data = data, let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    let status = json["status"] as? String ?? ""
                    DispatchQueue.main.async {
                        self.updateMessage(id: loadingId, text: "⏳ 视频生成中... \(status)", isLoading: true)
                    }
                    if status == "succeeded" || status == "completed" {
                        if let output = json["output"] as? String, let videoUrl = URL(string: output) {
                            self.downloadAndShowVideo(url: videoUrl, loadingId: loadingId)
                        } else if let outputArr = json["output"] as? [String], let firstUrl = outputArr.first, let videoUrl = URL(string: firstUrl) {
                            self.downloadAndShowVideo(url: videoUrl, loadingId: loadingId)
                        } else {
                            DispatchQueue.main.async {
                                self.isGenerating = false
                                self.updateMessage(id: loadingId, text: "❌ 未获取到视频地址", isLoading: false)
                            }
                        }
                    } else if status == "failed" {
                        DispatchQueue.main.async {
                            self.isGenerating = false
                            self.updateMessage(id: loadingId, text: "❌ 视频生成失败", isLoading: false)
                        }
                    } else {
                        DispatchQueue.global().asyncAfter(deadline: .now() + 2.0) { poll() }
                    }
                } else {
                    DispatchQueue.global().asyncAfter(deadline: .now() + 2.0) { poll() }
                }
            }.resume()
        }
        poll()
    }
    
    private func downloadAndShowVideo(url: URL, loadingId: String) {
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isGenerating = false
                if let data = data {
                    let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).mp4")
                    try? data.write(to: tempURL)
                    self.updateMessage(id: loadingId, videoURL: tempURL.absoluteString, text: "✅ 视频生成完成", isLoading: false)
                } else {
                    self.updateMessage(id: loadingId, text: "✅ 视频已生成（下载失败）\n\(url.absoluteString)", isLoading: false)
                }
            }
        }.resume()
    }
    
    private func generateShortDrama(prompt: String, loadingId: String) {
        guard let url = URL(string: "\(baseURL)/images/generations") else { return }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = ["model": currentImageModel, "prompt": prompt, "n": 1]
        req.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: req) { [weak self] data, _, _ in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if let data = data, let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let dataArr = json["data"] as? [[String: Any]], let first = dataArr.first,
                   let urlStr = first["url"] as? String, let imgUrl = URL(string: urlStr) {
                    URLSession.shared.dataTask(with: imgUrl) { imgData, _, _ in
                        DispatchQueue.main.async {
                            if let imgData = imgData, let image = UIImage(data: imgData) {
                                self.updateMessage(id: loadingId, image: image, text: "🎬 剧情画面已生成，正在生成视频...", isLoading: true)
                                self.generateVideoFromImage(prompt: prompt, loadingId: loadingId)
                            } else {
                                self.isGenerating = false
                                self.updateMessage(id: loadingId, text: "❌ 图片下载失败", isLoading: false)
                            }
                        }
                    }.resume()
                } else {
                    self.isGenerating = false
                    let errMsg = (data.flatMap { try? JSONSerialization.jsonObject(with: $0) as? [String: Any] })?["error"] as? String ?? "图片生成失败"
                    self.updateMessage(id: loadingId, text: "❌ \(errMsg)", isLoading: false)
                }
            }
        }.resume()
    }
    
    private func generateVideoFromImage(prompt: String, loadingId: String) {
        guard let url = URL(string: "\(baseURL)/video/generations") else { return }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = ["model": currentVideoModel, "prompt": prompt, "n": 1]
        req.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: req) { [weak self] data, _, _ in
            guard let self = self else { return }
            if let data = data, let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let taskId = json["id"] as? String {
                self.pollShortDramaVideo(taskId: taskId, loadingId: loadingId)
            } else {
                DispatchQueue.main.async {
                    self.isGenerating = false
                    self.updateMessage(id: loadingId, text: "✅ 画面已生成（视频生成请求失败）", isLoading: false)
                }
            }
        }.resume()
    }
    
    private func pollShortDramaVideo(taskId: String, loadingId: String) {
        guard let url = URL(string: "\(baseURL)/video/generations/\(taskId)") else { return }
        var req = URLRequest(url: url)
        req.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        func poll() {
            URLSession.shared.dataTask(with: req) { [weak self] data, _, _ in
                guard let self = self else { return }
                if let data = data, let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    let status = json["status"] as? String ?? ""
                    if status == "succeeded" || status == "completed" {
                        if let output = json["output"] as? String, let videoUrl = URL(string: output) {
                            self.downloadAndShowVideo(url: videoUrl, loadingId: loadingId)
                        } else if let outputArr = json["output"] as? [String], let firstUrl = outputArr.first, let videoUrl = URL(string: firstUrl) {
                            self.downloadAndShowVideo(url: videoUrl, loadingId: loadingId)
                        } else {
                            DispatchQueue.main.async {
                                self.isGenerating = false
                                self.updateMessage(id: loadingId, text: "🎬 剧情短片完成！", isLoading: false)
                            }
                        }
                    } else if status == "failed" {
                        DispatchQueue.main.async {
                            self.isGenerating = false
                            self.updateMessage(id: loadingId, text: "🎬 画面已生成（视频生成失败）", isLoading: false)
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.updateMessage(id: loadingId, text: "🎬 视频创作中...", isLoading: true)
                        }
                        DispatchQueue.global().asyncAfter(deadline: .now() + 2.0) { poll() }
                    }
                } else {
                    DispatchQueue.global().asyncAfter(deadline: .now() + 2.0) { poll() }
                }
            }.resume()
        }
        poll()
    }
    
    // MARK: - Helpers
    
    private func showToast(_ msg: String) {
        DispatchQueue.main.async {
            let label = UILabel()
            label.text = msg
            label.font = Theme.Font.regular(size: 14)
            label.textColor = .white
            label.backgroundColor = UIColor.black.withAlphaComponent(0.75)
            label.textAlignment = .center
            label.layer.cornerRadius = 10
            label.clipsToBounds = true
            label.sizeToFit()
            label.frame.size.width += 32
            label.frame.size.height += 16
            label.center = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.midY - 60)
            label.alpha = 0
            self.view.addSubview(label)
            UIView.animate(withDuration: 0.3, animations: { label.alpha = 1 }) { _ in
                UIView.animate(withDuration: 0.3, delay: 1.5, animations: { label.alpha = 0 }) { _ in label.removeFromSuperview() }
            }
        }
    }
    
    @objc private func saveVideo(_ sender: UIButton) {
        guard let urlStr = sender.titleLabel?.text, let url = URL(string: urlStr) else { return }
        showToast("⏳ 正在下载视频...")
        URLSession.shared.dataTask(with: url) { data, _, error in
            DispatchQueue.main.async {
                if let data = data, error == nil {
                    let temp = FileManager.default.temporaryDirectory.appendingPathComponent("temp_video.mp4")
                    try? data.write(to: temp)
                    UISaveVideoAtPathToSavedPhotosAlbum(temp.path, self, #selector(self.videoSaved(_:didFinishSavingWithError:contextInfo:)), nil)
                } else {
                    self.showToast("❌ 下载失败")
                }
            }
        }.resume()
    }
    
    @objc private func videoSaved(_ video: String, didFinishSavingWithError error: Error?, contextInfo: UnsafeMutableRawPointer) {
        showToast(error == nil ? "✅ 视频已保存到相册" : "❌ 保存失败")
    }
}

// MARK: - TableView

extension QuAIViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell", for: indexPath) as! ChatMessageCell
        let msg = messages[indexPath.row]
        cell.configure(with: msg, apiKeyMissing: apiKey.isEmpty)
        cell.onSaveVideo = { [weak self] url in
            guard let self = self else { return }
            self.showToast("⏳ 正在下载视频...")
            URLSession.shared.dataTask(with: url) { data, _, error in
                DispatchQueue.main.async {
                    if let data = data, error == nil {
                        let temp = FileManager.default.temporaryDirectory.appendingPathComponent("temp_video.mp4")
                        try? data.write(to: temp)
                        UISaveVideoAtPathToSavedPhotosAlbum(temp.path, self, #selector(self.videoSaved(_:didFinishSavingWithError:contextInfo:)), nil)
                    } else {
                        self.showToast("❌ 下载失败")
                    }
                }
            }.resume()
        }
        return cell
    }
}

// MARK: - TextField Delegate

extension QuAIViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendMessage()
        return true
    }
}

// MARK: - Chat Cell

class ChatMessageCell: UITableViewCell {
    private let bubbleView = UIView()
    private let msgLabel = UILabel()
    private let imagePreview = UIImageView()
    private let videoButton = UIButton()
    private let activityIndicator = UIActivityIndicatorView(style: .gray)
    
    var onSaveVideo: ((URL) -> Void)?
    private var videoURL: URL?
    private var bubbleLeading: NSLayoutConstraint!
    private var bubbleTrailing: NSLayoutConstraint!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        
        bubbleView.layer.cornerRadius = 16
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bubbleView)
        
        msgLabel.font = Theme.Font.regular(size: 14)
        msgLabel.numberOfLines = 0
        msgLabel.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.addSubview(msgLabel)
        
        imagePreview.contentMode = .scaleAspectFill
        imagePreview.layer.cornerRadius = 12
        imagePreview.clipsToBounds = true
        imagePreview.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.addSubview(imagePreview)
        
        videoButton.setTitle("▶ 保存视频", for: .normal)
        videoButton.titleLabel?.font = Theme.Font.bold(size: 13)
        videoButton.backgroundColor = Theme.neonPink
        videoButton.layer.cornerRadius = 12
        videoButton.translatesAutoresizingMaskIntoConstraints = false
        videoButton.addTarget(self, action: #selector(didTapSaveVideo), for: .touchUpInside)
        bubbleView.addSubview(videoButton)
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.addSubview(activityIndicator)
        
        bubbleLeading = bubbleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16)
        bubbleTrailing = bubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        bubbleLeading.isActive = false
        bubbleTrailing.isActive = false
        
        NSLayoutConstraint.activate([
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            bubbleView.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, multiplier: 0.8),
            
            msgLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 12),
            msgLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 14),
            msgLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -14),
            
            imagePreview.topAnchor.constraint(equalTo: msgLabel.bottomAnchor, constant: 8),
            imagePreview.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 8),
            imagePreview.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -8),
            imagePreview.heightAnchor.constraint(equalToConstant: 200),
            
            videoButton.topAnchor.constraint(equalTo: imagePreview.bottomAnchor, constant: 8),
            videoButton.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 8),
            videoButton.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -8),
            videoButton.heightAnchor.constraint(equalToConstant: 36),
            videoButton.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -8),
            
            activityIndicator.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor),
        ])
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imagePreview.image = nil
        videoButton.isHidden = true
        imagePreview.isHidden = true
        activityIndicator.stopAnimating()
        videoURL = nil
        bubbleLeading.isActive = false
        bubbleTrailing.isActive = false
    }
    
    func configure(with msg: ChatMessage, apiKeyMissing: Bool) {
        msgLabel.text = msg.text
        
        bubbleLeading.isActive = false
        bubbleTrailing.isActive = false
        
        if msg.isUser {
            bubbleView.backgroundColor = Theme.electricBlue.withAlphaComponent(0.25)
            bubbleTrailing.constant = -16
            bubbleTrailing.isActive = true
            msgLabel.textColor = Theme.brightWhite
        } else {
            bubbleView.backgroundColor = Theme.cardBackground.withAlphaComponent(0.7)
            bubbleLeading.constant = 16
            bubbleLeading.isActive = true
            msgLabel.textColor = Theme.brightWhite
        }
        
        if msg.isLoading && !apiKeyMissing {
            activityIndicator.startAnimating()
            imagePreview.isHidden = true
            videoButton.isHidden = true
        } else {
            activityIndicator.stopAnimating()
        }
        
        if let image = msg.image {
            imagePreview.image = image
            imagePreview.isHidden = false
        } else {
            imagePreview.isHidden = true
        }
        
        if let urlStr = msg.videoURL, let url = URL(string: urlStr) {
            videoURL = url
            videoButton.isHidden = false
        } else {
            videoButton.isHidden = true
        }
    }
    
    @objc private func didTapSaveVideo() {
        if let url = videoURL {
            onSaveVideo?(url)
        }
    }
}
