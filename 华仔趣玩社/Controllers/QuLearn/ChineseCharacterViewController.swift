import UIKit
import AVFoundation

class ChineseCharacterViewController: UIViewController {
    
    private var inputTextField: UITextField!
    private var characterView: CharacterWritingView!
    private var currentCharacter: String = "大"
    private var currentCharLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return false
    }
    
    private func setupUI() {
        let gradientBg = GradientBackgroundView(frame: view.bounds)
        gradientBg.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(gradientBg)
        
        let titleLabel = UILabel()
        titleLabel.text = "✏️ 幼儿识字"
        titleLabel.font = Theme.Font.bold(size: 28)
        titleLabel.textColor = Theme.brightWhite
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        let tipLabel = UILabel()
        tipLabel.text = "输入你想练习的汉字"
        tipLabel.font = Theme.Font.regular(size: 14)
        tipLabel.textColor = Theme.mutedGray
        tipLabel.textAlignment = .center
        tipLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tipLabel)
        
        let inputContainer = UIView()
        inputContainer.backgroundColor = Theme.cardBackground.withAlphaComponent(0.6)
        inputContainer.layer.cornerRadius = Theme.cardCornerRadius
        inputContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(inputContainer)
        
        inputTextField = UITextField()
        inputTextField.placeholder = "例如：大、小、中..."
        inputTextField.font = Theme.Font.bold(size: 28)
        inputTextField.textColor = Theme.brightWhite
        inputTextField.textAlignment = .center
        inputTextField.backgroundColor = Theme.gradientTop.withAlphaComponent(0.5)
        inputTextField.layer.cornerRadius = 12
        inputTextField.layer.borderWidth = 2
        inputTextField.layer.borderColor = Theme.electricBlue.cgColor
        inputTextField.attributedPlaceholder = NSAttributedString(string: "例如：大、小、中...", attributes: [.foregroundColor: Theme.mutedGray])
        inputTextField.translatesAutoresizingMaskIntoConstraints = false
        inputTextField.delegate = self
        inputTextField.returnKeyType = .done
        inputContainer.addSubview(inputTextField)
        
        let startButton = UIButton(type: .system)
        startButton.setTitle("开始练习", for: .normal)
        startButton.titleLabel?.font = Theme.Font.bold(size: 18)
        startButton.setTitleColor(Theme.brightWhite, for: .normal)
        startButton.backgroundColor = Theme.electricBlue
        startButton.layer.cornerRadius = 12
        startButton.translatesAutoresizingMaskIntoConstraints = false
        startButton.addTarget(self, action: #selector(startPractice), for: .touchUpInside)
        inputContainer.addSubview(startButton)
        
        NSLayoutConstraint.activate([
            inputTextField.topAnchor.constraint(equalTo: inputContainer.topAnchor, constant: 16),
            inputTextField.leadingAnchor.constraint(equalTo: inputContainer.leadingAnchor, constant: 16),
            inputTextField.trailingAnchor.constraint(equalTo: startButton.leadingAnchor, constant: -12),
            inputTextField.heightAnchor.constraint(equalToConstant: 50),
            
            startButton.topAnchor.constraint(equalTo: inputContainer.topAnchor, constant: 16),
            startButton.trailingAnchor.constraint(equalTo: inputContainer.trailingAnchor, constant: -16),
            startButton.widthAnchor.constraint(equalToConstant: 100),
            startButton.heightAnchor.constraint(equalToConstant: 50),
            startButton.bottomAnchor.constraint(equalTo: inputContainer.bottomAnchor, constant: -16)
        ])
        
        currentCharLabel = UILabel()
        currentCharLabel.text = "当前练习: \(currentCharacter)"
        currentCharLabel.font = Theme.Font.bold(size: 20)
        currentCharLabel.textColor = Theme.neonPink
        currentCharLabel.textAlignment = .center
        currentCharLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(currentCharLabel)
        
        characterView = CharacterWritingView(frame: .zero)
        characterView.backgroundColor = .white
        characterView.layer.cornerRadius = Theme.cardCornerRadius
        characterView.layer.borderWidth = 3
        characterView.layer.borderColor = Theme.neonPink.cgColor
        characterView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(characterView)
        
        characterView.setCharacter(currentCharacter)
        
        let buttonStack = UIStackView()
        buttonStack.axis = .horizontal
        buttonStack.spacing = 16
        buttonStack.distribution = .fillEqually
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonStack)
        
        let clearButton = UIButton(type: .system)
        clearButton.setTitle("🗑️ 清除", for: .normal)
        clearButton.titleLabel?.font = Theme.Font.bold(size: 18)
        clearButton.setTitleColor(Theme.brightWhite, for: .normal)
        clearButton.backgroundColor = Theme.neonPink
        clearButton.layer.cornerRadius = 16
        clearButton.addTarget(self, action: #selector(clearWriting), for: .touchUpInside)
        buttonStack.addArrangedSubview(clearButton)
        
        let speakButton = UIButton(type: .system)
        speakButton.setTitle("🔊 发音", for: .normal)
        speakButton.titleLabel?.font = Theme.Font.bold(size: 18)
        speakButton.setTitleColor(Theme.brightWhite, for: .normal)
        speakButton.backgroundColor = Theme.electricBlue
        speakButton.layer.cornerRadius = 16
        speakButton.addTarget(self, action: #selector(speakCharacter), for: .touchUpInside)
        buttonStack.addArrangedSubview(speakButton)
        
        let practiceTipLabel = UILabel()
        practiceTipLabel.text = "💡 用手指在田字格内描红练习写字"
        practiceTipLabel.font = Theme.Font.regular(size: 14)
        practiceTipLabel.textColor = Theme.mutedGray
        practiceTipLabel.textAlignment = .center
        practiceTipLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(practiceTipLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            tipLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            tipLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            inputContainer.topAnchor.constraint(equalTo: tipLabel.bottomAnchor, constant: 16),
            inputContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            inputContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            currentCharLabel.topAnchor.constraint(equalTo: inputContainer.bottomAnchor, constant: 16),
            currentCharLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            characterView.topAnchor.constraint(equalTo: currentCharLabel.bottomAnchor, constant: 16),
            characterView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            characterView.widthAnchor.constraint(equalToConstant: 280),
            characterView.heightAnchor.constraint(equalToConstant: 280),
            
            buttonStack.topAnchor.constraint(equalTo: characterView.bottomAnchor, constant: 20),
            buttonStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            buttonStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            buttonStack.heightAnchor.constraint(equalToConstant: 56),
            
            practiceTipLabel.topAnchor.constraint(equalTo: buttonStack.bottomAnchor, constant: 12),
            practiceTipLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        title = "幼儿识字"
    }
    
    @objc private func startPractice() {
        inputTextField.resignFirstResponder()
        if let text = inputTextField.text, !text.isEmpty {
            let firstChar = String(text.prefix(1))
            updateCharacter(firstChar)
        }
    }
    
    @objc private func clearWriting() {
        characterView.clearWriting()
    }
    
    @objc private func speakCharacter() {
        let synthesizer = AVSpeechSynthesizer()
        let utterance = AVSpeechUtterance(string: currentCharacter)
        utterance.voice = AVSpeechSynthesisVoice(language: "zh-CN")
        utterance.rate = 0.4
        synthesizer.speak(utterance)
    }
    
    private func updateCharacter(_ char: String) {
        if !char.isEmpty {
            currentCharacter = char
            characterView.setCharacter(char)
            currentCharLabel.text = "当前练习: \(currentCharacter)"
            
            currentCharLabel.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            UIView.animate(withDuration: 0.3) {
                self.currentCharLabel.transform = .identity
            }
            
            speakCharacter()
        }
    }
}

extension ChineseCharacterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        startPractice()
        return true
    }
}

class CharacterWritingView: UIView {
    
    private var targetCharacter: String = ""
    private var paths: [UIBezierPath] = []
    private var currentPath: UIBezierPath?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = .white
        layer.addSublayer(CAShapeLayer())
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        addGestureRecognizer(panGesture)
    }
    
    func setCharacter(_ char: String) {
        targetCharacter = char
        paths.removeAll()
        setNeedsDisplay()
    }
    
    func clearWriting() {
        paths.removeAll()
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        let gridSize = min(bounds.width, bounds.height)
        let offsetX = (bounds.width - gridSize) / 2
        let offsetY = (bounds.height - gridSize) / 2
        
        UIColor(hex: "E8E8E8").setStroke()
        context.setLineWidth(1)
        context.setLineDash(phase: 0, lengths: [5, 5])
        
        context.move(to: CGPoint(x: offsetX, y: offsetY + gridSize / 2))
        context.addLine(to: CGPoint(x: offsetX + gridSize, y: offsetY + gridSize / 2))
        
        context.move(to: CGPoint(x: offsetX + gridSize / 2, y: offsetY))
        context.addLine(to: CGPoint(x: offsetX + gridSize / 2, y: offsetY + gridSize))
        
        context.move(to: CGPoint(x: offsetX, y: offsetY))
        context.addLine(to: CGPoint(x: offsetX + gridSize, y: offsetY + gridSize))
        
        context.move(to: CGPoint(x: offsetX + gridSize, y: offsetY))
        context.addLine(to: CGPoint(x: offsetX, y: offsetY + gridSize))
        
        context.strokePath()
        
        UIColor(hex: "CCCCCC").setStroke()
        context.setLineWidth(3)
        context.setLineDash(phase: 0, lengths: [])
        context.stroke(CGRect(x: offsetX, y: offsetY, width: gridSize, height: gridSize))
        
        if !targetCharacter.isEmpty {
            let fontSize: CGFloat = gridSize * 0.75
            let font = UIFont.systemFont(ofSize: fontSize, weight: .regular)
            let attributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: UIColor(hex: "DDDDDD").withAlphaComponent(0.6)
            ]
            let size = targetCharacter.size(withAttributes: attributes)
            let x = offsetX + (gridSize - size.width) / 2
            let y = offsetY + (gridSize - size.height) / 2
            targetCharacter.draw(at: CGPoint(x: x, y: y), withAttributes: attributes)
        }
        
        UIColor(hex: "333333").setStroke()
        for path in paths {
            path.lineWidth = 10
            path.lineCapStyle = .round
            path.lineJoinStyle = .round
            path.stroke()
        }
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: self)
        
        switch gesture.state {
        case .began:
            currentPath = UIBezierPath()
            currentPath?.move(to: location)
        case .changed:
            currentPath?.addLine(to: location)
            if let path = currentPath {
                paths.append(path)
            }
            currentPath = UIBezierPath()
            currentPath?.move(to: location)
            setNeedsDisplay()
        case .ended:
            if let path = currentPath {
                paths.append(path)
            }
            currentPath = nil
            setNeedsDisplay()
        default:
            break
        }
    }
}
