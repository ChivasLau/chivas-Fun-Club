import UIKit
import AVFoundation

class AlphabetViewController: UIViewController {
    
    private let letters: [(String, String)] = [
        ("A", "Apple"), ("B", "Banana"), ("C", "Cat"), ("D", "Dog"), ("E", "Elephant"),
        ("F", "Fish"), ("G", "Grape"), ("H", "House"), ("I", "Ice cream"), ("J", "Juice"),
        ("K", "Kite"), ("L", "Lemon"), ("M", "Moon"), ("N", "Nest"), ("O", "Orange"),
        ("P", "Pig"), ("Q", "Queen"), ("R", "Rabbit"), ("S", "Sun"), ("T", "Tiger"),
        ("U", "Umbrella"), ("V", "Violin"), ("W", "Watermelon"), ("X", "X-ray"), ("Y", "Yogurt"), ("Z", "Zebra")
    ]
    
    private var currentLetterIndex: Int = 0
    private var letterLabel: UILabel!
    private var wordLabel: UILabel!
    private var writingView: LetterWritingView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateDisplay()
    }
    
    private func setupUI() {
        view.backgroundColor = Theme.gradientTop
        
        let titleLabel = UILabel()
        titleLabel.text = "字母点读"
        titleLabel.font = Theme.Font.bold(size: 24)
        titleLabel.textColor = Theme.brightWhite
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        let cardView = UIView()
        cardView.backgroundColor = Theme.cardBackground.withAlphaComponent(0.6)
        cardView.layer.cornerRadius = Theme.cardCornerRadius
        cardView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cardView)
        
        letterLabel = UILabel()
        letterLabel.font = UIFont.systemFont(ofSize: 120, weight: .bold)
        letterLabel.textColor = Theme.neonPink
        letterLabel.textAlignment = .center
        letterLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(letterLabel)
        
        wordLabel = UILabel()
        wordLabel.font = Theme.Font.bold(size: 28)
        wordLabel.textColor = Theme.electricBlue
        wordLabel.textAlignment = .center
        wordLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(wordLabel)
        
        NSLayoutConstraint.activate([
            letterLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 30),
            letterLabel.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            
            wordLabel.topAnchor.constraint(equalTo: letterLabel.bottomAnchor, constant: 16),
            wordLabel.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            wordLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -30)
        ])
        
        writingView = LetterWritingView(frame: .zero)
        writingView.backgroundColor = .white
        writingView.layer.cornerRadius = Theme.cornerRadius
        writingView.layer.borderWidth = 2
        writingView.layer.borderColor = Theme.electricBlue.cgColor
        writingView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(writingView)
        
        let buttonStack = UIStackView()
        buttonStack.axis = .horizontal
        buttonStack.spacing = 12
        buttonStack.distribution = .fillEqually
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonStack)
        
        let prevButton = UIButton(type: .system)
        prevButton.setTitle("◀", for: .normal)
        prevButton.titleLabel?.font = Theme.Font.bold(size: 24)
        prevButton.setTitleColor(Theme.brightWhite, for: .normal)
        prevButton.backgroundColor = Theme.mutedGray
        prevButton.layer.cornerRadius = 12
        prevButton.addTarget(self, action: #selector(prevLetter), for: .touchUpInside)
        buttonStack.addArrangedSubview(prevButton)
        
        let speakButton = UIButton(type: .system)
        speakButton.setTitle("🔊", for: .normal)
        speakButton.titleLabel?.font = UIFont.systemFont(ofSize: 24)
        speakButton.setTitleColor(Theme.brightWhite, for: .normal)
        speakButton.backgroundColor = Theme.electricBlue
        speakButton.layer.cornerRadius = 12
        speakButton.addTarget(self, action: #selector(speakLetter), for: .touchUpInside)
        buttonStack.addArrangedSubview(speakButton)
        
        let clearButton = UIButton(type: .system)
        clearButton.setTitle("清除", for: .normal)
        clearButton.titleLabel?.font = Theme.Font.bold(size: 18)
        clearButton.setTitleColor(Theme.brightWhite, for: .normal)
        clearButton.backgroundColor = Theme.neonPink
        clearButton.layer.cornerRadius = 12
        clearButton.addTarget(self, action: #selector(clearWriting), for: .touchUpInside)
        buttonStack.addArrangedSubview(clearButton)
        
        let nextButton = UIButton(type: .system)
        nextButton.setTitle("▶", for: .normal)
        nextButton.titleLabel?.font = Theme.Font.bold(size: 24)
        nextButton.setTitleColor(Theme.brightWhite, for: .normal)
        nextButton.backgroundColor = Theme.electricBlue
        nextButton.layer.cornerRadius = 12
        nextButton.addTarget(self, action: #selector(nextLetter), for: .touchUpInside)
        buttonStack.addArrangedSubview(nextButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            cardView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            writingView.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 16),
            writingView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            writingView.widthAnchor.constraint(equalToConstant: 250),
            writingView.heightAnchor.constraint(equalToConstant: 250),
            
            buttonStack.topAnchor.constraint(equalTo: writingView.bottomAnchor, constant: 20),
            buttonStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonStack.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        title = "字母点读"
    }
    
    private func updateDisplay() {
        let letter = letters[currentLetterIndex]
        letterLabel.text = letter.0
        wordLabel.text = letter.1
        writingView.setLetter(letter.0)
    }
    
    @objc private func prevLetter() {
        currentLetterIndex = (currentLetterIndex - 1 + letters.count) % letters.count
        updateDisplay()
    }
    
    @objc private func nextLetter() {
        currentLetterIndex = (currentLetterIndex + 1) % letters.count
        updateDisplay()
    }
    
    @objc private func speakLetter() {
        let letter = letters[currentLetterIndex]
        let synthesizer = AVSpeechSynthesizer()
        let utterance = AVSpeechUtterance(string: "\(letter.0), \(letter.1)")
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.4
        synthesizer.speak(utterance)
    }
    
    @objc private func clearWriting() {
        writingView.clear()
    }
}

class LetterWritingView: UIView {
    
    private var letter: String = "A"
    private var paths: [UIBezierPath] = []
    private var currentPath: UIBezierPath?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        addGestureRecognizer(pan)
    }
    
    func setLetter(_ letter: String) {
        self.letter = letter
        clear()
    }
    
    func clear() {
        paths.removeAll()
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        UIColor.lightGray.withAlphaComponent(0.2).setFill()
        UIRectFill(bounds)
        
        let font = UIFont.systemFont(ofSize: min(bounds.width, bounds.height) * 0.7, weight: .ultraLight)
        let attrs: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: UIColor.lightGray.withAlphaComponent(0.3)]
        let size = letter.size(withAttributes: attrs)
        let x = (bounds.width - size.width) / 2
        let y = (bounds.height - size.height) / 2
        letter.draw(at: CGPoint(x: x, y: y), withAttributes: attrs)
        
        UIColor(hex: "333333").setStroke()
        for path in paths {
            path.lineWidth = 6
            path.lineCapStyle = .round
            path.stroke()
        }
    }
    
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        let loc = gesture.location(in: self)
        
        switch gesture.state {
        case .began:
            currentPath = UIBezierPath()
            currentPath?.move(to: loc)
        case .changed:
            currentPath?.addLine(to: loc)
            if let p = currentPath { paths.append(p) }
            currentPath = UIBezierPath()
            currentPath?.move(to: loc)
            setNeedsDisplay()
        case .ended:
            if let p = currentPath { paths.append(p) }
            currentPath = nil
            setNeedsDisplay()
        default: break
        }
    }
}
