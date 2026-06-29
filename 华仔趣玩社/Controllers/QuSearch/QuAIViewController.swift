import UIKit

class QuAIViewController: UIViewController {
    
    private let agnesAPIKey = "" // 用户需要填入 Agnes API Key
    
    private var currentTab = 0
    private var tabButtons: [UIButton] = []
    private var tabViews: [UIView] = []
    
    private var chatVC: QuAIChatTabController!
    private var imageGenVC: QuAIImageGenTabController!
    private var imageEditVC: QuAIImageEditTabController!
    private var videoGenVC: QuAIVideoGenTabController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        showTab(index: 0)
    }
    
    override var prefersStatusBarHidden: Bool { true }
    override var prefersHomeIndicatorAutoHidden: Bool { true }
    
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
        
        let tabBar = UIView()
        tabBar.backgroundColor = Theme.cardBackground.withAlphaComponent(0.8)
        tabBar.layer.cornerRadius = 20
        tabBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tabBar)
        
        let tabs: [(String, String)] = [
            ("💬", "聊天"), ("🎨", "生图"), ("✏️", "修图"), ("🎬", "视频")
        ]
        
        let tabStack = UIStackView()
        tabStack.axis = .horizontal
        tabStack.distribution = .fillEqually
        tabStack.spacing = 4
        tabStack.translatesAutoresizingMaskIntoConstraints = false
        tabBar.addSubview(tabStack)
        
        for (i, tab) in tabs.enumerated() {
            let btn = UIButton(type: .system)
            let attrText = NSMutableAttributedString(string: "\(tab.0)  ", attributes: [.font: UIFont.systemFont(ofSize: 14)])
            attrText.append(NSAttributedString(string: tab.1, attributes: [.font: Theme.Font.regular(size: 12)]))
            btn.setAttributedTitle(attrText, for: .normal)
            btn.setTitleColor(Theme.mutedGray, for: .normal)
            btn.setTitleColor(Theme.brightWhite, for: .selected)
            btn.backgroundColor = .clear
            btn.layer.cornerRadius = 16
            btn.tag = i
            btn.addTarget(self, action: #selector(tabTapped(_:)), for: .touchUpInside)
            tabStack.addArrangedSubview(btn)
            tabButtons.append(btn)
        }
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            tabBar.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            tabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            tabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            tabBar.heightAnchor.constraint(equalToConstant: 44),
            
            tabStack.topAnchor.constraint(equalTo: tabBar.topAnchor, constant: 4),
            tabStack.leadingAnchor.constraint(equalTo: tabBar.leadingAnchor, constant: 4),
            tabStack.trailingAnchor.constraint(equalTo: tabBar.trailingAnchor, constant: -4),
            tabStack.bottomAnchor.constraint(equalTo: tabBar.bottomAnchor, constant: -4),
            
            containerView.topAnchor.constraint(equalTo: tabBar.bottomAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        chatVC = QuAIChatTabController(apiKey: agnesAPIKey)
        imageGenVC = QuAIImageGenTabController(apiKey: agnesAPIKey)
        imageEditVC = QuAIImageEditTabController(apiKey: agnesAPIKey)
        videoGenVC = QuAIVideoGenTabController(apiKey: agnesAPIKey)
        
        addChild(chatVC)
        addChild(imageGenVC)
        addChild(imageEditVC)
        addChild(videoGenVC)
        
        for vc in [chatVC, imageGenVC, imageEditVC, videoGenVC] {
            vc!.view.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview(vc!.view)
            vc!.didMove(toParent: self)
            NSLayoutConstraint.activate([
                vc!.view.topAnchor.constraint(equalTo: containerView.topAnchor),
                vc!.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                vc!.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                vc!.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
            ])
            vc!.view.isHidden = true
            tabViews.append(vc!.view)
        }
    }
    
    @objc private func tabTapped(_ sender: UIButton) {
        showTab(index: sender.tag)
    }
    
    private func showTab(index: Int) {
        currentTab = index
        for (i, btn) in tabButtons.enumerated() {
            btn.isSelected = i == index
            btn.backgroundColor = i == index ? Theme.electricBlue.withAlphaComponent(0.3) : .clear
        }
        for (i, view) in tabViews.enumerated() {
            view.isHidden = i != index
        }
    }
}

// MARK: - Chat Tab
class QuAIChatTabController: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate {
    
    private let apiKey: String
    private var messages: [(role: String, content: String)] = []
    private var tableView: UITableView!
    private var inputTextField: UITextField!
    private var isLoading = false
    private var searchToggle: UIButton!
    private var isSearchEnabled = false
    
    init(apiKey: String) {
        self.apiKey = apiKey
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        addWelcome()
    }
    
    private func setupUI() {
        tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ChatMessageCell.self, forCellReuseIdentifier: "ChatCell")
        tableView.keyboardDismissMode = .interactive
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        let inputBar = UIView()
        inputBar.backgroundColor = Theme.cardBackground.withAlphaComponent(0.9)
        inputBar.layer.cornerRadius = 22
        inputBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(inputBar)
        
        inputTextField = UITextField()
        inputTextField.placeholder = "问我任何问题..."
        inputTextField.font = Theme.Font.regular(size: 15)
        inputTextField.textColor = Theme.brightWhite
        inputTextField.attributedPlaceholder = NSAttributedString(string: "问我任何问题...", attributes: [.foregroundColor: Theme.mutedGray])
        inputTextField.returnKeyType = .send
        inputTextField.delegate = self
        inputTextField.translatesAutoresizingMaskIntoConstraints = false
        inputBar.addSubview(inputTextField)
        
        let sendBtn = UIButton(type: .system)
        sendBtn.setTitle("➤", for: .normal)
        sendBtn.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        sendBtn.setTitleColor(Theme.electricBlue, for: .normal)
        sendBtn.translatesAutoresizingMaskIntoConstraints = false
        sendBtn.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        inputBar.addSubview(sendBtn)
        
        searchToggle = UIButton(type: .system)
        searchToggle.setTitle("🌐 联网搜索: 关闭", for: .normal)
        searchToggle.titleLabel?.font = Theme.Font.regular(size: 11)
        searchToggle.setTitleColor(Theme.mutedGray, for: .normal)
        searchToggle.translatesAutoresizingMaskIntoConstraints = false
        searchToggle.addTarget(self, action: #selector(toggleSearch), for: .touchUpInside)
        view.addSubview(searchToggle)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: searchToggle.topAnchor, constant: -4),
            
            searchToggle.bottomAnchor.constraint(equalTo: inputBar.topAnchor, constant: -4),
            searchToggle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            searchToggle.heightAnchor.constraint(equalToConstant: 24),
            
            inputBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            inputBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            inputBar.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8),
            inputBar.heightAnchor.constraint(equalToConstant: 44),
            
            inputTextField.leadingAnchor.constraint(equalTo: inputBar.leadingAnchor, constant: 16),
            inputTextField.centerYAnchor.constraint(equalTo: inputBar.centerYAnchor),
            inputTextField.trailingAnchor.constraint(equalTo: sendBtn.leadingAnchor, constant: -8),
            
            sendBtn.trailingAnchor.constraint(equalTo: inputBar.trailingAnchor, constant: -12),
            sendBtn.centerYAnchor.constraint(equalTo: inputBar.centerYAnchor),
            sendBtn.widthAnchor.constraint(equalToConstant: 36)
        ])
    }
    
    private func addWelcome() {
        messages.append(("assistant", "👋 你好！我是趣AI助手\n\n我可以帮你：\n• 💬 回答各种问题\n• 🌐 联网搜索信息\n• 📝 写作辅助\n• 🧮 数学计算\n\n有什么我可以帮你的吗？"))
        tableView.reloadData()
    }
    
    @objc private func toggleSearch() {
        isSearchEnabled.toggle()
        searchToggle.setTitle(isSearchEnabled ? "🌐 联网搜索: 开启" : "🌐 联网搜索: 关闭", for: .normal)
        searchToggle.setTitleColor(isSearchEnabled ? Theme.electricBlue : Theme.mutedGray, for: .normal)
    }
    
    @objc private func sendMessage() {
        guard let text = inputTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty else { return }
        inputTextField.text = ""
        
        messages.append(("user", text))
        tableView.reloadData()
        scrollToBottom()
        
        let thinkingIndex = messages.count
        messages.append(("assistant", "思考中..."))
        tableView.reloadData()
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            var searchResults = ""
            if self.isSearchEnabled {
                searchResults = self.searchWeb(query: text)
            }
            
            let response = self.callAgnesChat(prompt: text, searchResults: searchResults)
            
            DispatchQueue.main.async {
                self.messages[thinkingIndex] = ("assistant", response)
                self.tableView.reloadData()
                self.scrollToBottom()
            }
        }
    }
    
    private func callAgnesChat(prompt: String, searchResults: String) -> String {
        guard !apiKey.isEmpty else {
            return "⚠️ 请先配置 Agnes API Key\n\n在 QuAIViewController.swift 中设置 agnesAPIKey"
        }
        guard let url = URL(string: "https://apihub.agnes-ai.com/v1/chat/completions") else { return "网络错误" }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let systemPrompt = searchResults.isEmpty ? "你是一个友好的AI助手，名叫趣AI。请用中文回答。" : "你是一个友好的AI助手，名叫趣AI。请用中文回答。以下是联网搜索结果供参考：\n\(searchResults)"
        
        let body: [String: Any] = [
            "model": "agnes-1.5-flash",
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.7,
            "max_tokens": 2048
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        let sema = DispatchSemaphore(value: 0)
        var result = ""
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let data = data, let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let choices = json["choices"] as? [[String: Any]],
               let first = choices.first,
               let msg = first["message"] as? [String: Any],
               let content = msg["content"] as? String {
                result = content
            } else {
                result = "抱歉，请求失败。请检查 API Key 是否正确。"
            }
            sema.signal()
        }.resume()
        sema.wait()
        return result
    }
    
    private func searchWeb(query: String) -> String {
        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        guard let url = URL(string: "https://html.duckduckgo.com/html/?q=\(encoded)") else { return "" }
        
        var req = URLRequest(url: url)
        req.setValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Safari/605.1.15", forHTTPHeaderField: "User-Agent")
        req.timeoutInterval = 10
        
        let sema = DispatchSemaphore(value: 0)
        var results = ""
        
        URLSession.shared.dataTask(with: req) { data, _, _ in
            if let data = data, let html = String(data: data, encoding: .utf8) {
                let pattern = "<a class=\"result__a\"[^>]*>(.*?)</a>"
                if let regex = try? NSRegularExpression(pattern: pattern) {
                    let matches = regex.matches(in: html, range: NSRange(html.startIndex..., in: html))
                    for i in 0..<min(matches.count, 5) {
                        if let r = Range(matches[i].range(at: 1), in: html) {
                            let title = String(html[r]).replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression).trimmingCharacters(in: .whitespacesAndNewlines)
                            if !title.isEmpty { results += "\(i+1). \(title)\n" }
                        }
                    }
                }
            }
            sema.signal()
        }.resume()
        sema.wait()
        return results
    }
    
    private func scrollToBottom() {
        guard messages.count > 0 else { return }
        tableView.scrollToRow(at: IndexPath(row: messages.count - 1, section: 0), at: .bottom, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { messages.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell", for: indexPath) as! ChatMessageCell
        let msg = messages[indexPath.row]
        cell.configure(msg.role == "user" ? "👤" : "🤖", message: msg.content == "思考中..." ? "" : msg.content, isUser: msg.role == "user", isSearching: msg.content == "思考中...")
        return cell
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool { sendMessage(); return true }
}

// MARK: - Image Generation Tab
class QuAIImageGenTabController: UIViewController {
    
    private let apiKey: String
    init(apiKey: String) { self.apiKey = apiKey; super.init(nibName: nil, bundle: nil) }
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stack)
        
        let promptField = UITextField()
        promptField.placeholder = "描述你想生成的图片..."
        promptField.font = Theme.Font.regular(size: 15)
        promptField.textColor = Theme.brightWhite
        promptField.backgroundColor = Theme.cardBackground.withAlphaComponent(0.6)
        promptField.layer.cornerRadius = 12
        promptField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
        promptField.leftViewMode = .always
        promptField.translatesAutoresizingMaskIntoConstraints = false
        promptField.heightAnchor.constraint(equalToConstant: 44).isActive = true
        promptField.tag = 100
        stack.addArrangedSubview(promptField)
        
        let sizePicker = UISegmentedControl(items: ["1024x768", "1024x1024", "768x1024"])
        sizePicker.selectedSegmentIndex = 0
        sizePicker.tag = 101
        stack.addArrangedSubview(sizePicker)
        
        let genBtn = UIButton(type: .system)
        genBtn.setTitle("🎨 生成图片", for: .normal)
        genBtn.titleLabel?.font = Theme.Font.bold(size: 18)
        genBtn.setTitleColor(.white, for: .normal)
        genBtn.backgroundColor = Theme.electricBlue
        genBtn.layer.cornerRadius = 12
        genBtn.translatesAutoresizingMaskIntoConstraints = false
        genBtn.heightAnchor.constraint(equalToConstant: 48).isActive = true
        genBtn.addTarget(self, action: #selector(generateImage), for: .touchUpInside)
        stack.addArrangedSubview(genBtn)
        
        let progressView = UIProgressView()
        progressView.tag = 102
        progressView.isHidden = true
        stack.addArrangedSubview(progressView)
        
        let resultImageView = UIImageView()
        resultImageView.contentMode = .scaleAspectFit
        resultImageView.backgroundColor = Theme.cardBackground.withAlphaComponent(0.3)
        resultImageView.layer.cornerRadius = 12
        resultImageView.clipsToBounds = true
        resultImageView.translatesAutoresizingMaskIntoConstraints = false
        resultImageView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        resultImageView.tag = 103
        stack.addArrangedSubview(resultImageView)
        
        let downloadBtn = UIButton(type: .system)
        downloadBtn.setTitle("💾 保存到相册", for: .normal)
        downloadBtn.titleLabel?.font = Theme.Font.bold(size: 16)
        downloadBtn.setTitleColor(Theme.neonPink, for: .normal)
        downloadBtn.backgroundColor = Theme.cardBackground.withAlphaComponent(0.6)
        downloadBtn.layer.cornerRadius = 12
        downloadBtn.translatesAutoresizingMaskIntoConstraints = false
        downloadBtn.heightAnchor.constraint(equalToConstant: 44).isActive = true
        downloadBtn.addTarget(self, action: #selector(saveImage), for: .touchUpInside)
        downloadBtn.tag = 104
        downloadBtn.isHidden = true
        stack.addArrangedSubview(downloadBtn)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stack.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            stack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])
    }
    
    @objc private func generateImage() {
        guard !apiKey.isEmpty else {
            showToast("⚠️ 请先配置 Agnes API Key")
            return
        }
        guard let prompt = (view.viewWithTag(100) as? UITextField)?.text, !prompt.isEmpty else {
            showToast("请输入图片描述")
            return
        }
        
        let sizes = ["1024x768", "1024x1024", "768x1024"]
        let selIdx = (view.viewWithTag(101) as? UISegmentedControl)?.selectedSegmentIndex ?? 0
        let size = sizes[selIdx]
        
        let progress = view.viewWithTag(102) as! UIProgressView
        progress.isHidden = false
        progress.progress = 0
        
        let resultView = view.viewWithTag(103) as! UIImageView
        resultView.image = nil
        let downloadBtn = view.viewWithTag(104) as! UIButton
        downloadBtn.isHidden = true
        
        UIView.animate(withDuration: 0.1) { progress.setProgress(0.3, animated: true) }
        
        guard let url = URL(string: "https://apihub.agnes-ai.com/v1/images/generations") else { return }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = ["model": "agnes-image-2.0-flash", "prompt": prompt, "size": size, "n": 1]
        req.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: req) { [weak self] data, _, _ in
            DispatchQueue.main.async {
                progress.setProgress(0.8, animated: true)
                if let data = data, let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let dataArr = json["data"] as? [[String: Any]], let first = dataArr.first,
                   let urlStr = first["url"] as? String, let imgUrl = URL(string: urlStr) {
                    URLSession.shared.dataTask(with: imgUrl) { imgData, _, _ in
                        DispatchQueue.main.async {
                            progress.setProgress(1.0, animated: true)
                            if let imgData = imgData, let image = UIImage(data: imgData) {
                                resultView.image = image
                                downloadBtn.isHidden = false
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { progress.isHidden = true }
                        }
                    }.resume()
                } else {
                    showToast("生成失败，请重试")
                    progress.isHidden = true
                }
            }
        }.resume()
    }
    
    @objc private func saveImage() {
        guard let image = (view.viewWithTag(103) as? UIImageView)?.image else { return }
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(imageSaved(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc private func imageSaved(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeMutableRawPointer) {
        showToast(error == nil ? "✅ 保存成功" : "❌ 保存失败")
    }
    
    private func showToast(_ msg: String) {
        let label = UILabel()
        label.text = msg
        label.textColor = .white
        label.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.textAlignment = .center
        label.font = Theme.Font.regular(size: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.widthAnchor.constraint(lessThanOrEqualToConstant: 250),
            label.heightAnchor.constraint(equalToConstant: 36)
        ])
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { label.removeFromSuperview() }
    }
}

// MARK: - Image Edit Tab
class QuAIImageEditTabController: UIViewController {
    
    private let apiKey: String
    init(apiKey: String) { self.apiKey = apiKey; super.init(nibName: nil, bundle: nil) }
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private var selectedImage: UIImage?
    
    private func setupUI() {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stack)
        
        let importBtn = UIButton(type: .system)
        importBtn.setTitle("📷 选择图片", for: .normal)
        importBtn.titleLabel?.font = Theme.Font.bold(size: 16)
        importBtn.setTitleColor(.white, for: .normal)
        importBtn.backgroundColor = UIColor(hex: "3498DB")
        importBtn.layer.cornerRadius = 12
        importBtn.translatesAutoresizingMaskIntoConstraints = false
        importBtn.heightAnchor.constraint(equalToConstant: 48).isActive = true
        importBtn.addTarget(self, action: #selector(selectImage), for: .touchUpInside)
        stack.addArrangedSubview(importBtn)
        
        let promptField = UITextField()
        promptField.placeholder = "编辑指令，如: 改为卡通风格、增加滤镜..."
        promptField.font = Theme.Font.regular(size: 15)
        promptField.textColor = Theme.brightWhite
        promptField.backgroundColor = Theme.cardBackground.withAlphaComponent(0.6)
        promptField.layer.cornerRadius = 12
        promptField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
        promptField.leftViewMode = .always
        promptField.translatesAutoresizingMaskIntoConstraints = false
        promptField.heightAnchor.constraint(equalToConstant: 44).isActive = true
        promptField.tag = 200
        stack.addArrangedSubview(promptField)
        
        let editBtn = UIButton(type: .system)
        editBtn.setTitle("✏️ 开始修图", for: .normal)
        editBtn.titleLabel?.font = Theme.Font.bold(size: 18)
        editBtn.setTitleColor(.white, for: .normal)
        editBtn.backgroundColor = Theme.neonPink
        editBtn.layer.cornerRadius = 12
        editBtn.translatesAutoresizingMaskIntoConstraints = false
        editBtn.heightAnchor.constraint(equalToConstant: 48).isActive = true
        editBtn.addTarget(self, action: #selector(editImage), for: .touchUpInside)
        stack.addArrangedSubview(editBtn)
        
        let progress = UIProgressView()
        progress.tag = 201
        progress.isHidden = true
        stack.addArrangedSubview(progress)
        
        let preview = UIImageView()
        preview.contentMode = .scaleAspectFit
        preview.backgroundColor = Theme.cardBackground.withAlphaComponent(0.3)
        preview.layer.cornerRadius = 12
        preview.clipsToBounds = true
        preview.translatesAutoresizingMaskIntoConstraints = false
        preview.heightAnchor.constraint(equalToConstant: 300).isActive = true
        preview.tag = 202
        stack.addArrangedSubview(preview)
        
        let downloadBtn = UIButton(type: .system)
        downloadBtn.setTitle("💾 保存到相册", for: .normal)
        downloadBtn.titleLabel?.font = Theme.Font.bold(size: 16)
        downloadBtn.setTitleColor(Theme.neonPink, for: .normal)
        downloadBtn.backgroundColor = Theme.cardBackground.withAlphaComponent(0.6)
        downloadBtn.layer.cornerRadius = 12
        downloadBtn.translatesAutoresizingMaskIntoConstraints = false
        downloadBtn.heightAnchor.constraint(equalToConstant: 44).isActive = true
        downloadBtn.addTarget(self, action: #selector(saveEdited), for: .touchUpInside)
        downloadBtn.tag = 203
        downloadBtn.isHidden = true
        stack.addArrangedSubview(downloadBtn)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stack.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            stack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])
    }
    
    @objc private func selectImage() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @objc private func editImage() {
        guard !apiKey.isEmpty else { showToast("请先配置 Agnes API Key"); return }
        guard let image = selectedImage else { showToast("请先选择图片"); return }
        guard let prompt = (view.viewWithTag(200) as? UITextField)?.text, !prompt.isEmpty else { showToast("请输入编辑指令"); return }
        
        let progress = view.viewWithTag(201) as! UIProgressView
        progress.isHidden = false
        progress.progress = 0
        progress.setProgress(0.2, animated: true)
        
        guard let imgData = image.jpegData(compressionQuality: 0.8) else { return }
        let base64 = imgData.base64EncodedString()
        let dataURI = "data:image/jpeg;base64,\(base64)"
        
        guard let url = URL(string: "https://apihub.agnes-ai.com/v1/images/generations") else { return }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = [
            "model": "agnes-image-2.0-flash",
            "prompt": prompt,
            "size": "1024x1024",
            "image": [dataURI]
        ]
        req.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        progress.setProgress(0.5, animated: true)
        
        URLSession.shared.dataTask(with: req) { [weak self] data, _, _ in
            DispatchQueue.main.async {
                progress.setProgress(0.8, animated: true)
                if let data = data, let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let dataArr = json["data"] as? [[String: Any]], let first = dataArr.first,
                   let urlStr = first["url"] as? String, let imgUrl = URL(string: urlStr) {
                    URLSession.shared.dataTask(with: imgUrl) { imgData, _, _ in
                        DispatchQueue.main.async {
                            progress.setProgress(1.0, animated: true)
                            if let imgData = imgData, let image = UIImage(data: imgData) {
                                let preview = self?.view.viewWithTag(202) as? UIImageView
                                preview?.image = image
                                self?.view.viewWithTag(203)?.isHidden = false
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { progress.isHidden = true }
                        }
                    }.resume()
                } else {
                    showToast("修图失败，请重试")
                    progress.isHidden = true
                }
            }
        }.resume()
    }
    
    @objc private func saveEdited() {
        guard let image = (view.viewWithTag(202) as? UIImageView)?.image else { return }
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(imageSaved(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc private func imageSaved(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeMutableRawPointer) {
        showToast(error == nil ? "✅ 保存成功" : "❌ 保存失败")
    }
    
    private func showToast(_ msg: String) {
        let label = UILabel()
        label.text = msg
        label.textColor = .white
        label.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.textAlignment = .center
        label.font = Theme.Font.regular(size: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.widthAnchor.constraint(lessThanOrEqualToConstant: 250),
            label.heightAnchor.constraint(equalToConstant: 36)
        ])
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { label.removeFromSuperview() }
    }
}

extension QuAIImageEditTabController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)
        selectedImage = info[.originalImage] as? UIImage
        let preview = view.viewWithTag(202) as? UIImageView
        preview?.image = selectedImage
        showToast("✅ 图片已选择")
    }
}

// MARK: - Video Generation Tab
class QuAIVideoGenTabController: UIViewController {
    
    private let apiKey: String
    init(apiKey: String) { self.apiKey = apiKey; super.init(nibName: nil, bundle: nil) }
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stack)
        
        let promptField = UITextField()
        promptField.placeholder = "描述视频场景..."
        promptField.font = Theme.Font.regular(size: 15)
        promptField.textColor = Theme.brightWhite
        promptField.backgroundColor = Theme.cardBackground.withAlphaComponent(0.6)
        promptField.layer.cornerRadius = 12
        promptField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
        promptField.leftViewMode = .always
        promptField.translatesAutoresizingMaskIntoConstraints = false
        promptField.heightAnchor.constraint(equalToConstant: 44).isActive = true
        promptField.tag = 300
        stack.addArrangedSubview(promptField)
        
        let genBtn = UIButton(type: .system)
        genBtn.setTitle("🎬 生成视频", for: .normal)
        genBtn.titleLabel?.font = Theme.Font.bold(size: 18)
        genBtn.setTitleColor(.white, for: .normal)
        genBtn.backgroundColor = UIColor(hex: "9B59B6")
        genBtn.layer.cornerRadius = 12
        genBtn.translatesAutoresizingMaskIntoConstraints = false
        genBtn.heightAnchor.constraint(equalToConstant: 48).isActive = true
        genBtn.addTarget(self, action: #selector(generateVideo), for: .touchUpInside)
        stack.addArrangedSubview(genBtn)
        
        let progress = UIProgressView()
        progress.tag = 301
        progress.isHidden = true
        stack.addArrangedSubview(progress)
        
        let statusLabel = UILabel()
        statusLabel.text = ""
        statusLabel.textColor = Theme.mutedGray
        statusLabel.font = Theme.Font.regular(size: 14)
        statusLabel.textAlignment = .center
        statusLabel.tag = 302
        stack.addArrangedSubview(statusLabel)
        
        let preview = UIImageView()
        preview.contentMode = .scaleAspectFit
        preview.backgroundColor = Theme.cardBackground.withAlphaComponent(0.3)
        preview.layer.cornerRadius = 12
        preview.clipsToBounds = true
        preview.translatesAutoresizingMaskIntoConstraints = false
        preview.heightAnchor.constraint(equalToConstant: 200).isActive = true
        preview.tag = 303
        stack.addArrangedSubview(preview)
        
        let downloadBtn = UIButton(type: .system)
        downloadBtn.setTitle("💾 保存视频", for: .normal)
        downloadBtn.titleLabel?.font = Theme.Font.bold(size: 16)
        downloadBtn.setTitleColor(Theme.neonPink, for: .normal)
        downloadBtn.backgroundColor = Theme.cardBackground.withAlphaComponent(0.6)
        downloadBtn.layer.cornerRadius = 12
        downloadBtn.translatesAutoresizingMaskIntoConstraints = false
        downloadBtn.heightAnchor.constraint(equalToConstant: 44).isActive = true
        downloadBtn.addTarget(self, action: #selector(saveVideo), for: .touchUpInside)
        downloadBtn.tag = 304
        downloadBtn.isHidden = true
        stack.addArrangedSubview(downloadBtn)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stack.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            stack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])
    }
    
    private var videoURL: URL?
    private var videoId: String?
    
    @objc private func generateVideo() {
        guard !apiKey.isEmpty else { showToast("请先配置 Agnes API Key"); return }
        guard let prompt = (view.viewWithTag(300) as? UITextField)?.text, !prompt.isEmpty else { showToast("请输入视频描述"); return }
        
        let progress = view.viewWithTag(301) as! UIProgressView
        let statusLabel = view.viewWithTag(302) as! UILabel
        progress.isHidden = false
        progress.progress = 0
        statusLabel.text = "⏳ 创建任务中..."
        
        guard let url = URL(string: "https://apihub.agnes-ai.com/v1/videos") else { return }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = [
            "model": "agnes-video-v2.0",
            "prompt": prompt,
            "height": 768,
            "width": 1152,
            "num_frames": 81,
            "frame_rate": 24
        ]
        req.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        progress.setProgress(0.2, animated: true)
        statusLabel.text = "⏳ 任务已提交，等待处理..."
        
        URLSession.shared.dataTask(with: req) { [weak self] data, _, _ in
            guard let self = self else { return }
            if let data = data, let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                self.videoId = json["video_id"] as? String
                let taskId = json["task_id"] as? String
                print("Video task created: video_id=\(self.videoId ?? ""), task_id=\(taskId ?? "")")
                
                DispatchQueue.main.async {
                    progress.setProgress(0.4, animated: true)
                    statusLabel.text = "⏳ 生成中，请耐心等待（约1-3分钟）..."
                    self.pollVideoResult()
                }
            } else {
                DispatchQueue.main.async {
                    statusLabel.text = "❌ 任务创建失败"
                    progress.isHidden = true
                }
            }
        }.resume()
    }
    
    private func pollVideoResult() {
        guard let vid = videoId else { return }
        
        let progress = view.viewWithTag(301) as! UIProgressView
        let statusLabel = view.viewWithTag(302) as! UILabel
        let preview = view.viewWithTag(303) as! UIImageView
        
        var pollCount = 0
        let maxPolls = 60
        
        func poll() {
            guard pollCount < maxPolls else {
                DispatchQueue.main.async {
                    statusLabel.text = "⏰ 生成超时，请重试"
                    progress.isHidden = true
                }
                return
            }
            
            guard let url = URL(string: "https://apihub.agnes-ai.com/agnesapi?video_id=\(vid)") else { return }
            var req = URLRequest(url: url)
            req.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            
            pollCount += 1
            
            URLSession.shared.dataTask(with: req) { data, _, _ in
                if let data = data, let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    let status = json["status"] as? String ?? ""
                    let p = min(0.4 + Double(pollCount) * 0.01, 0.95)
                    
                    DispatchQueue.main.async {
                        progress.setProgress(Float(p), animated: true)
                        statusLabel.text = status == "completed" ? "✅ 生成完成！" : "⏳ 生成中 (\(pollCount)s)..."
                        
                        if status == "completed" {
                            if let videoUrlStr = json["video_url"] as? String,
                               let videoUrl = URL(string: videoUrlStr) {
                                self.videoURL = videoUrl
                                preview.image = UIImage(named: "video_placeholder")
                                progress.setProgress(1.0, animated: true)
                                self.view.viewWithTag(304)?.isHidden = false
                                statusLabel.text = "✅ 视频生成完成！"
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { progress.isHidden = true }
                                return
                            }
                        } else if status == "failed" {
                            statusLabel.text = "❌ 生成失败"
                            progress.isHidden = true
                            return
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { poll() }
                    }
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { poll() }
                }
            }.resume()
        }
        
        poll()
    }
    
    @objc private func saveVideo() {
        guard let videoURL = videoURL else { showToast("没有可保存的视频"); return }
        showToast("⏳ 正在下载视频...")
        
        URLSession.shared.dataTask(with: videoURL) { [weak self] data, _, _ in
            guard let data = data else { return }
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("agnes_video.mp4")
            try? data.write(to: tempURL)
            
            if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(tempURL.path) {
                UISaveVideoAtPathToSavedPhotosAlbum(tempURL.path, self, #selector(self?.videoSaved(_:didFinishSavingWithError:contextInfo:)), nil)
            }
        }.resume()
    }
    
    @objc private func videoSaved(_ videoPath: String, didFinishSavingWithError error: Error?, contextInfo: UnsafeMutableRawPointer) {
        showToast(error == nil ? "✅ 视频已保存到相册" : "❌ 保存失败: \(error!.localizedDescription)")
    }
    
    private func showToast(_ msg: String) {
        let label = UILabel()
        label.text = msg
        label.textColor = .white
        label.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.textAlignment = .center
        label.font = Theme.Font.regular(size: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.widthAnchor.constraint(lessThanOrEqualToConstant: 250),
            label.heightAnchor.constraint(equalToConstant: 36)
        ])
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { label.removeFromSuperview() }
    }
}

// MARK: - Chat Message Cell
class ChatMessageCell: UITableViewCell {
    private let avatarLabel = UILabel()
    private let messageLabel = UILabel()
    private let bubbleView = UIView()
    private let spinner = UIActivityIndicatorView(style: .gray)
    private var avatarLeading: NSLayoutConstraint!
    private var avatarTrailing: NSLayoutConstraint!
    private var bubbleLeading: NSLayoutConstraint!
    private var bubbleTrailing: NSLayoutConstraint!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        
        avatarLabel.font = UIFont.systemFont(ofSize: 24)
        avatarLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(avatarLabel)
        
        bubbleView.layer.cornerRadius = 14
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bubbleView)
        
        messageLabel.font = Theme.Font.regular(size: 14)
        messageLabel.numberOfLines = 0
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.addSubview(messageLabel)
        
        spinner.hidesWhenStopped = true
        spinner.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.addSubview(spinner)
        
        avatarLeading = avatarLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12)
        avatarTrailing = avatarLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12)
        bubbleLeading = bubbleView.leadingAnchor.constraint(equalTo: avatarLabel.trailingAnchor, constant: 8)
        bubbleTrailing = bubbleView.trailingAnchor.constraint(equalTo: avatarLabel.leadingAnchor, constant: -8)
        
        NSLayoutConstraint.activate([
            avatarLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            avatarLabel.widthAnchor.constraint(equalToConstant: 32),
            avatarLabel.heightAnchor.constraint(equalToConstant: 32),
            
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            bubbleView.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, multiplier: 0.75),
            
            messageLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 10),
            messageLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 12),
            messageLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -12),
            messageLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -10),
            
            spinner.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func configure(_ avatar: String, message: String, isUser: Bool, isSearching: Bool) {
        avatarLabel.text = avatar
        
        avatarLeading.isActive = false
        avatarTrailing.isActive = false
        bubbleLeading.isActive = false
        bubbleTrailing.isActive = false
        
        if isUser {
            avatarLabel.textAlignment = .right
            avatarTrailing.isActive = true
            bubbleView.backgroundColor = Theme.electricBlue.withAlphaComponent(0.25)
            bubbleTrailing.isActive = true
        } else {
            avatarLabel.textAlignment = .left
            avatarLeading.isActive = true
            bubbleView.backgroundColor = Theme.cardBackground.withAlphaComponent(0.7)
            bubbleLeading.isActive = true
        }
        
        if isSearching {
            messageLabel.isHidden = true
            spinner.startAnimating()
        } else {
            messageLabel.isHidden = false
            messageLabel.text = message
            spinner.stopAnimating()
        }
    }
}
