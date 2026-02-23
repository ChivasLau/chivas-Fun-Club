import UIKit
import AVFoundation

class MathTableViewController: UIViewController {
    
    private let fruits: [String] = ["🍎", "🍊", "🍋", "🍇", "🍓", "🍑", "🍒", "🥝", "🍌", "🍉"]
    private let stars: [String] = ["⭐", "🌟", "✨"]
    
    private var currentQuestion: (leftNum: Int, rightNum: Int, answer: Int, isAddition: Bool)?
    private var score = 0
    private var starsEarned = 0
    private var answerOptions: [Int] = []
    
    private var questionLabel: UILabel!
    private var leftFruitsLabel: UILabel!
    private var rightFruitsLabel: UILabel!
    private var scoreLabel: UILabel!
    private var starsLabel: UILabel!
    private var answerButtons: [UIButton] = []
    private var starAnimationView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        generateNewQuestion()
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
        titleLabel.text = "🍓 加减口诀"
        titleLabel.font = Theme.Font.bold(size: 28)
        titleLabel.textColor = Theme.brightWhite
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        let scoreContainer = UIView()
        scoreContainer.backgroundColor = Theme.cardBackground.withAlphaComponent(0.6)
        scoreContainer.layer.cornerRadius = 16
        scoreContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scoreContainer)
        
        scoreLabel = UILabel()
        scoreLabel.text = "得分: 0"
        scoreLabel.font = Theme.Font.bold(size: 18)
        scoreLabel.textColor = Theme.electricBlue
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreContainer.addSubview(scoreLabel)
        
        starsLabel = UILabel()
        starsLabel.text = "⭐ 0"
        starsLabel.font = Theme.Font.bold(size: 18)
        starsLabel.textColor = UIColor(hex: "FFD700")
        starsLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreContainer.addSubview(starsLabel)
        
        NSLayoutConstraint.activate([
            scoreLabel.topAnchor.constraint(equalTo: scoreContainer.topAnchor, constant: 12),
            scoreLabel.leadingAnchor.constraint(equalTo: scoreContainer.leadingAnchor, constant: 16),
            scoreLabel.bottomAnchor.constraint(equalTo: scoreContainer.bottomAnchor, constant: -12),
            
            starsLabel.topAnchor.constraint(equalTo: scoreContainer.topAnchor, constant: 12),
            starsLabel.trailingAnchor.constraint(equalTo: scoreContainer.trailingAnchor, constant: -16),
            starsLabel.bottomAnchor.constraint(equalTo: scoreContainer.bottomAnchor, constant: -12)
        ])
        
        let questionCard = UIView()
        questionCard.backgroundColor = Theme.cardBackground.withAlphaComponent(0.8)
        questionCard.layer.cornerRadius = Theme.cardCornerRadius
        questionCard.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(questionCard)
        
        questionLabel = UILabel()
        questionLabel.font = UIFont.systemFont(ofSize: 36, weight: .bold)
        questionLabel.textColor = Theme.brightWhite
        questionLabel.textAlignment = .center
        questionLabel.text = "? + ? = ?"
        questionLabel.translatesAutoresizingMaskIntoConstraints = false
        questionCard.addSubview(questionLabel)
        
        let fruitContainer = UIView()
        fruitContainer.translatesAutoresizingMaskIntoConstraints = false
        questionCard.addSubview(fruitContainer)
        
        leftFruitsLabel = UILabel()
        leftFruitsLabel.font = UIFont.systemFont(ofSize: 32)
        leftFruitsLabel.textAlignment = .center
        leftFruitsLabel.numberOfLines = 2
        leftFruitsLabel.translatesAutoresizingMaskIntoConstraints = false
        fruitContainer.addSubview(leftFruitsLabel)
        
        let plusLabel = UILabel()
        plusLabel.font = UIFont.systemFont(ofSize: 36, weight: .bold)
        plusLabel.text = "+"
        plusLabel.textColor = Theme.neonPink
        plusLabel.textAlignment = .center
        plusLabel.translatesAutoresizingMaskIntoConstraints = false
        fruitContainer.addSubview(plusLabel)
        
        rightFruitsLabel = UILabel()
        rightFruitsLabel.font = UIFont.systemFont(ofSize: 32)
        rightFruitsLabel.textAlignment = .center
        rightFruitsLabel.numberOfLines = 2
        rightFruitsLabel.translatesAutoresizingMaskIntoConstraints = false
        fruitContainer.addSubview(rightFruitsLabel)
        
        NSLayoutConstraint.activate([
            leftFruitsLabel.topAnchor.constraint(equalTo: fruitContainer.topAnchor),
            leftFruitsLabel.leadingAnchor.constraint(equalTo: fruitContainer.leadingAnchor),
            leftFruitsLabel.bottomAnchor.constraint(equalTo: fruitContainer.bottomAnchor),
            
            plusLabel.topAnchor.constraint(equalTo: fruitContainer.topAnchor),
            plusLabel.leadingAnchor.constraint(equalTo: leftFruitsLabel.trailingAnchor, constant: 12),
            plusLabel.bottomAnchor.constraint(equalTo: fruitContainer.bottomAnchor),
            
            rightFruitsLabel.topAnchor.constraint(equalTo: fruitContainer.topAnchor),
            rightFruitsLabel.leadingAnchor.constraint(equalTo: plusLabel.trailingAnchor, constant: 12),
            rightFruitsLabel.trailingAnchor.constraint(equalTo: fruitContainer.trailingAnchor),
            rightFruitsLabel.bottomAnchor.constraint(equalTo: fruitContainer.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            questionLabel.topAnchor.constraint(equalTo: questionCard.topAnchor, constant: 20),
            questionLabel.centerXAnchor.constraint(equalTo: questionCard.centerXAnchor),
            
            fruitContainer.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 16),
            fruitContainer.centerXAnchor.constraint(equalTo: questionCard.centerXAnchor),
            fruitContainer.bottomAnchor.constraint(equalTo: questionCard.bottomAnchor, constant: -20)
        ])
        
        let answerCard = UIView()
        answerCard.backgroundColor = Theme.cardBackground.withAlphaComponent(0.8)
        answerCard.layer.cornerRadius = Theme.cardCornerRadius
        answerCard.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(answerCard)
        
        let tipLabel = UILabel()
        tipLabel.text = "👆 点选正确答案"
        tipLabel.font = Theme.Font.regular(size: 16)
        tipLabel.textColor = Theme.mutedGray
        tipLabel.textAlignment = .center
        tipLabel.translatesAutoresizingMaskIntoConstraints = false
        answerCard.addSubview(tipLabel)
        
        let answerStack = UIStackView()
        answerStack.axis = .horizontal
        answerStack.spacing = 16
        answerStack.distribution = .fillEqually
        answerStack.translatesAutoresizingMaskIntoConstraints = false
        answerCard.addSubview(answerStack)
        
        for i in 0..<4 {
            let button = UIButton(type: .system)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 32, weight: .bold)
            button.setTitleColor(Theme.brightWhite, for: .normal)
            button.backgroundColor = Theme.electricBlue
            button.layer.cornerRadius = 20
            button.tag = i
            button.addTarget(self, action: #selector(answerTapped(_:)), for: .touchUpInside)
            answerStack.addArrangedSubview(button)
            answerButtons.append(button)
        }
        
        NSLayoutConstraint.activate([
            tipLabel.topAnchor.constraint(equalTo: answerCard.topAnchor, constant: 16),
            tipLabel.centerXAnchor.constraint(equalTo: answerCard.centerXAnchor),
            
            answerStack.topAnchor.constraint(equalTo: tipLabel.bottomAnchor, constant: 16),
            answerStack.leadingAnchor.constraint(equalTo: answerCard.leadingAnchor, constant: 20),
            answerStack.trailingAnchor.constraint(equalTo: answerCard.trailingAnchor, constant: -20),
            answerStack.bottomAnchor.constraint(equalTo: answerCard.bottomAnchor, constant: -20),
            answerStack.heightAnchor.constraint(equalToConstant: 70)
        ])
        
        starAnimationView = UIView(frame: view.bounds)
        starAnimationView.isUserInteractionEnabled = false
        starAnimationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(starAnimationView)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            scoreContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            scoreContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            scoreContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            questionCard.topAnchor.constraint(equalTo: scoreContainer.bottomAnchor, constant: 24),
            questionCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            questionCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            answerCard.topAnchor.constraint(equalTo: questionCard.bottomAnchor, constant: 24),
            answerCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            answerCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            starAnimationView.topAnchor.constraint(equalTo: view.topAnchor),
            starAnimationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            starAnimationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            starAnimationView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        title = "加减口诀"
    }
    
    private func generateNewQuestion() {
        let left = Int(arc4random_uniform(5)) + 1
        let right = Int(arc4random_uniform(5)) + 1
        let isAddition = arc4random_uniform(2) == 0
        
        let fruit = fruits[Int(arc4random_uniform(UInt32(fruits.count)))]
        
        if isAddition {
            currentQuestion = (left, right, left + right, true)
            questionLabel.text = "\(left) + \(right) = ?"
            leftFruitsLabel.text = String(repeating: fruit, count: left)
            rightFruitsLabel.text = String(repeating: fruit, count: right)
        } else {
            let larger = max(left, right)
            let smaller = min(left, right)
            currentQuestion = (larger, smaller, larger - smaller, false)
            questionLabel.text = "\(larger) - \(smaller) = ?"
            leftFruitsLabel.text = String(repeating: fruit, count: larger)
            rightFruitsLabel.text = String(repeating: "⬜", count: smaller)
        }
        
        generateAnswerOptions()
        animateQuestion()
    }
    
    private func generateAnswerOptions() {
        guard let answer = currentQuestion?.answer else { return }
        
        var options: Set<Int> = [answer]
        while options.count < 4 {
            let wrongAnswer = Int(arc4random_uniform(10)) + 1
            options.insert(wrongAnswer)
        }
        answerOptions = Array(options).shuffled()
        
        for (index, button) in answerButtons.enumerated() {
            button.setTitle("\(answerOptions[index])", for: .normal)
            button.backgroundColor = Theme.electricBlue
            button.isEnabled = true
        }
    }
    
    private func animateQuestion() {
        questionLabel.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        questionLabel.alpha = 0
        UIView.animate(withDuration: 0.3) {
            self.questionLabel.transform = .identity
            self.questionLabel.alpha = 1
        }
    }
    
    @objc private func answerTapped(_ sender: UIButton) {
        let selectedIndex = sender.tag
        let selectedAnswer = answerOptions[selectedIndex]
        
        for button in answerButtons {
            button.isEnabled = false
        }
        
        if selectedAnswer == currentQuestion?.answer {
            sender.backgroundColor = UIColor(hex: "4CAF50")
            score += 10
            starsEarned += 1
            scoreLabel.text = "得分: \(score)"
            starsLabel.text = "⭐ \(starsEarned)"
            showStarAnimation()
            speakText("太棒了！答对了！")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.generateNewQuestion()
            }
        } else {
            sender.backgroundColor = UIColor(hex: "F44336")
            speakText("再想想哦")
            
            if let answer = currentQuestion?.answer {
                for (index, option) in answerOptions.enumerated() {
                    if option == answer {
                        answerButtons[index].backgroundColor = UIColor(hex: "4CAF50")
                        answerButtons[index].layer.borderWidth = 3
                        answerButtons[index].layer.borderColor = UIColor.white.cgColor
                    }
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.generateNewQuestion()
            }
        }
    }
    
    private func showStarAnimation() {
        for i in 0..<5 {
            let delay = Double(i) * 0.1
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                let starLabel = UILabel()
                let star = self.stars[Int(arc4random_uniform(UInt32(self.stars.count)))]
                starLabel.text = star
                starLabel.font = UIFont.systemFont(ofSize: CGFloat(30 + Int(arc4random_uniform(20))))
                starLabel.translatesAutoresizingMaskIntoConstraints = false
                self.starAnimationView.addSubview(starLabel)
                
                starLabel.centerXAnchor.constraint(equalTo: self.starAnimationView.centerXAnchor, constant: CGFloat(Int(arc4random_uniform(200)) - 100)).isActive = true
                starLabel.centerYAnchor.constraint(equalTo: self.starAnimationView.centerYAnchor, constant: CGFloat(Int(arc4random_uniform(200)) - 100)).isActive = true
                
                starLabel.transform = CGAffineTransform(scaleX: 0, y: 0)
                
                UIView.animate(withDuration: 0.5, animations: {
                    starLabel.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
                    starLabel.alpha = 1
                }) { _ in
                    UIView.animate(withDuration: 0.5, delay: 0.5, options: [], animations: {
                        starLabel.transform = CGAffineTransform(scaleX: 0, y: 0)
                        starLabel.alpha = 0
                    }) { _ in
                        starLabel.removeFromSuperview()
                    }
                }
            }
        }
    }
    
    private func speakText(_ text: String) {
        let synthesizer = AVSpeechSynthesizer()
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "zh-CN")
        utterance.rate = 0.5
        synthesizer.speak(utterance)
    }
}
