import UIKit
import AVFoundation

enum ThemeType: String, CaseIterable {
    case fruit = "水果"
    case animal = "动物"
    
    var icon: String {
        switch self {
        case .fruit: return "🍎"
        case .animal: return "🐱"
        }
    }
    
    var items: [String] {
        switch self {
        case .fruit: return ["🍎", "🍊", "🍋", "🍇", "🍓", "🍑", "🍒", "🥝", "🍌", "🍉"]
        case .animal: return ["🐱", "🐶", "🐰", "🐻", "🦊", "🐼", "🐨", "🦁", "🐸", "🐵"]
        }
    }
}

enum CalculationType: String, CaseIterable {
    case addition = "加法"
    case subtraction = "减法"
    
    var description: String {
        switch self {
        case .addition: return "合起来"
        case .subtraction: return "拿走"
        }
    }
    
    var verb: String {
        switch self {
        case .addition: return "加"
        case .subtraction: return "减"
        }
    }
}

enum DifficultyLevel: Int, CaseIterable {
    case primary = 1
    case intermediate = 2
    
    var range: ClosedRange<Int> {
        switch self {
        case .primary: return 1...5
        case .intermediate: return 1...10
        }
    }
    
    var title: String {
        switch self {
        case .primary: return "初级 (1-5)"
        case .intermediate: return "中级 (1-10)"
        }
    }
}

struct MathQuestion {
    let leftNum: Int
    let rightNum: Int
    let answer: Int
    let type: CalculationType
    let themeItem: String
    
    var questionText: String {
        switch type {
        case .addition:
            return "\(leftNum) 个 \(themeItem) 合起来是多少呀？"
        case .subtraction:
            return "\(leftNum) 个 \(themeItem)，拿走 \(rightNum) 个，还剩多少呀？"
        }
    }
}

class MathTableViewController: UIViewController {
    
    private var selectedTheme: ThemeType = .fruit
    private var selectedCalculation: CalculationType = .addition
    private var selectedDifficulty: DifficultyLevel = .primary
    
    private var currentQuestion: MathQuestion?
    private var correctCount = 0
    private var totalQuestions = 10
    private var answerButtons: [UIButton] = []
    private var isAnswering = false
    
    private var contentView: UIView!
    private var selectionView: UIView!
    private var questionView: UIView!
    private var resultView: UIView!
    
    private let synthesizer = AVSpeechSynthesizer()
    
    private let userDefaultsKey = "math_game_settings"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadSettings()
        setupUI()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return false
    }
    
    private func loadSettings() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let settings = try? JSONDecoder().decode(MathGameSettings.self, from: data) {
            selectedTheme = ThemeType(rawValue: settings.theme) ?? .fruit
            selectedCalculation = CalculationType(rawValue: settings.calculation) ?? .addition
            selectedDifficulty = DifficultyLevel(rawValue: settings.difficulty) ?? .primary
        }
    }
    
    private func saveSettings() {
        let settings = MathGameSettings(
            theme: selectedTheme.rawValue,
            calculation: selectedCalculation.rawValue,
            difficulty: selectedDifficulty.rawValue
        )
        if let data = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        }
    }
    
    private func setupUI() {
        let gradientBg = GradientBackgroundView(frame: view.bounds)
        gradientBg.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(gradientBg)
        
        contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        setupSelectionView()
        showSelectionView()
    }
    
    private func setupSelectionView() {
        selectionView = UIView()
        selectionView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(selectionView)
        
        NSLayoutConstraint.activate([
            selectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            selectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            selectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            selectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        let titleLabel = UILabel()
        titleLabel.text = "🎮 加减口诀"
        titleLabel.font = Theme.Font.bold(size: 32)
        titleLabel.textColor = Theme.brightWhite
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        selectionView.addSubview(titleLabel)
        
        let themeLabel = UILabel()
        themeLabel.text = "👆 先选喜欢的图案吧"
        themeLabel.font = Theme.Font.regular(size: 18)
        themeLabel.textColor = Theme.mutedGray
        themeLabel.textAlignment = .center
        themeLabel.translatesAutoresizingMaskIntoConstraints = false
        selectionView.addSubview(themeLabel)
        
        let themeStack = UIStackView()
        themeStack.axis = .horizontal
        themeStack.spacing = 20
        themeStack.distribution = .fillEqually
        themeStack.translatesAutoresizingMaskIntoConstraints = false
        selectionView.addSubview(themeStack)
        
        for theme in ThemeType.allCases {
            let themeButton = createThemeButton(theme: theme)
            themeStack.addArrangedSubview(themeButton)
        }
        
        let calcLabel = UILabel()
        calcLabel.text = "想玩加法还是减法呀？"
        calcLabel.font = Theme.Font.regular(size: 18)
        calcLabel.textColor = Theme.mutedGray
        calcLabel.textAlignment = .center
        calcLabel.translatesAutoresizingMaskIntoConstraints = false
        selectionView.addSubview(calcLabel)
        
        let calcStack = UIStackView()
        calcStack.axis = .horizontal
        calcStack.spacing = 16
        calcStack.distribution = .fillEqually
        calcStack.translatesAutoresizingMaskIntoConstraints = false
        selectionView.addSubview(calcStack)
        
        for calc in CalculationType.allCases {
            let calcButton = createCalcButton(type: calc)
            calcStack.addArrangedSubview(calcButton)
        }
        
        let difficultyLabel = UILabel()
        difficultyLabel.text = "选一个难度吧"
        difficultyLabel.font = Theme.Font.regular(size: 18)
        difficultyLabel.textColor = Theme.mutedGray
        difficultyLabel.textAlignment = .center
        difficultyLabel.translatesAutoresizingMaskIntoConstraints = false
        selectionView.addSubview(difficultyLabel)
        
        let difficultyStack = UIStackView()
        difficultyStack.axis = .horizontal
        difficultyStack.spacing = 16
        difficultyStack.distribution = .fillEqually
        difficultyStack.translatesAutoresizingMaskIntoConstraints = false
        selectionView.addSubview(difficultyStack)
        
        for difficulty in DifficultyLevel.allCases {
            let diffButton = createDifficultyButton(level: difficulty)
            difficultyStack.addArrangedSubview(diffButton)
        }
        
        let startButton = UIButton(type: .system)
        startButton.setTitle("🚀 出发啦！", for: .normal)
        startButton.titleLabel?.font = Theme.Font.bold(size: 24)
        startButton.setTitleColor(Theme.brightWhite, for: .normal)
        startButton.backgroundColor = Theme.neonPink
        startButton.layer.cornerRadius = 25
        startButton.translatesAutoresizingMaskIntoConstraints = false
        startButton.addTarget(self, action: #selector(startGame), for: .touchUpInside)
        selectionView.addSubview(startButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: selectionView.topAnchor, constant: 30),
            titleLabel.centerXAnchor.constraint(equalTo: selectionView.centerXAnchor),
            
            themeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            themeLabel.centerXAnchor.constraint(equalTo: selectionView.centerXAnchor),
            
            themeStack.topAnchor.constraint(equalTo: themeLabel.bottomAnchor, constant: 16),
            themeStack.leadingAnchor.constraint(equalTo: selectionView.leadingAnchor, constant: 40),
            themeStack.trailingAnchor.constraint(equalTo: selectionView.trailingAnchor, constant: -40),
            themeStack.heightAnchor.constraint(equalToConstant: 100),
            
            calcLabel.topAnchor.constraint(equalTo: themeStack.bottomAnchor, constant: 30),
            calcLabel.centerXAnchor.constraint(equalTo: selectionView.centerXAnchor),
            
            calcStack.topAnchor.constraint(equalTo: calcLabel.bottomAnchor, constant: 16),
            calcStack.leadingAnchor.constraint(equalTo: selectionView.leadingAnchor, constant: 40),
            calcStack.trailingAnchor.constraint(equalTo: selectionView.trailingAnchor, constant: -40),
            calcStack.heightAnchor.constraint(equalToConstant: 60),
            
            difficultyLabel.topAnchor.constraint(equalTo: calcStack.bottomAnchor, constant: 30),
            difficultyLabel.centerXAnchor.constraint(equalTo: selectionView.centerXAnchor),
            
            difficultyStack.topAnchor.constraint(equalTo: difficultyLabel.bottomAnchor, constant: 16),
            difficultyStack.leadingAnchor.constraint(equalTo: selectionView.leadingAnchor, constant: 40),
            difficultyStack.trailingAnchor.constraint(equalTo: selectionView.trailingAnchor, constant: -40),
            difficultyStack.heightAnchor.constraint(equalToConstant: 60),
            
            startButton.topAnchor.constraint(equalTo: difficultyStack.bottomAnchor, constant: 40),
            startButton.centerXAnchor.constraint(equalTo: selectionView.centerXAnchor),
            startButton.widthAnchor.constraint(equalToConstant: 200),
            startButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func createThemeButton(theme: ThemeType) -> UIView {
        let container = UIView()
        container.backgroundColor = selectedTheme == theme ? Theme.electricBlue.withAlphaComponent(0.5) : Theme.cardBackground.withAlphaComponent(0.6)
        container.layer.cornerRadius = 20
        container.layer.borderWidth = selectedTheme == theme ? 3 : 0
        container.layer.borderColor = Theme.electricBlue.cgColor
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let iconLabel = UILabel()
        iconLabel.text = theme.icon
        iconLabel.font = UIFont.systemFont(ofSize: 40)
        iconLabel.textAlignment = .center
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(iconLabel)
        
        let nameLabel = UILabel()
        nameLabel.text = theme.rawValue
        nameLabel.font = Theme.Font.bold(size: 18)
        nameLabel.textColor = Theme.brightWhite
        nameLabel.textAlignment = .center
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(nameLabel)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(themeSelected(_:)))
        container.addGestureRecognizer(tapGesture)
        container.isUserInteractionEnabled = true
        container.tag = theme == .fruit ? 0 : 1
        
        NSLayoutConstraint.activate([
            iconLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            iconLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            
            nameLabel.topAnchor.constraint(equalTo: iconLabel.bottomAnchor, constant: 8),
            nameLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            nameLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12)
        ])
        
        return container
    }
    
    private func createCalcButton(type: CalculationType) -> UIView {
        let container = UIView()
        let isAddition = type == .addition
        container.backgroundColor = selectedCalculation == type ? (isAddition ? UIColor(hex: "FF6B6B").withAlphaComponent(0.5) : UIColor(hex: "4ECDC4").withAlphaComponent(0.5)) : Theme.cardBackground.withAlphaComponent(0.6)
        container.layer.cornerRadius = 15
        container.layer.borderWidth = selectedCalculation == type ? 3 : 0
        container.layer.borderColor = (isAddition ? UIColor(hex: "FF6B6B") : UIColor(hex: "4ECDC4")).cgColor
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let textLabel = UILabel()
        textLabel.text = "\(type.rawValue)\n(\(type.description))"
        textLabel.font = Theme.Font.bold(size: 16)
        textLabel.textColor = Theme.brightWhite
        textLabel.textAlignment = .center
        textLabel.numberOfLines = 2
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(textLabel)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(calcSelected(_:)))
        container.addGestureRecognizer(tapGesture)
        container.isUserInteractionEnabled = true
        container.tag = isAddition ? 0 : 1
        
        NSLayoutConstraint.activate([
            textLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            textLabel.centerYAnchor.constraint(equalTo: container.centerXAnchor),
            textLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 8),
            textLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -8)
        ])
        
        return container
    }
    
    private func createDifficultyButton(level: DifficultyLevel) -> UIView {
        let container = UIView()
        container.backgroundColor = selectedDifficulty == level ? Theme.neonPink.withAlphaComponent(0.5) : Theme.cardBackground.withAlphaComponent(0.6)
        container.layer.cornerRadius = 15
        container.layer.borderWidth = selectedDifficulty == level ? 3 : 0
        container.layer.borderColor = Theme.neonPink.cgColor
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let textLabel = UILabel()
        textLabel.text = level.title
        textLabel.font = Theme.Font.bold(size: 16)
        textLabel.textColor = Theme.brightWhite
        textLabel.textAlignment = .center
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(textLabel)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(difficultySelected(_:)))
        container.addGestureRecognizer(tapGesture)
        container.isUserInteractionEnabled = true
        container.tag = level.rawValue
        
        NSLayoutConstraint.activate([
            textLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            textLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        
        return container
    }
    
    @objc private func themeSelected(_ gesture: UITapGestureRecognizer) {
        guard let view = gesture.view else { return }
        selectedTheme = view.tag == 0 ? .fruit : .animal
        saveSettings()
        speakText("我选\(selectedTheme.rawValue)")
        UIView.animate(withDuration: 0.2) {
            view.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        } completion: { _ in
            UIView.animate(withDuration: 0.2) {
                view.transform = .identity
            }
        }
        refreshSelectionView()
    }
    
    @objc private func calcSelected(_ gesture: UITapGestureRecognizer) {
        guard let view = gesture.view else { return }
        selectedCalculation = view.tag == 0 ? .addition : .subtraction
        saveSettings()
        speakText(selectedCalculation.description)
        UIView.animate(withDuration: 0.2) {
            view.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        } completion: { _ in
            UIView.animate(withDuration: 0.2) {
                view.transform = .identity
            }
        }
        refreshSelectionView()
    }
    
    @objc private func difficultySelected(_ gesture: UITapGestureRecognizer) {
        guard let view = gesture.view else { return }
        selectedDifficulty = DifficultyLevel(rawValue: view.tag) ?? .primary
        saveSettings()
        speakText(selectedDifficulty.title)
        UIView.animate(withDuration: 0.2) {
            view.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        } completion: { _ in
            UIView.animate(withDuration: 0.2) {
                view.transform = .identity
            }
        }
        refreshSelectionView()
    }
    
    private func refreshSelectionView() {
        selectionView.removeFromSuperview()
        setupSelectionView()
    }
    
    @objc private func startGame() {
        correctCount = 0
        speakText("出发啦！")
        showQuestionView()
    }
    
    private func showSelectionView() {
        selectionView.isHidden = false
        questionView?.isHidden = true
        resultView?.isHidden = true
    }
    
    private func showQuestionView() {
        selectionView.isHidden = true
        resultView?.isHidden = true
        
        if questionView == nil {
            setupQuestionView()
        }
        questionView.isHidden = false
        generateNewQuestion()
    }
    
    private func setupQuestionView() {
        questionView = UIView()
        questionView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(questionView)
        
        NSLayoutConstraint.activate([
            questionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            questionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            questionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            questionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        let progressLabel = UILabel()
        progressLabel.font = Theme.Font.bold(size: 18)
        progressLabel.textColor = Theme.electricBlue
        progressLabel.textAlignment = .center
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        progressLabel.tag = 100
        questionView.addSubview(progressLabel)
        
        let backButton = UIButton(type: .system)
        backButton.setTitle("‹ 返回", for: .normal)
        backButton.titleLabel?.font = Theme.Font.bold(size: 18)
        backButton.setTitleColor(Theme.electricBlue, for: .normal)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.addTarget(self, action: #selector(backToSelection), for: .touchUpInside)
        questionView.addSubview(backButton)
        
        let questionCard = UIView()
        questionCard.backgroundColor = Theme.cardBackground.withAlphaComponent(0.8)
        questionCard.layer.cornerRadius = Theme.cardCornerRadius
        questionCard.translatesAutoresizingMaskIntoConstraints = false
        questionView.addSubview(questionCard)
        
        let questionTextLabel = UILabel()
        questionTextLabel.font = Theme.Font.bold(size: 22)
        questionTextLabel.textColor = Theme.brightWhite
        questionTextLabel.textAlignment = .center
        questionTextLabel.numberOfLines = 0
        questionTextLabel.tag = 101
        questionCard.addSubview(questionTextLabel)
        
        let iconContainer = UIStackView()
        iconContainer.axis = .horizontal
        iconContainer.spacing = 8
        iconContainer.alignment = .center
        iconContainer.distribution = .equalSpacing
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.tag = 102
        questionCard.addSubview(iconContainer)
        
        let operatorLabel = UILabel()
        operatorLabel.font = UIFont.systemFont(ofSize: 36, weight: .bold)
        operatorLabel.textColor = selectedCalculation == .addition ? UIColor(hex: "FF6B6B") : UIColor(hex: "4ECDC4")
        operatorLabel.textAlignment = .center
        operatorLabel.translatesAutoresizingMaskIntoConstraints = false
        operatorLabel.tag = 103
        questionCard.addSubview(operatorLabel)
        
        let resultLabel = UILabel()
        resultLabel.font = UIFont.systemFont(ofSize: 36, weight: .bold)
        resultLabel.textColor = Theme.neonPink
        resultLabel.textAlignment = .center
        resultLabel.text = "= ?"
        resultLabel.translatesAutoresizingMaskIntoConstraints = false
        resultLabel.tag = 104
        questionCard.addSubview(resultLabel)
        
        let speakButton = UIButton(type: .system)
        speakButton.setTitle("🔊 再听一遍", for: .normal)
        speakButton.titleLabel?.font = Theme.Font.regular(size: 16)
        speakButton.setTitleColor(Theme.electricBlue, for: .normal)
        speakButton.translatesAutoresizingMaskIntoConstraints = false
        speakButton.addTarget(self, action: #selector(speakQuestion), for: .touchUpInside)
        questionView.addSubview(speakButton)
        
        let answerStack = UIStackView()
        answerStack.axis = .horizontal
        answerStack.spacing = 12
        answerStack.distribution = .fillEqually
        answerStack.translatesAutoresizingMaskIntoConstraints = false
        answerStack.tag = 105
        questionView.addSubview(answerStack)
        
        let range = selectedDifficulty.range
        let maxAnswer = range.upperBound + range.upperBound
        let displayCount = min(6, maxAnswer + 1)
        
        for i in 0..<displayCount {
            let button = UIButton(type: .system)
            button.setTitle("\(i)", for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 32, weight: .bold)
            button.setTitleColor(Theme.brightWhite, for: .normal)
            button.backgroundColor = Theme.cardBackground.withAlphaComponent(0.8)
            button.layer.cornerRadius = 25
            button.tag = i
            button.addTarget(self, action: #selector(answerTapped(_:)), for: .touchUpInside)
            answerStack.addArrangedSubview(button)
            answerButtons.append(button)
        }
        
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: questionView.topAnchor, constant: 16),
            backButton.leadingAnchor.constraint(equalTo: questionView.leadingAnchor, constant: 16),
            
            progressLabel.topAnchor.constraint(equalTo: questionView.topAnchor, constant: 20),
            progressLabel.centerXAnchor.constraint(equalTo: questionView.centerXAnchor),
            
            speakButton.topAnchor.constraint(equalTo: questionView.topAnchor, constant: 16),
            speakButton.trailingAnchor.constraint(equalTo: questionView.trailingAnchor, constant: -16),
            
            questionCard.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 30),
            questionCard.leadingAnchor.constraint(equalTo: questionView.leadingAnchor, constant: 20),
            questionCard.trailingAnchor.constraint(equalTo: questionView.trailingAnchor, constant: -20),
            
            questionTextLabel.topAnchor.constraint(equalTo: questionCard.topAnchor, constant: 20),
            questionTextLabel.leadingAnchor.constraint(equalTo: questionCard.leadingAnchor, constant: 16),
            questionTextLabel.trailingAnchor.constraint(equalTo: questionCard.trailingAnchor, constant: -16),
            
            iconContainer.topAnchor.constraint(equalTo: questionTextLabel.bottomAnchor, constant: 20),
            iconContainer.centerXAnchor.constraint(equalTo: questionCard.centerXAnchor),
            
            operatorLabel.topAnchor.constraint(equalTo: iconContainer.bottomAnchor, constant: 16),
            operatorLabel.centerXAnchor.constraint(equalTo: questionCard.centerXAnchor),
            
            resultLabel.topAnchor.constraint(equalTo: operatorLabel.bottomAnchor, constant: 16),
            resultLabel.centerXAnchor.constraint(equalTo: questionCard.centerXAnchor),
            resultLabel.bottomAnchor.constraint(equalTo: questionCard.bottomAnchor, constant: -20),
            
            answerStack.topAnchor.constraint(equalTo: questionCard.bottomAnchor, constant: 40),
            answerStack.leadingAnchor.constraint(equalTo: questionView.leadingAnchor, constant: 20),
            answerStack.trailingAnchor.constraint(equalTo: questionView.trailingAnchor, constant: -20),
            answerStack.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc private func backToSelection() {
        showSelectionView()
    }
    
    @objc private func speakQuestion() {
        if let question = currentQuestion {
            speakText(question.questionText)
        }
    }
    
    private func generateNewQuestion() {
        guard let questionView = questionView else { return }
        
        let range = selectedDifficulty.range
        let left = Int(arc4random_uniform(UInt32(range.upperBound - range.lowerBound + 1))) + range.lowerBound
        let right = Int(arc4random_uniform(UInt32(range.upperBound - range.lowerBound + 1))) + range.lowerBound
        
        var answer: Int
        var finalLeft = left
        var finalRight = right
        
        if selectedCalculation == .addition {
            answer = left + right
        } else {
            if left >= right {
                finalLeft = left
                finalRight = right
                answer = left - right
            } else {
                finalLeft = right
                finalRight = left
                answer = right - left
            }
        }
        
        let themeItems = selectedTheme.items
        let themeItem = themeItems[Int(arc4random_uniform(UInt32(themeItems.count)))]
        
        currentQuestion = MathQuestion(
            leftNum: finalLeft,
            rightNum: finalRight,
            answer: answer,
            type: selectedCalculation,
            themeItem: themeItem
        )
        
        updateQuestionDisplay()
        
        let progressLabel = questionView.viewWithTag(100) as? UILabel
        progressLabel?.text = "第 \(correctCount + 1) / \(totalQuestions) 题"
        
        speakText(currentQuestion?.questionText ?? "")
    }
    
    private func updateQuestionDisplay() {
        guard let questionView = questionView, let question = currentQuestion else { return }
        
        let questionTextLabel = questionView.viewWithTag(101) as? UILabel
        questionTextLabel?.text = question.questionText
        
        let iconContainer = questionView.viewWithTag(102) as? UIStackView
        iconContainer?.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        if question.type == .addition {
            for _ in 0..<question.leftNum {
                let iconLabel = UILabel()
                iconLabel.text = question.themeItem
                iconLabel.font = UIFont.systemFont(ofSize: 36)
                iconContainer?.addArrangedSubview(iconLabel)
            }
            
            let plusLabel = UILabel()
            plusLabel.text = "➕"
            plusLabel.font = UIFont.systemFont(ofSize: 30)
            iconContainer?.addArrangedSubview(plusLabel)
            
            for _ in 0..<question.rightNum {
                let iconLabel = UILabel()
                iconLabel.text = question.themeItem
                iconLabel.font = UIFont.systemFont(ofSize: 36)
                iconContainer?.addArrangedSubview(iconLabel)
            }
        } else {
            for i in 0..<question.leftNum {
                let iconLabel = UILabel()
                if i < question.answer {
                    iconLabel.text = question.themeItem
                } else {
                    iconLabel.text = "❌"
                }
                iconLabel.font = UIFont.systemFont(ofSize: 36)
                iconContainer?.addArrangedSubview(iconLabel)
            }
        }
        
        let operatorLabel = questionView.viewWithTag(103) as? UILabel
        operatorLabel?.text = question.type == .addition ? "➕" : "➖"
        
        isAnswering = true
        for button in answerButtons {
            button.isEnabled = true
            button.backgroundColor = Theme.cardBackground.withAlphaComponent(0.8)
        }
    }
    
    @objc private func answerTapped(_ sender: UIButton) {
        guard isAnswering, let question = currentQuestion else { return }
        
        let selectedAnswer = sender.tag
        isAnswering = false
        
        for button in answerButtons {
            button.isEnabled = false
        }
        
        if selectedAnswer == question.answer {
            sender.backgroundColor = UIColor(hex: "4CAF50")
            correctCount += 1
            speakText("答对啦！你真棒～")
            showCorrectAnimation()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.nextQuestion()
            }
        } else {
            sender.backgroundColor = UIColor(hex: "F44336")
            speakText("再想想哦～")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.isAnswering = true
                for button in self.answerButtons {
                    button.isEnabled = true
                    button.backgroundColor = Theme.cardBackground.withAlphaComponent(0.8)
                }
            }
        }
    }
    
    private func showCorrectAnimation() {
        guard let questionView = questionView else { return }
        
        for i in 0..<8 {
            let delay = Double(i) * 0.1
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                let starLabel = UILabel()
                starLabel.text = ["⭐", "🌟", "✨", "💫"][Int(arc4random_uniform(4))]
                starLabel.font = UIFont.systemFont(ofSize: CGFloat(25 + Int(arc4random_uniform(15))))
                starLabel.translatesAutoresizingMaskIntoConstraints = false
                questionView.addSubview(starLabel)
                
                starLabel.centerXAnchor.constraint(equalTo: questionView.centerXAnchor, constant: CGFloat(Int(arc4random_uniform(200)) - 100)).isActive = true
                starLabel.centerYAnchor.constraint(equalTo: questionView.centerYAnchor, constant: CGFloat(Int(arc4random_uniform(150)) - 75)).isActive = true
                
                starLabel.transform = CGAffineTransform(scaleX: 0, y: 0)
                
                UIView.animate(withDuration: 0.4, animations: {
                    starLabel.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                    starLabel.alpha = 1
                }) { _ in
                    UIView.animate(withDuration: 0.4, delay: 0.3, options: [], animations: {
                        starLabel.transform = CGAffineTransform(scaleX: 0, y: 0)
                        starLabel.alpha = 0
                    }) { _ in
                        starLabel.removeFromSuperview()
                    }
                }
            }
        }
    }
    
    private func nextQuestion() {
        if correctCount >= totalQuestions {
            showResultView()
        } else {
            generateNewQuestion()
        }
    }
    
    private func showResultView() {
        questionView.isHidden = true
        
        if resultView == nil {
            setupResultView()
        }
        resultView.isHidden = false
        
        updateResultDisplay()
    }
    
    private func setupResultView() {
        resultView = UIView()
        resultView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(resultView)
        
        NSLayoutConstraint.activate([
            resultView.topAnchor.constraint(equalTo: contentView.topAnchor),
            resultView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            resultView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            resultView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        let trophyLabel = UILabel()
        trophyLabel.text = "🏆"
        trophyLabel.font = UIFont.systemFont(ofSize: 80)
        trophyLabel.textAlignment = .center
        trophyLabel.translatesAutoresizingMaskIntoConstraints = false
        resultView.addSubview(trophyLabel)
        
        let resultTitleLabel = UILabel()
        resultTitleLabel.font = Theme.Font.bold(size: 28)
        resultTitleLabel.textColor = Theme.brightWhite
        resultTitleLabel.textAlignment = .center
        resultTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        resultTitleLabel.tag = 200
        resultView.addSubview(resultTitleLabel)
        
        let resultDetailLabel = UILabel()
        resultDetailLabel.font = Theme.Font.regular(size: 20)
        resultDetailLabel.textColor = Theme.mutedGray
        resultDetailLabel.textAlignment = .center
        resultDetailLabel.translatesAutoresizingMaskIntoConstraints = false
        resultDetailLabel.tag = 201
        resultView.addSubview(resultDetailLabel)
        
        let rewardLabel = UILabel()
        rewardLabel.font = Theme.Font.bold(size: 22)
        rewardLabel.textColor = UIColor(hex: "FFD700")
        rewardLabel.textAlignment = .center
        rewardLabel.translatesAutoresizingMaskIntoConstraints = false
        rewardLabel.tag = 202
        resultView.addSubview(rewardLabel)
        
        let buttonStack = UIStackView()
        buttonStack.axis = .vertical
        buttonStack.spacing = 16
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        resultView.addSubview(buttonStack)
        
        let replayButton = UIButton(type: .system)
        replayButton.setTitle("🔄 再玩一次", for: .normal)
        replayButton.titleLabel?.font = Theme.Font.bold(size: 20)
        replayButton.setTitleColor(Theme.brightWhite, for: .normal)
        replayButton.backgroundColor = Theme.electricBlue
        replayButton.layer.cornerRadius = 25
        replayButton.translatesAutoresizingMaskIntoConstraints = false
        replayButton.addTarget(self, action: #selector(replayGame), for: .touchUpInside)
        buttonStack.addArrangedSubview(replayButton)
        
        let changeButton = UIButton(type: .system)
        changeButton.setTitle("🔁 更换模式", for: .normal)
        changeButton.titleLabel?.font = Theme.Font.bold(size: 20)
        changeButton.setTitleColor(Theme.brightWhite, for: .normal)
        changeButton.backgroundColor = Theme.neonPink
        changeButton.layer.cornerRadius = 25
        changeButton.translatesAutoresizingMaskIntoConstraints = false
        changeButton.addTarget(self, action: #selector(changeMode), for: .touchUpInside)
        buttonStack.addArrangedSubview(changeButton)
        
        let exitButton = UIButton(type: .system)
        exitButton.setTitle("🏠 返回主页", for: .normal)
        exitButton.titleLabel?.font = Theme.Font.bold(size: 20)
        exitButton.setTitleColor(Theme.brightWhite, for: .normal)
        exitButton.backgroundColor = Theme.cardBackground.withAlphaComponent(0.8)
        exitButton.layer.cornerRadius = 25
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        exitButton.addTarget(self, action: #selector(exitGame), for: .touchUpInside)
        buttonStack.addArrangedSubview(exitButton)
        
        NSLayoutConstraint.activate([
            trophyLabel.topAnchor.constraint(equalTo: resultView.topAnchor, constant: 60),
            trophyLabel.centerXAnchor.constraint(equalTo: resultView.centerXAnchor),
            
            resultTitleLabel.topAnchor.constraint(equalTo: trophyLabel.bottomAnchor, constant: 20),
            resultTitleLabel.centerXAnchor.constraint(equalTo: resultView.centerXAnchor),
            
            resultDetailLabel.topAnchor.constraint(equalTo: resultTitleLabel.bottomAnchor, constant: 16),
            resultDetailLabel.centerXAnchor.constraint(equalTo: resultView.centerXAnchor),
            
            rewardLabel.topAnchor.constraint(equalTo: resultDetailLabel.bottomAnchor, constant: 20),
            rewardLabel.centerXAnchor.constraint(equalTo: resultView.centerXAnchor),
            
            buttonStack.topAnchor.constraint(equalTo: rewardLabel.bottomAnchor, constant: 40),
            buttonStack.centerXAnchor.constraint(equalTo: resultView.centerXAnchor),
            buttonStack.widthAnchor.constraint(equalToConstant: 220),
            
            replayButton.heightAnchor.constraint(equalToConstant: 50),
            changeButton.heightAnchor.constraint(equalToConstant: 50),
            exitButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func updateResultDisplay() {
        guard let resultView = resultView else { return }
        
        let titleLabel = resultView.viewWithTag(200) as? UILabel
        let detailLabel = resultView.viewWithTag(201) as? UILabel
        let rewardLabel = resultView.viewWithTag(202) as? UILabel
        
        let percentage = Double(correctCount) / Double(totalQuestions) * 100
        
        if percentage >= 80 {
            titleLabel?.text = "太棒啦！🎉"
            rewardLabel?.text = "🎁 恭喜解锁新主题！"
            speakText("太棒啦！你真厉害！")
        } else if percentage >= 50 {
            titleLabel?.text = "做得很棒！💪"
            rewardLabel?.text = "⭐ 继续加油哦！"
            speakText("做得很棒！继续加油！")
        } else {
            titleLabel?.text = "没关系，继续努力！🌟"
            rewardLabel?.text = "💪 再试试吧！"
            speakText("没关系，继续努力！")
        }
        
        detailLabel?.text = "答对 \(correctCount) / \(totalQuestions) 题"
    }
    
    @objc private func replayGame() {
        correctCount = 0
        speakText("再来一次！")
        showQuestionView()
    }
    
    @objc private func changeMode() {
        correctCount = 0
        showSelectionView()
    }
    
    @objc private func exitGame() {
        navigationController?.popViewController(animated: true)
    }
    
    private func speakText(_ text: String) {
        synthesizer.stopSpeaking(at: .immediate)
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "zh-CN")
        utterance.rate = 0.4
        utterance.pitchMultiplier = 1.2
        synthesizer.speak(utterance)
    }
}

struct MathGameSettings: Codable {
    let theme: String
    let calculation: String
    let difficulty: Int
}
