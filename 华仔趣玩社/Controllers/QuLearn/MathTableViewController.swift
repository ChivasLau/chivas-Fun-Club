import UIKit
import AVFoundation

class MathTableViewController: UIViewController {
    
    private var currentTableType: TableType = .addition
    private var currentNumber = 1
    private var isQuizMode = false
    private var quizQuestion: (left: Int, right: Int, answer: Int, isAddition: Bool)?
    private var userAnswer = ""
    private var score = 0
    private var totalQuestions = 0
    
    private var answerTextField: UITextField!
    private var questionLabel: UILabel!
    private var scoreLabel: UILabel!
    private var tableCollectionView: UICollectionView!
    
    private enum TableType {
        case addition
        case subtraction
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        let gradientBg = GradientBackgroundView(frame: view.bounds)
        gradientBg.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(gradientBg)
        
        let titleLabel = UILabel()
        titleLabel.text = "加减口诀表"
        titleLabel.font = Theme.Font.bold(size: 28)
        titleLabel.textColor = Theme.brightWhite
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        let segmentControl = UISegmentedControl(items: ["加法表", "减法表", "趣味测验"])
        segmentControl.selectedSegmentIndex = 0
        segmentControl.translatesAutoresizingMaskIntoConstraints = false
        segmentControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        if #available(iOS 13.0, *) {
            segmentControl.selectedSegmentTintColor = Theme.electricBlue
        } else {
            segmentControl.tintColor = Theme.electricBlue
        }
        segmentControl.setTitleTextAttributes([.foregroundColor: Theme.brightWhite], for: .selected)
        segmentControl.setTitleTextAttributes([.foregroundColor: Theme.mutedGray], for: .normal)
        view.addSubview(segmentControl)
        
        let numberSlider = UISlider()
        numberSlider.minimumValue = 1
        numberSlider.maximumValue = 10
        numberSlider.value = 1
        numberSlider.translatesAutoresizingMaskIntoConstraints = false
        numberSlider.addTarget(self, action: #selector(sliderChanged(_:)), for: .valueChanged)
        numberSlider.tintColor = Theme.neonPink
        view.addSubview(numberSlider)
        
        let numberLabel = UILabel()
        numberLabel.text = "当前数字: 1"
        numberLabel.font = Theme.Font.regular(size: 16)
        numberLabel.textColor = Theme.mutedGray
        numberLabel.textAlignment = .center
        numberLabel.tag = 100
        numberLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(numberLabel)
        
        let contentContainer = UIView()
        contentContainer.backgroundColor = Theme.cardBackground.withAlphaComponent(0.6)
        contentContainer.layer.cornerRadius = Theme.cardCornerRadius
        contentContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentContainer)
        
        tableCollectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        tableCollectionView.backgroundColor = .clear
        tableCollectionView.dataSource = self
        tableCollectionView.translatesAutoresizingMaskIntoConstraints = false
        tableCollectionView.register(MathCell.self, forCellWithReuseIdentifier: "MathCell")
        contentContainer.addSubview(tableCollectionView)
        
        let quizContainer = UIView()
        quizContainer.backgroundColor = Theme.cardBackground.withAlphaComponent(0.6)
        quizContainer.layer.cornerRadius = Theme.cardCornerRadius
        quizContainer.translatesAutoresizingMaskIntoConstraints = false
        quizContainer.isHidden = true
        quizContainer.tag = 200
        view.addSubview(quizContainer)
        
        questionLabel = UILabel()
        questionLabel.text = "准备开始！"
        questionLabel.font = Theme.Font.bold(size: 48)
        questionLabel.textColor = Theme.brightWhite
        questionLabel.textAlignment = .center
        questionLabel.translatesAutoresizingMaskIntoConstraints = false
        quizContainer.addSubview(questionLabel)
        
        answerTextField = UITextField()
        answerTextField.placeholder = "输入答案"
        answerTextField.font = Theme.Font.bold(size: 32)
        answerTextField.textColor = Theme.brightWhite
        answerTextField.textAlignment = .center
        answerTextField.keyboardType = .numberPad
        answerTextField.backgroundColor = Theme.cardBackground.withAlphaComponent(0.8)
        answerTextField.layer.cornerRadius = 12
        answerTextField.layer.borderWidth = 2
        answerTextField.layer.borderColor = Theme.electricBlue.cgColor
        answerTextField.translatesAutoresizingMaskIntoConstraints = false
        answerTextField.delegate = self
        quizContainer.addSubview(answerTextField)
        
        let submitButton = UIButton(type: .system)
        submitButton.setTitle("提交答案", for: .normal)
        submitButton.titleLabel?.font = Theme.Font.bold(size: 18)
        submitButton.setTitleColor(Theme.brightWhite, for: .normal)
        submitButton.backgroundColor = Theme.electricBlue
        submitButton.layer.cornerRadius = 12
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        submitButton.addTarget(self, action: #selector(submitAnswer), for: .touchUpInside)
        quizContainer.addSubview(submitButton)
        
        let nextButton = UIButton(type: .system)
        nextButton.setTitle("下一题", for: .normal)
        nextButton.titleLabel?.font = Theme.Font.bold(size: 18)
        nextButton.setTitleColor(Theme.electricBlue, for: .normal)
        nextButton.backgroundColor = Theme.cardBackground.withAlphaComponent(0.8)
        nextButton.layer.cornerRadius = 12
        nextButton.layer.borderWidth = 2
        nextButton.layer.borderColor = Theme.electricBlue.cgColor
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.addTarget(self, action: #selector(nextQuestion), for: .touchUpInside)
        quizContainer.addSubview(nextButton)
        
        scoreLabel = UILabel()
        scoreLabel.text = "得分: 0 / 0"
        scoreLabel.font = Theme.Font.bold(size: 20)
        scoreLabel.textColor = Theme.neonPink
        scoreLabel.textAlignment = .center
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        quizContainer.addSubview(scoreLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            segmentControl.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            segmentControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            segmentControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            numberSlider.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 16),
            numberSlider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 60),
            numberSlider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -60),
            
            numberLabel.topAnchor.constraint(equalTo: numberSlider.bottomAnchor, constant: 8),
            numberLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            contentContainer.topAnchor.constraint(equalTo: numberLabel.bottomAnchor, constant: 16),
            contentContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            contentContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            contentContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            
            tableCollectionView.topAnchor.constraint(equalTo: contentContainer.topAnchor, constant: 16),
            tableCollectionView.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor, constant: 16),
            tableCollectionView.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor, constant: -16),
            tableCollectionView.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor, constant: -16),
            
            quizContainer.topAnchor.constraint(equalTo: numberLabel.bottomAnchor, constant: 16),
            quizContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            quizContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            quizContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            
            questionLabel.topAnchor.constraint(equalTo: quizContainer.topAnchor, constant: 40),
            questionLabel.centerXAnchor.constraint(equalTo: quizContainer.centerXAnchor),
            
            answerTextField.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 32),
            answerTextField.centerXAnchor.constraint(equalTo: quizContainer.centerXAnchor),
            answerTextField.widthAnchor.constraint(equalToConstant: 200),
            answerTextField.heightAnchor.constraint(equalToConstant: 60),
            
            submitButton.topAnchor.constraint(equalTo: answerTextField.bottomAnchor, constant: 24),
            submitButton.leadingAnchor.constraint(equalTo: quizContainer.leadingAnchor, constant: 40),
            submitButton.heightAnchor.constraint(equalToConstant: 50),
            
            nextButton.topAnchor.constraint(equalTo: answerTextField.bottomAnchor, constant: 24),
            nextButton.trailingAnchor.constraint(equalTo: quizContainer.trailingAnchor, constant: -40),
            nextButton.heightAnchor.constraint(equalToConstant: 50),
            
            submitButton.widthAnchor.constraint(equalTo: nextButton.widthAnchor),
            nextButton.leadingAnchor.constraint(equalTo: submitButton.trailingAnchor, constant: 16),
            
            scoreLabel.topAnchor.constraint(equalTo: submitButton.bottomAnchor, constant: 24),
            scoreLabel.centerXAnchor.constraint(equalTo: quizContainer.centerXAnchor)
        ])
        
        title = "加减口诀"
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.itemSize = CGSize(width: 80, height: 60)
        return layout
    }
    
    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 2 {
            isQuizMode = true
            view.viewWithTag(200)?.isHidden = false
            view.viewWithTag(200)?.superview?.bringSubviewToFront(view.viewWithTag(200)!)
            generateQuizQuestion()
        } else {
            isQuizMode = false
            view.viewWithTag(200)?.isHidden = true
            currentTableType = sender.selectedSegmentIndex == 0 ? .addition : .subtraction
            tableCollectionView.reloadData()
        }
    }
    
    @objc private func sliderChanged(_ sender: UISlider) {
        currentNumber = Int(sender.value)
        if let label = view.viewWithTag(100) as? UILabel {
            label.text = "当前数字: \(currentNumber)"
        }
        tableCollectionView.reloadData()
    }
    
    private func generateQuizQuestion() {
        let left = Int(arc4random_uniform(10)) + 1
        let right = Int(arc4random_uniform(UInt32(left))) + 1
        let isAddition = arc4random_uniform(2) == 0
        
        if isAddition {
            quizQuestion = (left, right, left + right, true)
            questionLabel.text = "\(left) + \(right) = ?"
        } else {
            let result = left - right
            quizQuestion = (left, result, right, false)
            questionLabel.text = "\(left) - ? = \(result)"
        }
        
        answerTextField.text = ""
        animateQuestion()
    }
    
    private func animateQuestion() {
        questionLabel.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        questionLabel.alpha = 0
        UIView.animate(withDuration: 0.3) {
            self.questionLabel.transform = .identity
            self.questionLabel.alpha = 1
        }
    }
    
    @objc private func submitAnswer() {
        guard let answerText = answerTextField.text, let userNum = Int(answerText) else {
            shakeView(answerTextField)
            return
        }
        
        totalQuestions += 1
        if userNum == quizQuestion?.answer {
            score += 1
            showCorrectAnimation()
            speakText("正确！")
        } else {
            showWrongAnimation()
            speakText("答案是\(quizQuestion?.answer ?? 0)")
        }
        
        scoreLabel.text = "得分: \(score) / \(totalQuestions)"
    }
    
    @objc private func nextQuestion() {
        generateQuizQuestion()
    }
    
    private func showCorrectAnimation() {
        questionLabel.textColor = UIColor(hex: "4CAF50")
        UIView.animate(withDuration: 0.2, animations: {
            self.questionLabel.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }) { _ in
            UIView.animate(withDuration: 0.2) {
                self.questionLabel.transform = .identity
                self.questionLabel.textColor = Theme.brightWhite
            }
        }
    }
    
    private func showWrongAnimation() {
        questionLabel.textColor = UIColor(hex: "F44336")
        shakeView(questionLabel)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.questionLabel.textColor = Theme.brightWhite
        }
    }
    
    private func shakeView(_ view: UIView) {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = 0.4
        animation.values = [-10, 10, -8, 8, -5, 5, 0]
        view.layer.add(animation, forKey: "shake")
    }
    
    private func speakText(_ text: String) {
        let synthesizer = AVSpeechSynthesizer()
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "zh-CN")
        utterance.rate = 0.5
        synthesizer.speak(utterance)
    }
}

extension MathTableViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MathCell", for: indexPath) as! MathCell
        let num = indexPath.item + 1
        
        let result: Int
        let displayText: String
        
        if currentTableType == .addition {
            result = currentNumber + num
            displayText = "\(currentNumber)+\(num)=\(result)"
        } else {
            let larger = max(currentNumber, num)
            let smaller = min(currentNumber, num)
            result = larger - smaller
            displayText = "\(larger)-\(smaller)=\(result)"
        }
        
        cell.configure(text: displayText, result: result)
        return cell
    }
}

extension MathTableViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        submitAnswer()
        return true
    }
}

class MathCell: UICollectionViewCell {
    private let label: UILabel = {
        let label = UILabel()
        label.font = Theme.Font.bold(size: 16)
        label.textColor = Theme.brightWhite
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = Theme.cardBackground.withAlphaComponent(0.5)
        contentView.layer.cornerRadius = 8
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = Theme.electricBlue.withAlphaComponent(0.3).cgColor
        contentView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(text: String, result: Int) {
        label.text = text
        
        let hue = CGFloat(result) / 20.0
        let color = UIColor(hue: hue, saturation: 0.6, brightness: 0.9, alpha: 1.0)
        contentView.backgroundColor = color.withAlphaComponent(0.3)
    }
}
