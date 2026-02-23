import UIKit

class ChineseCharacterViewController: UIViewController {
    
    private var inputTextField: UITextField!
    private var characterView: CharacterWritingView!
    private var currentCharacter: String = "大"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = Theme.gradientTop
        
        let titleLabel = UILabel()
        titleLabel.text = "幼儿识字"
        titleLabel.font = Theme.Font.bold(size: 24)
        titleLabel.textColor = Theme.brightWhite
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        let inputContainer = UIView()
        inputContainer.backgroundColor = Theme.cardBackground.withAlphaComponent(0.6)
        inputContainer.layer.cornerRadius = Theme.cornerRadius
        inputContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(inputContainer)
        
        inputTextField = UITextField()
        inputTextField.placeholder = "输入汉字..."
        inputTextField.font = Theme.Font.regular(size: 20)
        inputTextField.textColor = Theme.brightWhite
        inputTextField.textAlignment = .center
        inputTextField.backgroundColor = Theme.gradientTop
        inputTextField.layer.cornerRadius = 8
        inputTextField.layer.borderWidth = 2
        inputTextField.layer.borderColor = Theme.electricBlue.cgColor
        inputTextField.translatesAutoresizingMaskIntoConstraints = false
        inputTextField.delegate = self
        inputContainer.addSubview(inputTextField)
        
        NSLayoutConstraint.activate([
            inputTextField.topAnchor.constraint(equalTo: inputContainer.topAnchor, constant: 12),
            inputTextField.leadingAnchor.constraint(equalTo: inputContainer.leadingAnchor, constant: 16),
            inputTextField.trailingAnchor.constraint(equalTo: inputContainer.trailingAnchor, constant: -16),
            inputTextField.bottomAnchor.constraint(equalTo: inputContainer.bottomAnchor, constant: -12),
            inputTextField.heightAnchor.constraint(equalToConstant: 44)
        ])
        
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
        clearButton.setTitle("清除", for: .normal)
        clearButton.titleLabel?.font = Theme.Font.bold(size: 16)
        clearButton.setTitleColor(Theme.brightWhite, for: .normal)
        clearButton.backgroundColor = Theme.neonPink
        clearButton.layer.cornerRadius = 12
        clearButton.addTarget(self, action: #selector(clearWriting), for: .touchUpInside)
        buttonStack.addArrangedSubview(clearButton)
        
        let speakButton = UIButton(type: .system)
        speakButton.setTitle("🔊 发音", for: .normal)
        speakButton.titleLabel?.font = Theme.Font.bold(size: 16)
        speakButton.setTitleColor(Theme.brightWhite, for: .normal)
        speakButton.backgroundColor = Theme.electricBlue
        speakButton.layer.cornerRadius = 12
        speakButton.addTarget(self, action: #selector(speakCharacter), for: .touchUpInside)
        buttonStack.addArrangedSubview(speakButton)
        
        let tipLabel = UILabel()
        tipLabel.text = "💡 在田字格内用手指描红练习写字"
        tipLabel.font = Theme.Font.regular(size: 14)
        tipLabel.textColor = Theme.mutedGray
        tipLabel.textAlignment = .center
        tipLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tipLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            inputContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            inputContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            inputContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            characterView.topAnchor.constraint(equalTo: inputContainer.bottomAnchor, constant: 24),
            characterView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            characterView.widthAnchor.constraint(equalToConstant: 300),
            characterView.heightAnchor.constraint(equalToConstant: 300),
            
            buttonStack.topAnchor.constraint(equalTo: characterView.bottomAnchor, constant: 24),
            buttonStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            buttonStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            buttonStack.heightAnchor.constraint(equalToConstant: 50),
            
            tipLabel.topAnchor.constraint(equalTo: buttonStack.bottomAnchor, constant: 16),
            tipLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        title = "幼儿识字"
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
        }
    }
}

extension ChineseCharacterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if let text = textField.text, !text.isEmpty {
            let firstChar = String(text.prefix(1))
            updateCharacter(firstChar)
        }
        return true
    }
}

import AVFoundation

class CharacterWritingView: UIView {
    
    private var targetCharacter: String = ""
    private var paths: [UIBezierPath] = []
    private var currentPath: UIBezierPath?
    private var characterLayer = CAShapeLayer()
    
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
        layer.addSublayer(characterLayer)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        addGestureRecognizer(panGesture)
    }
    
    func setCharacter(_ char: String) {
        targetCharacter = char
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
        
        context.setStrokeColor(UIColor.lightGray.cgColor)
        context.setLineWidth(1)
        
        context.move(to: CGPoint(x: offsetX, y: offsetY + gridSize / 2))
        context.addLine(to: CGPoint(x: offsetX + gridSize, y: offsetY + gridSize / 2))
        
        context.move(to: CGPoint(x: offsetX + gridSize / 2, y: offsetY))
        context.addLine(to: CGPoint(x: offsetX + gridSize / 2, y: offsetY + gridSize))
        
        context.strokePath()
        
        context.setStrokeColor(UIColor.gray.cgColor)
        context.setLineWidth(2)
        context.stroke(CGRect(x: offsetX, y: offsetY, width: gridSize, height: gridSize))
        
        if !targetCharacter.isEmpty {
            let fontSize: CGFloat = gridSize * 0.7
            let font = UIFont.systemFont(ofSize: fontSize, weight: .regular)
            let attributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: UIColor.lightGray.withAlphaComponent(0.3)
            ]
            let size = targetCharacter.size(withAttributes: attributes)
            let x = offsetX + (gridSize - size.width) / 2
            let y = offsetY + (gridSize - size.height) / 2
            targetCharacter.draw(at: CGPoint(x: x, y: y), withAttributes: attributes)
        }
        
        UIColor(hex: "333333").setStroke()
        for path in paths {
            path.lineWidth = 8
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
