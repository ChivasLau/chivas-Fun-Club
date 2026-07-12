import UIKit

enum AIMode: String, CaseIterable {
    case chat = "聊天"
    case shortDrama = "剧情短片"
    case imageGen = "图片生成"
    case videoGen = "视频生成"
    case imageToVideo = "图生视频"
    case pavo = "Pavo 剧情工厂"
}

class QuAIViewController: UIViewController {

    private var sessions: [ChatSession] = []
    private var currentSession: ChatSession!
    private var currentMessages: [ChatMessage] = []
    
    // 侧栏
    private var sidebarView: UIView!
    private var sidebarWidthConstraint: NSLayoutConstraint!
    private var sidebarCollapsed = true
    private let sidebarWidth: CGFloat = 260
    private var sessionTable: UITableView!
    private var dimView: UIView!
    
    // 主区域
    private let chatTable = UITableView()
    private let bottomBar = UIView()
    private let modeButton = UIButton()
    private let imageModelButton = UIButton()
    private let videoModelButton = UIButton()
    private let textField = UITextField()
    private let sendButton = UIButton()
    private let menuButton = UIButton()
    private var bottomBarBottomConstraint: NSLayoutConstraint!
    
    private var currentMode: AIMode = .shortDrama
    private var currentImageModel = "agnes-image-2.0-flash"
    private var currentVideoModel = "agnes-video-v2.0"
    
    private let imageModels = ["agnes-image-2.0-flash", "agnes-image-2.1-flash"]
    private let videoModels = ["agnes-video-v2.0"]
    private var isGenerating = false
    
    // 图生视频
    private var selectedImageForVideo: UIImage?
    private var imagePreviewInBar: UIImageView?
    private let beeimgToken = "2058|bEouQ9HmHO1EnXCUK75hKZrg07WnTDZIGRH0QoBL6483d1c3"
    
    private var apiKey: String {
        UserDefaults.standard.string(forKey: "agnes_api_key") ?? ""
    }
    private let baseURL = "https://apihub.agnes-ai.com/v1"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sessions = ChatSession.loadAll()
        if sessions.isEmpty {
            currentSession = ChatSession.create(title: "新对话")
            sessions.append(currentSession)
            currentSession.save()
        } else {
            currentSession = sessions.first!
        }
        loadMessages(for: currentSession)
        setupUI()
        updateModeUI()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func keyboardWillShow(_ n: Notification) {
        guard let frame = (n.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
              let duration = (n.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue else { return }
        let keyboardH = frame.height
        bottomBarBottomConstraint.constant = -keyboardH - 8
        UIView.animate(withDuration: duration) { self.view.layoutIfNeeded() }
    }

    @objc private func keyboardWillHide(_ n: Notification) {
        let duration = (n.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.25
        bottomBarBottomConstraint.constant = -8
        UIView.animate(withDuration: duration) { self.view.layoutIfNeeded() }
    }
    
    override var prefersStatusBarHidden: Bool { true }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    // MARK: - Session Message Loading
    
    private func loadMessages(for session: ChatSession) {
        currentMessages = session.messages.map { cm in
            let image = cm.imagePath.flatMap { ChatSession.loadImage(path: $0) }
            return ChatMessage(id: cm.id, text: cm.text, isUser: cm.isUser, image: image, videoURL: cm.videoURL.flatMap { URL(string: $0) }, isLoading: false, timestamp: cm.timestamp)
        }
    }
    
    private func saveCurrentSession() {
        let codableMessages = currentMessages.map { msg in
            CodableMessage(id: msg.id, text: msg.text, isUser: msg.isUser, imagePath: nil, videoURL: msg.videoURL?.absoluteString, isLoading: false, timestamp: msg.timestamp)
        }
        currentSession.messages = codableMessages
        currentSession.updatedAt = Date()
        currentSession.save()
    }
    
    private func switchSession(_ session: ChatSession) {
        saveCurrentSession()
        currentSession = session
        loadMessages(for: session)
        chatTable.reloadData()
        scrollToBottom()
        toggleSidebar()
    }
    
    private func newSession() {
        saveCurrentSession()
        let session = ChatSession.create(title: "新对话")
        sessions.insert(session, at: 0)
        currentSession = session
        currentMessages = []
        session.save()
        chatTable.reloadData()
        sessionTable.reloadData()
        toggleSidebar()
    }
    
    private func deleteSession(at index: Int) {
        guard sessions.count > 1 else { return }
        let session = sessions[index]
        session.delete()
        sessions.remove(at: index)
        if session.id == currentSession.id {
            currentSession = sessions.first!
            loadMessages(for: currentSession)
            chatTable.reloadData()
        }
        sessionTable.reloadData()
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        let gradientBg = GradientBackgroundView(frame: view.bounds)
        gradientBg.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(gradientBg)
        
        // 标题
        let titleLabel = UILabel()
        titleLabel.text = "🤖 趣AI"
        titleLabel.font = Theme.Font.bold(size: 28)
        titleLabel.textColor = Theme.brightWhite
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        // 菜单按钮
        menuButton.setTitle("☰", for: .normal)
        menuButton.titleLabel?.font = Theme.Font.bold(size: 24)
        menuButton.setTitleColor(Theme.electricBlue, for: .normal)
        menuButton.backgroundColor = Theme.cardBackground.withAlphaComponent(0.6)
        menuButton.layer.cornerRadius = 20
        menuButton.translatesAutoresizingMaskIntoConstraints = false
        menuButton.addTarget(self, action: #selector(toggleSidebar), for: .touchUpInside)
        view.addSubview(menuButton)
        
        // 聊天列表
        chatTable.backgroundColor = .clear
        chatTable.separatorStyle = .none
        chatTable.dataSource = self
        chatTable.delegate = self
        chatTable.register(ChatMessageCell.self, forCellReuseIdentifier: "ChatCell")
        chatTable.keyboardDismissMode = .interactive
        chatTable.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(chatTable)
        
        // 底部栏
        bottomBar.backgroundColor = Theme.cardBackground.withAlphaComponent(0.92)
        bottomBar.layer.cornerRadius = 16
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bottomBar)
        
        setupBottomBar()
        setupSidebar()
        
        NSLayoutConstraint.activate([
            menuButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 4),
            menuButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            menuButton.widthAnchor.constraint(equalToConstant: 40),
            menuButton.heightAnchor.constraint(equalToConstant: 40),
            
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            chatTable.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            chatTable.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            chatTable.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            chatTable.bottomAnchor.constraint(equalTo: bottomBar.topAnchor, constant: -8),
            
            bottomBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            bottomBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
        ])
        bottomBarBottomConstraint = bottomBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8)
        bottomBarBottomConstraint.isActive = true
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
    
    private func setupSidebar() {
        sidebarView = UIView()
        sidebarView.backgroundColor = Theme.cardBackground.withAlphaComponent(0.95)
        sidebarView.translatesAutoresizingMaskIntoConstraints = false
        sidebarView.clipsToBounds = true
        view.addSubview(sidebarView)
        
        sidebarWidthConstraint = sidebarView.widthAnchor.constraint(equalToConstant: 0)
        
        let headerLabel = UILabel()
        headerLabel.text = "💬 对话历史"
        headerLabel.font = Theme.Font.bold(size: 18)
        headerLabel.textColor = Theme.brightWhite
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        sidebarView.addSubview(headerLabel)
        
        let newButton = UIButton(type: .system)
        newButton.setTitle("✏️ 新建对话", for: .normal)
        newButton.titleLabel?.font = Theme.Font.bold(size: 14)
        newButton.setTitleColor(Theme.electricBlue, for: .normal)
        newButton.backgroundColor = Theme.cardBackground.withAlphaComponent(0.5)
        newButton.layer.cornerRadius = 12
        newButton.translatesAutoresizingMaskIntoConstraints = false
        newButton.addTarget(self, action: #selector(didTapNewSession), for: .touchUpInside)
        sidebarView.addSubview(newButton)
        
        sessionTable = UITableView()
        sessionTable.backgroundColor = .clear
        sessionTable.separatorStyle = .none
        sessionTable.dataSource = self
        sessionTable.delegate = self
        sessionTable.register(SessionCell.self, forCellReuseIdentifier: "SessionCell")
        sessionTable.translatesAutoresizingMaskIntoConstraints = false
        sidebarView.addSubview(sessionTable)
        
        dimView = UIView()
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        dimView.translatesAutoresizingMaskIntoConstraints = false
        dimView.isHidden = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(toggleSidebar))
        dimView.addGestureRecognizer(tap)
        view.addSubview(dimView)
        
        NSLayoutConstraint.activate([
            sidebarView.topAnchor.constraint(equalTo: view.topAnchor),
            sidebarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sidebarView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            sidebarWidthConstraint,
            
            dimView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimView.topAnchor.constraint(equalTo: view.topAnchor),
            dimView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dimView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            headerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            headerLabel.leadingAnchor.constraint(equalTo: sidebarView.leadingAnchor, constant: 16),
            headerLabel.trailingAnchor.constraint(equalTo: sidebarView.trailingAnchor, constant: -16),
            
            newButton.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 12),
            newButton.leadingAnchor.constraint(equalTo: sidebarView.leadingAnchor, constant: 16),
            newButton.trailingAnchor.constraint(equalTo: sidebarView.trailingAnchor, constant: -16),
            newButton.heightAnchor.constraint(equalToConstant: 40),
            
            sessionTable.topAnchor.constraint(equalTo: newButton.bottomAnchor, constant: 12),
            sessionTable.leadingAnchor.constraint(equalTo: sidebarView.leadingAnchor),
            sessionTable.trailingAnchor.constraint(equalTo: sidebarView.trailingAnchor),
            sessionTable.bottomAnchor.constraint(equalTo: sidebarView.bottomAnchor),
        ])
    }
    
    // MARK: - Sidebar
    
    @objc private func toggleSidebar() {
        sidebarCollapsed.toggle()
        dimView.isHidden = sidebarCollapsed
        UIView.animate(withDuration: 0.3) {
            self.sidebarWidthConstraint.constant = self.sidebarCollapsed ? 0 : self.sidebarWidth
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func didTapNewSession() {
        newSession()
    }
    
    // MARK: - Mode / Model Pickers
    
    @objc private func showModePicker() {
        let alert = UIAlertController(title: "选择模式", message: nil, preferredStyle: .actionSheet)
        for mode in AIMode.allCases {
            alert.addAction(UIAlertAction(title: mode.rawValue, style: .default, handler: { [weak self] _ in
                self?.currentMode = mode
                self?.modeButton.setTitle("▼ \(mode.rawValue)", for: .normal)
                self?.updateModelVisibility()
                self?.updateModeUI()
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
    
    private func updateModeUI() {
        switch currentMode {
        case .chat:
            textField.attributedPlaceholder = NSAttributedString(string: "输入聊天内容...", attributes: [.foregroundColor: Theme.mutedGray])
        case .pavo:
            textField.attributedPlaceholder = NSAttributedString(string: "输入故事主题，开始 Pavo 创作...", attributes: [.foregroundColor: Theme.mutedGray])
        case .imageToVideo:
            textField.attributedPlaceholder = NSAttributedString(string: "输入视频描述，然后选择图片...", attributes: [.foregroundColor: Theme.mutedGray])
        default:
            textField.attributedPlaceholder = NSAttributedString(string: "输入你的想法...", attributes: [.foregroundColor: Theme.mutedGray])
        }
    }

    private func updateModelVisibility() {
        let dimColor = Theme.mutedGray
        switch currentMode {
        case .chat:
            videoModelButton.setTitleColor(dimColor, for: .normal)
            videoModelButton.alpha = 0.4
            imageModelButton.setTitleColor(dimColor, for: .normal)
            imageModelButton.alpha = 0.4
        case .imageGen:
            videoModelButton.setTitleColor(dimColor, for: .normal)
            videoModelButton.alpha = 0.4
            imageModelButton.setTitleColor(Theme.brightWhite, for: .normal)
            imageModelButton.alpha = 1.0
        case .videoGen, .shortDrama, .imageToVideo:
            videoModelButton.setTitleColor(Theme.brightWhite, for: .normal)
            videoModelButton.alpha = 1.0
            imageModelButton.setTitleColor(Theme.brightWhite, for: .normal)
            imageModelButton.alpha = 1.0
        case .pavo:
            videoModelButton.setTitleColor(dimColor, for: .normal)
            videoModelButton.alpha = 0.4
            imageModelButton.setTitleColor(dimColor, for: .normal)
            imageModelButton.alpha = 0.4
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
        
        // 图生视频模式：先确保选了图
        if currentMode == .imageToVideo && selectedImageForVideo == nil {
            textField.text = text
            showImagePickerForVideo()
            return
        }
        
        let userMsg = ChatMessage(text: text, isUser: true)
        addMessage(userMsg)
        
        let loadingText: String = {
            switch currentMode {
            case .chat: return "🤔 正在思考..."
            case .shortDrama: return "🎬 正在创作剧情短片..."
            case .imageToVideo: return "🎬 正在生成视频..."
            default: return "🤔 正在思考..."
            }
        }()
        let loadingMsg = ChatMessage(text: loadingText, isUser: false, isLoading: true)
        addMessage(loadingMsg)
        isGenerating = true
        scrollToBottom()
        
        switch currentMode {
        case .chat:
            generateChatResponse(prompt: text, loadingId: loadingMsg.id)
        case .imageGen:
            generateImage(prompt: text, loadingId: loadingMsg.id)
        case .videoGen:
            generateVideo(prompt: text, loadingId: loadingMsg.id)
        case .shortDrama:
            generateShortDrama(prompt: text, loadingId: loadingMsg.id)
        case .imageToVideo:
            if let img = selectedImageForVideo {
                generateImageToVideo(image: img, prompt: text, loadingId: loadingMsg.id)
                selectedImageForVideo = nil
                imagePreviewInBar?.isHidden = true
            } else {
                isGenerating = false
                let _ = currentMessages.popLast()
                let _ = currentMessages.popLast()
                chatTable.reloadData()
            }
        case .pavo:
            currentMessages.removeLast()
            currentMessages.removeLast()
            chatTable.reloadData()
            isGenerating = false
            let project = PavoProject.create(title: String(text.prefix(30)))
            var updated = project
            updated.requirements = text
            let pavoVC = PavoViewController(project: updated)
            pavoVC.modalPresentationStyle = .fullScreen
            present(pavoVC, animated: true)
        }
    }
    
    private func addMessage(_ msg: ChatMessage) {
        currentMessages.append(msg)
        chatTable.reloadData()
        scrollToBottom()
        saveCurrentSession()
    }
    
    private func updateMessage(id: String, image: UIImage? = nil, videoURL: URL? = nil, text: String? = nil, isLoading: Bool = false) {
        if let idx = currentMessages.firstIndex(where: { $0.id == id }) {
            var msg = currentMessages[idx]
            if let img = image { msg.image = img }
            if let url = videoURL { msg.videoURL = url }
            if let t = text {
                let newMsg = ChatMessage(id: msg.id, text: t, isUser: msg.isUser, image: msg.image, videoURL: msg.videoURL, isLoading: isLoading, timestamp: msg.timestamp)
                currentMessages[idx] = newMsg
            } else {
                currentMessages[idx] = msg
            }
            chatTable.reloadData()
            scrollToBottom()
            saveCurrentSession()
        }
    }
    
    private func scrollToBottom() {
        guard !currentMessages.isEmpty else { return }
        let idx = IndexPath(row: currentMessages.count - 1, section: 0)
        chatTable.scrollToRow(at: idx, at: .bottom, animated: true)
    }
    
    // MARK: - API Calls

    private func generateChatResponse(prompt: String, loadingId: String) {
        guard let url = URL(string: "\(baseURL)/chat/completions") else { return }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = [
            "model": "agnes-2.0-flash",
            "messages": [["role": "user", "content": prompt]],
            "max_tokens": 2048
        ]
        req.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: req) { [weak self] data, _, _ in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isGenerating = false
                if let data = data,
                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let choices = json["choices"] as? [[String: Any]],
                   let first = choices.first,
                   let message = first["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    self.updateMessage(id: loadingId, text: content, isLoading: false)
                } else {
                    let err = (data.flatMap { try? JSONSerialization.jsonObject(with: $0) as? [String: Any] })?["error"] as? String ?? "请求失败"
                    self.updateMessage(id: loadingId, text: "❌ \(err)", isLoading: false)
                }
            }
        }.resume()
    }

    private func generateImage(prompt: String, loadingId: String) {
        guard let url = URL(string: "\(baseURL)/images/generations") else { return }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
let body: [String: Any] = ["model": currentImageModel, "prompt": prompt, "n": 1, "size": "1024x1024"]
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
                                let _ = ChatSession.saveImage(image, sessionId: self.currentSession.id, messageId: loadingId)
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
        guard let url = URL(string: "\(baseURL)/videos") else { return }
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
        guard let url = URL(string: "\(baseURL)/videos/\(taskId)") else { return }
        var req = URLRequest(url: url)
        req.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        var attempts = 0
        let maxAttempts = 60
        
        func poll() {
            attempts += 1
            if attempts > maxAttempts {
                DispatchQueue.main.async {
                    self.isGenerating = false
                    self.updateMessage(id: loadingId, text: "❌ 视频生成超时", isLoading: false)
                }
                return
            }
            URLSession.shared.dataTask(with: req) { [weak self] data, _, _ in
                guard let self = self else { return }
                if let data = data, let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    let status = json["status"] as? String ?? ""
                    if status == "succeeded" || status == "completed" {
                        if let output = json["url"] as? String, let videoUrl = URL(string: output) {
                            self.downloadAndShowVideo(url: videoUrl, loadingId: loadingId)
                        } else if let outputArr = json["url"] as? [String], let firstUrl = outputArr.first, let videoUrl = URL(string: firstUrl) {
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
                    self.updateMessage(id: loadingId, videoURL: tempURL, text: "✅ 视频生成完成", isLoading: false)
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
        let body: [String: Any] = ["model": currentImageModel, "prompt": prompt, "n": 1, "size": "1024x1024"]
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
                                let _ = ChatSession.saveImage(image, sessionId: self.currentSession.id, messageId: loadingId)
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
        guard let url = URL(string: "\(baseURL)/videos") else { return }
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
        guard let url = URL(string: "\(baseURL)/videos/\(taskId)") else { return }
        var req = URLRequest(url: url)
        req.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        var attempts = 0
        let maxAttempts = 60
        
        func poll() {
            attempts += 1
            if attempts > maxAttempts {
                DispatchQueue.main.async {
                    self.isGenerating = false
                    self.updateMessage(id: loadingId, text: "🎬 画面已生成（视频生成超时）", isLoading: false)
                }
                return
            }
            URLSession.shared.dataTask(with: req) { [weak self] data, _, _ in
                guard let self = self else { return }
                if let data = data, let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    let status = json["status"] as? String ?? ""
                    if status == "succeeded" || status == "completed" {
                        if let output = json["url"] as? String, let videoUrl = URL(string: output) {
                            self.downloadAndShowVideo(url: videoUrl, loadingId: loadingId)
                        } else if let outputArr = json["url"] as? [String], let firstUrl = outputArr.first, let videoUrl = URL(string: firstUrl) {
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
                        DispatchQueue.global().asyncAfter(deadline: .now() + 2.0) { poll() }
                    }
                } else {
                    DispatchQueue.global().asyncAfter(deadline: .now() + 2.0) { poll() }
                }
            }.resume()
        }
        poll()
    }
    
    // MARK: - 图生视频
    
    private func showImagePickerForVideo() {
        let alert = UIAlertController(title: "选择图片", message: "图生视频需要先选择一张图片", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "📱 从相册选择", style: .default, handler: { [weak self] _ in
            self?.pickImageFromLibrary()
        }))
        alert.addAction(UIAlertAction(title: "🔗 粘贴图片URL", style: .default, handler: { [weak self] _ in
            self?.promptImageURL()
        }))
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        if let popover = alert.popoverPresentationController {
            popover.sourceView = sendButton
            popover.sourceRect = sendButton.bounds
        }
        present(alert, animated: true)
    }
    
    private func pickImageFromLibrary() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated: true)
    }
    
    private func promptImageURL() {
        let alert = UIAlertController(title: "粘贴图片URL", message: nil, preferredStyle: .alert)
        alert.addTextField { tf in
            tf.placeholder = "https://example.com/image.jpg"
            tf.keyboardType = .URL
        }
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { [weak self] _ in
            guard let urlStr = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespaces), !urlStr.isEmpty,
                  let url = URL(string: urlStr) else {
                self?.showToast("❌ 无效的URL")
                return
            }
            URLSession.shared.dataTask(with: url) { data, _, _ in
                DispatchQueue.main.async {
                    if let data = data, let image = UIImage(data: data) {
                        self?.setSelectedImage(image)
                    } else {
                        self?.showToast("❌ 下载图片失败")
                    }
                }
            }.resume()
        }))
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        present(alert, animated: true)
    }
    
    private func setSelectedImage(_ image: UIImage) {
        selectedImageForVideo = image
        if imagePreviewInBar == nil {
            imagePreviewInBar = UIImageView(frame: CGRect(x: 0, y: 0, width: 36, height: 36))
            imagePreviewInBar!.layer.cornerRadius = 6
            imagePreviewInBar!.clipsToBounds = true
            imagePreviewInBar!.contentMode = .scaleAspectFill
            imagePreviewInBar!.translatesAutoresizingMaskIntoConstraints = false
            bottomBar.addSubview(imagePreviewInBar!)
            imagePreviewInBar!.centerYAnchor.constraint(equalTo: textField.centerYAnchor).isActive = true
            imagePreviewInBar!.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -8).isActive = true
            imagePreviewInBar!.widthAnchor.constraint(equalToConstant: 36).isActive = true
            imagePreviewInBar!.heightAnchor.constraint(equalToConstant: 36).isActive = true
        }
        imagePreviewInBar!.image = image
        imagePreviewInBar!.isHidden = false
        showToast("✅ 已选择图片，输入描述后发送")
    }
    
    private func uploadImageToBeeimg(_ image: UIImage, completion: @escaping (String?) -> Void) {
        guard let url = URL(string: "https://beeimg.com/api/upload/file/json/") else { completion(nil); return }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        let boundary = UUID().uuidString
        req.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        guard let imageData = image.jpegData(compressionQuality: 0.85) else { completion(nil); return }
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"apikey\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(beeimgToken)\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        req.httpBody = body
        
        URLSession.shared.dataTask(with: req) { data, _, _ in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let files = json["files"] as? [String: Any],
                  let imgUrl = files["url"] as? String else {
                completion(nil)
                return
            }
            completion(imgUrl)
        }.resume()
    }
    
    private func generateImageToVideo(image: UIImage, prompt: String, loadingId: String) {
        showToast("⏳ 正在上传图片...")
        uploadImageToBeeimg(image) { [weak self] imageUrl in
            guard let self = self, let imageUrl = imageUrl else {
                DispatchQueue.main.async {
                    self?.showToast("❌ 图片上传失败")
                    self?.isGenerating = false
                    self?.updateMessage(id: loadingId, text: "❌ 图片上传失败，请重试", isLoading: false)
                }
                return
            }
            DispatchQueue.main.async {
                self.showToast("✅ 图片已上传，正在生成视频...")
            }
            guard let url = URL(string: "\(self.baseURL)/videos") else { return }
            var req = URLRequest(url: url)
            req.httpMethod = "POST"
            req.setValue("Bearer \(self.apiKey)", forHTTPHeaderField: "Authorization")
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let body: [String: Any] = ["model": self.currentVideoModel, "prompt": prompt, "image_url": imageUrl, "n": 1]
            req.httpBody = try? JSONSerialization.data(withJSONObject: body)
            
            URLSession.shared.dataTask(with: req) { data, _, _ in
                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let taskId = json["id"] as? String else {
                    DispatchQueue.main.async {
                        self.isGenerating = false
                        self.updateMessage(id: loadingId, text: "❌ 视频生成请求失败", isLoading: false)
                    }
                    return
                }
                self.pollVideoTask(taskId: taskId, loadingId: loadingId)
            }.resume()
        }
    }
    
    // MARK: - UIImagePicker Delegate
    
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
    
    @objc private func saveImage(_ sender: UIButton) {
        let tag = sender.tag
        guard tag < currentMessages.count, let image = currentMessages[tag].image else { return }
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(imageSaved(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc private func imageSaved(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeMutableRawPointer) {
        showToast(error == nil ? "✅ 图片已保存到相册" : "❌ 保存失败")
    }
    
    @objc private func videoSaved(_ video: String, didFinishSavingWithError error: Error?, contextInfo: UnsafeMutableRawPointer) {
        showToast(error == nil ? "✅ 视频已保存到相册" : "❌ 保存失败")
    }
}

// MARK: - TableView (Chat + Session)

extension QuAIViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == sessionTable { return sessions.count }
        return currentMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == sessionTable {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SessionCell", for: indexPath) as! SessionCell
            let session = sessions[indexPath.row]
            let isActive = session.id == currentSession.id
            cell.configure(title: session.title, subtitle: timeAgo(session.updatedAt), isActive: isActive)
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell", for: indexPath) as! ChatMessageCell
        let msg = currentMessages[indexPath.row]
        cell.configure(with: msg, apiKeyMissing: apiKey.isEmpty, index: indexPath.row)
        cell.onSaveImage = { [weak self] idx in
            guard let self = self, idx < self.currentMessages.count, let image = self.currentMessages[idx].image else { return }
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.imageSaved(_:didFinishSavingWithError:contextInfo:)), nil)
        }
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == sessionTable {
            switchSession(sessions[indexPath.row])
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == sessionTable { return 60 }
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        100
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        tableView == sessionTable && sessions.count > 1
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if tableView == sessionTable && editingStyle == .delete {
            deleteSession(at: indexPath.row)
        }
    }
    
    private func timeAgo(_ date: Date) -> String {
        let secs = Int(-date.timeIntervalSinceNow)
        if secs < 60 { return "刚刚" }
        if secs < 3600 { return "\(secs/60)分钟前" }
        if secs < 86400 { return "\(secs/3600)小时前" }
        return "\(secs/86400)天前"
    }
}

// MARK: - UIImagePicker Delegate

extension QuAIViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        if let image = info[.originalImage] as? UIImage {
            setSelectedImage(image)
        }
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

// MARK: - TextField Delegate

extension QuAIViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendMessage()
        return true
    }
}

// MARK: - Session Cell

class SessionCell: UITableViewCell {
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let indicator = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        
        indicator.backgroundColor = Theme.electricBlue
        indicator.layer.cornerRadius = 3
        indicator.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(indicator)
        
        titleLabel.font = Theme.Font.bold(size: 14)
        titleLabel.textColor = Theme.brightWhite
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        subtitleLabel.font = Theme.Font.regular(size: 11)
        subtitleLabel.textColor = Theme.mutedGray
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            indicator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            indicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            indicator.widthAnchor.constraint(equalToConstant: 6),
            indicator.heightAnchor.constraint(equalToConstant: 6),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: indicator.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            subtitleLabel.leadingAnchor.constraint(equalTo: indicator.trailingAnchor, constant: 8),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
        ])
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func configure(title: String, subtitle: String, isActive: Bool) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        indicator.isHidden = !isActive
        titleLabel.textColor = isActive ? Theme.electricBlue : Theme.brightWhite
    }
}

// MARK: - Chat Message Cell

class ChatMessageCell: UITableViewCell {
    private let bubbleView = UIView()
    private let msgLabel = UILabel()
    private let imagePreview = UIImageView()
    private let saveImageButton = UIButton()
    private let videoButton = UIButton()
    private let activityIndicator = UIActivityIndicatorView(style: .gray)
    
    var onSaveImage: ((Int) -> Void)?
    var onSaveVideo: ((URL) -> Void)?
    private var videoURL: URL?
    private var bubbleLeading: NSLayoutConstraint!
    private var bubbleTrailing: NSLayoutConstraint!
    private var cellIndex = 0
    
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
        
        saveImageButton.setTitle("💾 保存图片", for: .normal)
        saveImageButton.titleLabel?.font = Theme.Font.bold(size: 12)
        saveImageButton.backgroundColor = Theme.electricBlue
        saveImageButton.layer.cornerRadius = 10
        saveImageButton.translatesAutoresizingMaskIntoConstraints = false
        saveImageButton.addTarget(self, action: #selector(didTapSaveImage), for: .touchUpInside)
        bubbleView.addSubview(saveImageButton)
        
        videoButton.setTitle("💾 保存视频", for: .normal)
        videoButton.titleLabel?.font = Theme.Font.bold(size: 12)
        videoButton.backgroundColor = Theme.neonPink
        videoButton.layer.cornerRadius = 10
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
            
            saveImageButton.topAnchor.constraint(equalTo: imagePreview.bottomAnchor, constant: 8),
            saveImageButton.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 8),
            saveImageButton.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -8),
            saveImageButton.heightAnchor.constraint(equalToConstant: 32),
            
            videoButton.topAnchor.constraint(equalTo: saveImageButton.bottomAnchor, constant: 6),
            videoButton.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 8),
            videoButton.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -8),
            videoButton.heightAnchor.constraint(equalToConstant: 32),
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
        saveImageButton.isHidden = true
        imagePreview.isHidden = true
        activityIndicator.stopAnimating()
        videoURL = nil
        bubbleLeading.isActive = false
        bubbleTrailing.isActive = false
    }
    
    func configure(with msg: ChatMessage, apiKeyMissing: Bool, index: Int) {
        cellIndex = index
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
            saveImageButton.isHidden = true
            videoButton.isHidden = true
        } else {
            activityIndicator.stopAnimating()
        }
        
        if let image = msg.image {
            imagePreview.image = image
            imagePreview.isHidden = false
            saveImageButton.isHidden = false
            saveImageButton.tag = index
        } else {
            imagePreview.isHidden = true
            saveImageButton.isHidden = true
        }
        
        if let url = msg.videoURL {
            videoURL = url
            videoButton.isHidden = false
        } else {
            videoButton.isHidden = true
        }
    }
    
    @objc private func didTapSaveImage() {
        onSaveImage?(cellIndex)
    }
    
    @objc private func didTapSaveVideo() {
        if let url = videoURL {
            onSaveVideo?(url)
        }
    }
}

// ChatMessage with URL videoURL
struct ChatMessage {
    let id: String
    let text: String
    let isUser: Bool
    var image: UIImage?
    var videoURL: URL?
    let isLoading: Bool
    let timestamp: Date
    
    init(id: String = UUID().uuidString, text: String, isUser: Bool, image: UIImage? = nil, videoURL: URL? = nil, isLoading: Bool = false, timestamp: Date = Date()) {
        self.id = id
        self.text = text
        self.isUser = isUser
        self.image = image
        self.videoURL = videoURL
        self.isLoading = isLoading
        self.timestamp = timestamp
    }
}
