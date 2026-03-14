import UIKit

class QuAIViewController: UIViewController {
    
    private let nvAPIKey = "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"
    
    private var messages: [(role: String, content: String, isSearching: Bool)] = []
    private var tableView: UITableView!
    private var inputContainer: UIView!
    private var inputTextField: UITextField!
    private var sendButton: UIButton!
    private var loadingIndicator: UIActivityIndicatorView!
    private var isLoading = false
    private var isSearchEnabled = false
    private var searchToggleButton: UIButton!
    
    private let userAvatar = "👤"
    private let aiAvatar = "🤖"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        addWelcomeMessage()
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
        
        let clearButton = UIButton(type: .system)
        clearButton.setTitle("清空", for: .normal)
        clearButton.titleLabel?.font = Theme.Font.regular(size: 16)
        clearButton.setTitleColor(Theme.mutedGray, for: .normal)
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        clearButton.addTarget(self, action: #selector(clearChat), for: .touchUpInside)
        view.addSubview(clearButton)
        
        tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ChatMessageCell.self, forCellReuseIdentifier: "ChatMessageCell")
        tableView.keyboardDismissMode = .interactive
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        loadingIndicator = UIActivityIndicatorView(style: .whiteLarge)
        loadingIndicator.color = Theme.electricBlue
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingIndicator)
        
        inputContainer = UIView()
        inputContainer.backgroundColor = Theme.cardBackground.withAlphaComponent(0.9)
        inputContainer.layer.cornerRadius = 25
        inputContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(inputContainer)
        
        let inputIcon = UILabel()
        inputIcon.text = "💬"
        inputIcon.font = UIFont.systemFont(ofSize: 20)
        inputIcon.translatesAutoresizingMaskIntoConstraints = false
        inputContainer.addSubview(inputIcon)
        
        inputTextField = UITextField()
        inputTextField.placeholder = "问我任何问题..."
        inputTextField.font = Theme.Font.regular(size: 16)
        inputTextField.textColor = Theme.brightWhite
        inputTextField.attributedPlaceholder = NSAttributedString(
            string: "问我任何问题...",
            attributes: [.foregroundColor: Theme.mutedGray]
        )
        inputTextField.returnKeyType = .send
        inputTextField.delegate = self
        inputTextField.translatesAutoresizingMaskIntoConstraints = false
        inputContainer.addSubview(inputTextField)
        
        sendButton = UIButton(type: .system)
        sendButton.setTitle("➤", for: .normal)
        sendButton.titleLabel?.font = UIFont.systemFont(ofSize: 22)
        sendButton.setTitleColor(Theme.electricBlue, for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        inputContainer.addSubview(sendButton)
        
        searchToggleButton = UIButton(type: .system)
        searchToggleButton.setTitle("🌐 联网搜索: 关闭", for: .normal)
        searchToggleButton.titleLabel?.font = Theme.Font.regular(size: 12)
        searchToggleButton.setTitleColor(Theme.mutedGray, for: .normal)
        searchToggleButton.translatesAutoresizingMaskIntoConstraints = false
        searchToggleButton.addTarget(self, action: #selector(toggleSearch), for: .touchUpInside)
        view.addSubview(searchToggleButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            clearButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            clearButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: searchToggleButton.topAnchor, constant: -8),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: tableView.centerYAnchor),
            
            searchToggleButton.bottomAnchor.constraint(equalTo: inputContainer.topAnchor, constant: -8),
            searchToggleButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            inputContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            inputContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            inputContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            inputContainer.heightAnchor.constraint(equalToConstant: 50),
            
            inputIcon.leadingAnchor.constraint(equalTo: inputContainer.leadingAnchor, constant: 16),
            inputIcon.centerYAnchor.constraint(equalTo: inputContainer.centerYAnchor),
            
            inputTextField.leadingAnchor.constraint(equalTo: inputIcon.trailingAnchor, constant: 8),
            inputTextField.centerYAnchor.constraint(equalTo: inputContainer.centerYAnchor),
            inputTextField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -8),
            
            sendButton.trailingAnchor.constraint(equalTo: inputContainer.trailingAnchor, constant: -16),
            sendButton.centerYAnchor.constraint(equalTo: inputContainer.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 40)
        ])
        
        title = "趣AI"
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func addWelcomeMessage() {
        let welcomeMsg = """
        👋 你好！我是趣AI助手

        我可以帮你：
        • 💬 回答各种问题
        • 🌐 联网搜索信息
        • 📝 写作辅助
        • 🧮 数学计算
        • 💡 提供建议

        有什么我可以帮你的吗？
        """
        messages.append((role: "assistant", content: welcomeMsg, isSearching: false))
    }
    
    @objc private func toggleSearch() {
        isSearchEnabled.toggle()
        if isSearchEnabled {
            searchToggleButton.setTitle("🌐 联网搜索: 开启", for: .normal)
            searchToggleButton.setTitleColor(Theme.electricBlue, for: .normal)
        } else {
            searchToggleButton.setTitle("🌐 联网搜索: 关闭", for: .normal)
            searchToggleButton.setTitleColor(Theme.mutedGray, for: .normal)
        }
    }
    
    private func needsWebSearch(_ question: String) -> Bool {
        return isSearchEnabled
    }
    
    @objc private func sendMessage() {
        guard let text = inputTextField.text, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let userMessage = text.trimmingCharacters(in: .whitespacesAndNewlines)
        inputTextField.text = ""
        
        messages.append((role: "user", content: userMessage, isSearching: false))
        tableView.reloadData()
        scrollToBottom()
        
        getAIResponse(for: userMessage)
    }
    
    private func getAIResponse(for question: String) {
        isLoading = true
        loadingIndicator.startAnimating()
        
        messages.append((role: "assistant", content: "思考中...", isSearching: true))
        let thinkingIndex = messages.count - 1
        tableView.reloadData()
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            var searchResults = ""
            if self.needsWebSearch(question) {
                searchResults = self.performWebSearch(query: question)
            }
            
            let context = self.buildContext()
            let searchContext = searchResults.isEmpty ? "" : "\n\n搜索结果:\n\(searchResults)\n\n"
            let prompt = """
            你是一个友好的AI助手，名叫"趣AI"。请用中文回答用户的问题。\(searchContext)\(context)
            
            用户问题: \(question)
            
            请给出回答:
            """
            
            let response = self.callNVIDIAAPI(prompt: prompt, question: question)
            
            DispatchQueue.main.async {
                self.isLoading = false
                self.loadingIndicator.stopAnimating()
                
                self.messages[thinkingIndex] = (role: "assistant", content: response, isSearching: false)
                self.tableView.reloadData()
                self.scrollToBottom()
            }
        }
    }
    
    private func performWebSearch(query: String) -> String {
        let mcpServerURL = "http://localhost:3000/mcp"
        
        let mcpRequest: [String: Any] = [
            "jsonrpc": "2.0",
            "id": 1,
            "method": "tools/call",
            "params": [
                "name": "web_search",
                "arguments": ["query": query]
            ]
        ]
        
        guard let url = URL(string: mcpServerURL),
              let requestBody = try? JSONSerialization.data(withJSONObject: mcpRequest) else {
            return mcpFallbackSearch(query: query)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = requestBody
        request.timeoutInterval = 15
        
        let semaphore = DispatchSemaphore(value: 0)
        var responseData: Data?
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                responseData = data
            }
            semaphore.signal()
        }
        task.resume()
        semaphore.wait()
        
        if let data = responseData,
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let result = json["result"] as? [String: Any],
           let content = result["content"] as? String {
            return content
        }
        
        return mcpFallbackSearch(query: query)
    }
    
    private func mcpFallbackSearch(query: String) -> String {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        
        let urlString = "https://ddg-api.vercel.app/search?q=\(encodedQuery)&limit=5"
        
        guard let url = URL(string: urlString) else {
            return ""
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        
        let semaphore = DispatchSemaphore(value: 0)
        var responseData: Data?
        
        let task = URLSession.shared.dataTask(with: request) { data, _, _ in
            responseData = data
            semaphore.signal()
        }
        task.resume()
        semaphore.wait()
        
        if let data = responseData,
           let json = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
            var searchText = ""
            for (index, result) in json.enumerated() {
                let title = result["title"] as? String ?? ""
                let snippet = result["snippet"] as? String ?? ""
                searchText += "\(index + 1). \(title)\n\(snippet)\n\n"
            }
            return searchText
        }
        
        return ""
    }
    
    private func buildContext() -> String {
        var context = "对话历史:\n"
        for msg in messages.suffix(10) {
            let role = msg.role == "user" ? "用户" : "助手"
            context += "\(role): \(msg.content)\n"
        }
        return context
    }
    
    private func callNVIDIAAPI(prompt: String, question: String) -> String {
        let url = URL(string: "https://api.nvcf.nvidia.com/v2/chat/completions")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(nvAPIKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "model": "nvidia/llama-3.1-nemotron-70b-instruct",
            "messages": [
                ["role": "system", "content": "你是一个友好的AI助手，名叫'趣AI'。请用中文回答用户的问题。"],
                ["role": "user", "content": question]
            ],
            "temperature": 0.7,
            "max_tokens": 1024
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)
        
        let semaphore = DispatchSemaphore(value: 0)
        var responseData: Data?
        var responseError: Error?
        
        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            responseData = data
            responseError = error
            semaphore.signal()
        }
        task.resume()
        semaphore.wait()
        
        if let error = responseError {
            return "抱歉，我遇到了网络错误: \(error.localizedDescription)"
        }
        
        if let data = responseData {
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let choices = json["choices"] as? [[String: Any]],
               let firstChoice = choices.first,
               let message = firstChoice["message"] as? [String: Any],
               let content = message["content"] as? String {
                return content
            } else if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                if let error = json["error"] as? [String: Any],
                   let message = error["message"] as? String {
                    return "API错误: \(message)"
                }
            }
        }
        
        return generateFallbackResponse(for: question)
    }
    
    private func generateFallbackResponse(for question: String) -> String {
        let lowercased = question.lowercased()
        
        if lowercased.contains("天气") {
            return "抱歉，我目前没有实时天气数据。你可以告诉我你在哪个城市，我可以帮你查找天气网站。"
        } else if lowercased.contains("搜索") || lowercased.contains("查") {
            return "我可以帮你回答问题，但实时搜索功能需要联网。请换个方式提问，我会尽力回答你！"
        } else if lowercased.contains("你好") || lowercased.contains("hi") || lowercased.contains("hello") {
            return "你好！有什么我可以帮助你的吗？"
        } else if lowercased.contains("是谁") || lowercased.contains("什么") {
            return "我是趣AI，一个智能助手。我可以回答问题、帮你写作、提供建议等。有什么想问的吗？"
        } else {
            return "感谢你的提问！关于「\(question)」，让我想想...\n\n由于网络限制，我无法获取最新信息，但我可以根据我的知识库尽力回答你。如果需要最新信息，建议你使用搜索引擎查找哦！"
        }
    }
    
    private func scrollToBottom() {
        guard messages.count > 0 else { return }
        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    
    @objc private func clearChat() {
        let alert = UIAlertController(title: "清空对话", message: "确定要清空所有聊天记录吗？", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "清空", style: .destructive) { [weak self] _ in
            self?.messages.removeAll()
            self?.addWelcomeMessage()
            self?.tableView.reloadData()
        })
        present(alert, animated: true)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        let keyboardHeight = keyboardFrame.height
        inputContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -keyboardHeight + view.safeAreaInsets.bottom - 16).isActive = true
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        
        scrollToBottom()
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        inputContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16).isActive = true
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
}

extension QuAIViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatMessageCell", for: indexPath) as! ChatMessageCell
        let message = messages[indexPath.row]
        cell.configure(
            avatar: message.role == "user" ? userAvatar : aiAvatar,
            message: message.content,
            isUser: message.role == "user",
            isSearching: message.isSearching
        )
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

extension QuAIViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendMessage()
        return true
    }
}

class ChatMessageCell: UITableViewCell {
    private let avatarLabel = UILabel()
    private let messageLabel = UILabel()
    private let bubbleView = UIView()
    private let searchingIndicator = UIActivityIndicatorView(style: .gray)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        avatarLabel.font = UIFont.systemFont(ofSize: 24)
        avatarLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(avatarLabel)
        
        bubbleView.layer.cornerRadius = 16
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bubbleView)
        
        messageLabel.font = Theme.Font.regular(size: 15)
        messageLabel.numberOfLines = 0
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.addSubview(messageLabel)
        
        searchingIndicator.color = Theme.electricBlue
        searchingIndicator.hidesWhenStopped = true
        searchingIndicator.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.addSubview(searchingIndicator)
        
        NSLayoutConstraint.activate([
            avatarLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            avatarLabel.widthAnchor.constraint(equalToConstant: 36),
            avatarLabel.heightAnchor.constraint(equalToConstant: 36),
            
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            bubbleView.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, multiplier: 0.75),
            
            messageLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 12),
            messageLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 14),
            messageLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -14),
            messageLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -12),
            
            searchingIndicator.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor),
            searchingIndicator.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor)
        ])
    }
    
    func configure(avatar: String, message: String, isUser: Bool, isSearching: Bool) {
        avatarLabel.text = avatar
        
        if isUser {
            avatarLabel.textAlignment = .right
            bubbleView.backgroundColor = Theme.electricBlue.withAlphaComponent(0.3)
            messageLabel.textColor = Theme.brightWhite
            
            NSLayoutConstraint.deactivate(avatarLabel.constraints.filter { $0.firstAttribute == .leading })
            avatarLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12).isActive = true
            
            bubbleView.trailingAnchor.constraint(equalTo: avatarLabel.leadingAnchor, constant: -8).isActive = true
        } else {
            avatarLabel.textAlignment = .left
            bubbleView.backgroundColor = Theme.cardBackground.withAlphaComponent(0.8)
            messageLabel.textColor = Theme.brightWhite
            
            NSLayoutConstraint.deactivate(avatarLabel.constraints.filter { $0.firstAttribute == .trailing })
            avatarLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12).isActive = true
            
            bubbleView.leadingAnchor.constraint(equalTo: avatarLabel.trailingAnchor, constant: 8).isActive = true
        }
        
        if isSearching {
            messageLabel.isHidden = true
            searchingIndicator.startAnimating()
        } else {
            messageLabel.isHidden = false
            messageLabel.text = message
            searchingIndicator.stopAnimating()
        }
    }
}
