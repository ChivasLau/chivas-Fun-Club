import UIKit
import AVFoundation

class AlphabetViewController: UIViewController {
    
    private let letters: [(String, String, String)] = [
        ("A", "Apple", "🍎"), ("B", "Ball", "⚽"), ("C", "Cat", "🐱"), ("D", "Dog", "🐕"), ("E", "Elephant", "🐘"),
        ("F", "Fish", "🐟"), ("G", "Grape", "🍇"), ("H", "House", "🏠"), ("I", "Ice", "🍦"), ("J", "Juice", "🧃"),
        ("K", "Kite", "🪁"), ("L", "Lion", "🦁"), ("M", "Moon", "🌙"), ("N", "Nest", "🪺"), ("O", "Orange", "🍊"),
        ("P", "Pig", "🐷"), ("Q", "Queen", "👑"), ("R", "Rabbit", "🐰"), ("S", "Sun", "☀️"), ("T", "Tiger", "🐯"),
        ("U", "Umbrella", "☂️"), ("V", "Violin", "🎻"), ("W", "Watermelon", "🍉"), ("X", "Xylophone", "🎵"), ("Y", "Yak", "🦬"), ("Z", "Zebra", "🦓")
    ]
    
    private let colors: [UIColor] = [
        UIColor(hex: "FF6B6B"), UIColor(hex: "4ECDC4"), UIColor(hex: "45B7D1"), UIColor(hex: "96CEB4"),
        UIColor(hex: "FFEAA7"), UIColor(hex: "DDA0DD"), UIColor(hex: "98D8C8"), UIColor(hex: "F7DC6F"),
        UIColor(hex: "BB8FCE"), UIColor(hex: "85C1E9"), UIColor(hex: "F8B500"), UIColor(hex: "00CED1"),
        UIColor(hex: "FF69B4"), UIColor(hex: "32CD32"), UIColor(hex: "FFD700"), UIColor(hex: "FF7F50"),
        UIColor(hex: "6495ED"), UIColor(hex: "DC143C"), UIColor(hex: "00FA9A"), UIColor(hex: "FF1493"),
        UIColor(hex: "1E90FF"), UIColor(hex: "FFDAB9"), UIColor(hex: "20B2AA"), UIColor(hex: "FF6347"),
        UIColor(hex: "7B68EE"), UIColor(hex: "00BFFF")
    ]
    
    private var collectionView: UICollectionView!
    private var detailView: UIView!
    private var detailLetterLabel: UILabel!
    private var detailWordLabel: UILabel!
    private var detailEmojiLabel: UILabel!
    private var selectedLetterIndex: Int?
    
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
        titleLabel.text = "🔤 字母点读"
        titleLabel.font = Theme.Font.bold(size: 28)
        titleLabel.textColor = Theme.brightWhite
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        let tipLabel = UILabel()
        tipLabel.text = "点击字母学习发音"
        tipLabel.font = Theme.Font.regular(size: 14)
        tipLabel.textColor = Theme.mutedGray
        tipLabel.textAlignment = .center
        tipLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tipLabel)
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        let itemWidth = (view.bounds.width - 40 - 8 * 5) / 6
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(LetterCell.self, forCellWithReuseIdentifier: "LetterCell")
        view.addSubview(collectionView)
        
        detailView = UIView()
        detailView.backgroundColor = Theme.cardBackground.withAlphaComponent(0.8)
        detailView.layer.cornerRadius = Theme.cardCornerRadius
        detailView.isHidden = true
        detailView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(detailView)
        
        let tapToClose = UITapGestureRecognizer(target: self, action: #selector(hideDetail))
        detailView.addGestureRecognizer(tapToClose)
        
        detailEmojiLabel = UILabel()
        detailEmojiLabel.font = UIFont.systemFont(ofSize: 80)
        detailEmojiLabel.textAlignment = .center
        detailEmojiLabel.translatesAutoresizingMaskIntoConstraints = false
        detailView.addSubview(detailEmojiLabel)
        
        detailLetterLabel = UILabel()
        detailLetterLabel.font = UIFont.systemFont(ofSize: 72, weight: .bold)
        detailLetterLabel.textAlignment = .center
        detailLetterLabel.translatesAutoresizingMaskIntoConstraints = false
        detailView.addSubview(detailLetterLabel)
        
        detailWordLabel = UILabel()
        detailWordLabel.font = Theme.Font.bold(size: 24)
        detailWordLabel.textAlignment = .center
        detailWordLabel.translatesAutoresizingMaskIntoConstraints = false
        detailView.addSubview(detailWordLabel)
        
        let speakButton = UIButton(type: .system)
        speakButton.setTitle("🔊 再读一遍", for: .normal)
        speakButton.titleLabel?.font = Theme.Font.bold(size: 18)
        speakButton.setTitleColor(Theme.brightWhite, for: .normal)
        speakButton.backgroundColor = Theme.electricBlue
        speakButton.layer.cornerRadius = 12
        speakButton.translatesAutoresizingMaskIntoConstraints = false
        speakButton.addTarget(self, action: #selector(speakCurrentLetter), for: .touchUpInside)
        detailView.addSubview(speakButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            tipLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            tipLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            collectionView.topAnchor.constraint(equalTo: tipLabel.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            
            detailView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            detailView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            detailView.widthAnchor.constraint(equalToConstant: 280),
            detailView.heightAnchor.constraint(equalToConstant: 320),
            
            detailEmojiLabel.topAnchor.constraint(equalTo: detailView.topAnchor, constant: 20),
            detailEmojiLabel.centerXAnchor.constraint(equalTo: detailView.centerXAnchor),
            
            detailLetterLabel.topAnchor.constraint(equalTo: detailEmojiLabel.bottomAnchor, constant: 8),
            detailLetterLabel.centerXAnchor.constraint(equalTo: detailView.centerXAnchor),
            
            detailWordLabel.topAnchor.constraint(equalTo: detailLetterLabel.bottomAnchor, constant: 8),
            detailWordLabel.centerXAnchor.constraint(equalTo: detailView.centerXAnchor),
            
            speakButton.topAnchor.constraint(equalTo: detailWordLabel.bottomAnchor, constant: 24),
            speakButton.centerXAnchor.constraint(equalTo: detailView.centerXAnchor),
            speakButton.widthAnchor.constraint(equalToConstant: 160),
            speakButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        title = "字母点读"
    }
    
    @objc private func hideDetail() {
        UIView.animate(withDuration: 0.2) {
            self.detailView.alpha = 0
            self.detailView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        } completion: { _ in
            self.detailView.isHidden = true
            self.detailView.transform = .identity
        }
    }
    
    private func showDetail(at index: Int) {
        selectedLetterIndex = index
        let letter = letters[index]
        
        detailEmojiLabel.text = letter.2
        detailLetterLabel.text = letter.0
        detailLetterLabel.textColor = colors[index]
        detailWordLabel.text = letter.1
        detailWordLabel.textColor = colors[index]
        
        detailView.isHidden = false
        detailView.alpha = 0
        detailView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        UIView.animate(withDuration: 0.3) {
            self.detailView.alpha = 1
            self.detailView.transform = .identity
        }
        
        speakLetter(at: index)
    }
    
    private func speakLetter(at index: Int) {
        let letter = letters[index]
        let synthesizer = AVSpeechSynthesizer()
        let utterance = AVSpeechUtterance(string: "\(letter.0), \(letter.0) is for \(letter.1)")
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.4
        synthesizer.speak(utterance)
    }
    
    @objc private func speakCurrentLetter() {
        if let index = selectedLetterIndex {
            speakLetter(at: index)
        }
    }
}

extension AlphabetViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 26
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LetterCell", for: indexPath) as! LetterCell
        let letter = letters[indexPath.item]
        cell.configure(letter: letter.0, emoji: letter.2, color: colors[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        showDetail(at: indexPath.item)
    }
}

class LetterCell: UICollectionViewCell {
    private let letterLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 12
        contentView.addSubview(letterLabel)
        contentView.addSubview(emojiLabel)
        
        NSLayoutConstraint.activate([
            letterLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            letterLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            emojiLabel.topAnchor.constraint(equalTo: letterLabel.bottomAnchor, constant: 2),
            emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(letter: String, emoji: String, color: UIColor) {
        letterLabel.text = letter
        letterLabel.textColor = color
        emojiLabel.text = emoji
        contentView.backgroundColor = Theme.cardBackground.withAlphaComponent(0.6)
        contentView.layer.borderWidth = 2
        contentView.layer.borderColor = color.withAlphaComponent(0.5).cgColor
    }
}
