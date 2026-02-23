import UIKit
import AVFoundation

class PinyinViewController: UIViewController {
    
    private let shengmu: [(String, String)] = [
        ("b", "玻"), ("p", "坡"), ("m", "摸"), ("f", "佛"),
        ("d", "得"), ("t", "特"), ("n", "讷"), ("l", "勒"),
        ("g", "哥"), ("k", "科"), ("h", "喝"),
        ("j", "基"), ("q", "欺"), ("x", "希"),
        ("zh", "知"), ("ch", "吃"), ("sh", "诗"), ("r", "日"),
        ("z", "资"), ("c", "次"), ("s", "思"),
        ("y", "衣"), ("w", "乌")
    ]
    
    private let yunmu: [(String, String)] = [
        ("a", "啊"), ("o", "哦"), ("e", "鹅"),
        ("i", "衣"), ("u", "乌"), ("ü", "迂"),
        ("ai", "爱"), ("ei", "诶"), ("ui", "威"),
        ("ao", "熬"), ("ou", "欧"), ("iu", "优"),
        ("ie", "耶"), ("üe", "约"), ("er", "耳"),
        ("an", "安"), ("en", "恩"), ("in", "因"), ("un", "温"), ("ün", "晕"),
        ("ang", "昂"), ("eng", "鞥"), ("ing", "英"), ("ong", "轰")
    ]
    
    private let ztren: [(String, String)] = [
        ("zhi", "知"), ("chi", "吃"), ("shi", "诗"), ("ri", "日"),
        ("zi", "资"), ("ci", "次"), ("si", "思"),
        ("yi", "衣"), ("wu", "乌"), ("yu", "迂"),
        ("ye", "耶"), ("yue", "约"), ("yuan", "圆"),
        ("yin", "因"), ("yun", "云"), ("ying", "英")
    ]
    
    private var collectionView: UICollectionView!
    private var currentCategory: Int = 0
    private var selectedShengmu: String?
    private var selectedYunmu: String?
    private var comboLabel: UILabel!
    private var comboHintLabel: UILabel!
    
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
        titleLabel.text = "🔤 识拼音"
        titleLabel.font = Theme.Font.bold(size: 28)
        titleLabel.textColor = Theme.brightWhite
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        let segmentControl = UISegmentedControl(items: ["声母", "韵母", "整体认读", "拼读组合"])
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
        
        let comboContainer = UIView()
        comboContainer.backgroundColor = Theme.cardBackground.withAlphaComponent(0.8)
        comboContainer.layer.cornerRadius = 16
        comboContainer.translatesAutoresizingMaskIntoConstraints = false
        comboContainer.tag = 100
        view.addSubview(comboContainer)
        
        let comboTitleLabel = UILabel()
        comboTitleLabel.text = "拼音拼读器"
        comboTitleLabel.font = Theme.Font.bold(size: 16)
        comboTitleLabel.textColor = Theme.mutedGray
        comboTitleLabel.textAlignment = .center
        comboTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        comboContainer.addSubview(comboTitleLabel)
        
        comboLabel = UILabel()
        comboLabel.text = "点击声母和韵母组合"
        comboLabel.font = UIFont.systemFont(ofSize: 36, weight: .bold)
        comboLabel.textColor = Theme.brightWhite
        comboLabel.textAlignment = .center
        comboLabel.translatesAutoresizingMaskIntoConstraints = false
        comboContainer.addSubview(comboLabel)
        
        comboHintLabel = UILabel()
        comboHintLabel.text = ""
        comboHintLabel.font = Theme.Font.regular(size: 18)
        comboHintLabel.textColor = Theme.neonPink
        comboHintLabel.textAlignment = .center
        comboHintLabel.translatesAutoresizingMaskIntoConstraints = false
        comboContainer.addSubview(comboHintLabel)
        
        let speakComboButton = UIButton(type: .system)
        speakComboButton.setTitle("🔊 拼读", for: .normal)
        speakComboButton.titleLabel?.font = Theme.Font.bold(size: 16)
        speakComboButton.setTitleColor(Theme.brightWhite, for: .normal)
        speakComboButton.backgroundColor = Theme.electricBlue
        speakComboButton.layer.cornerRadius = 12
        speakComboButton.translatesAutoresizingMaskIntoConstraints = false
        speakComboButton.addTarget(self, action: #selector(speakCombo), for: .touchUpInside)
        comboContainer.addSubview(speakComboButton)
        
        let clearComboButton = UIButton(type: .system)
        clearComboButton.setTitle("清除", for: .normal)
        clearComboButton.titleLabel?.font = Theme.Font.bold(size: 16)
        clearComboButton.setTitleColor(Theme.brightWhite, for: .normal)
        clearComboButton.backgroundColor = Theme.neonPink
        clearComboButton.layer.cornerRadius = 12
        clearComboButton.translatesAutoresizingMaskIntoConstraints = false
        clearComboButton.addTarget(self, action: #selector(clearCombo), for: .touchUpInside)
        comboContainer.addSubview(clearComboButton)
        
        NSLayoutConstraint.activate([
            comboTitleLabel.topAnchor.constraint(equalTo: comboContainer.topAnchor, constant: 12),
            comboTitleLabel.centerXAnchor.constraint(equalTo: comboContainer.centerXAnchor),
            
            comboLabel.topAnchor.constraint(equalTo: comboTitleLabel.bottomAnchor, constant: 12),
            comboLabel.centerXAnchor.constraint(equalTo: comboContainer.centerXAnchor),
            
            comboHintLabel.topAnchor.constraint(equalTo: comboLabel.bottomAnchor, constant: 4),
            comboHintLabel.centerXAnchor.constraint(equalTo: comboContainer.centerXAnchor),
            
            speakComboButton.topAnchor.constraint(equalTo: comboHintLabel.bottomAnchor, constant: 16),
            speakComboButton.leadingAnchor.constraint(equalTo: comboContainer.leadingAnchor, constant: 20),
            speakComboButton.heightAnchor.constraint(equalToConstant: 44),
            
            clearComboButton.topAnchor.constraint(equalTo: comboHintLabel.bottomAnchor, constant: 16),
            clearComboButton.trailingAnchor.constraint(equalTo: comboContainer.trailingAnchor, constant: -20),
            clearComboButton.heightAnchor.constraint(equalToConstant: 44),
            clearComboButton.widthAnchor.constraint(equalTo: speakComboButton.widthAnchor),
            clearComboButton.leadingAnchor.constraint(equalTo: speakComboButton.trailingAnchor, constant: 16),
            clearComboButton.bottomAnchor.constraint(equalTo: comboContainer.bottomAnchor, constant: -16)
        ])
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        let itemWidth = (view.bounds.width - 40 - 8 * 5) / 6
        layout.itemSize = CGSize(width: itemWidth, height: 60)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(PinyinCell.self, forCellWithReuseIdentifier: "PinyinCell")
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            segmentControl.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            segmentControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            segmentControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            comboContainer.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 16),
            comboContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            comboContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            collectionView.topAnchor.constraint(equalTo: comboContainer.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
        
        title = "识拼音"
    }
    
    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        currentCategory = sender.selectedSegmentIndex
        selectedShengmu = nil
        selectedYunmu = nil
        updateComboLabel()
        collectionView.reloadData()
        
        let comboContainer = view.viewWithTag(100)
        comboContainer?.isHidden = currentCategory != 3
    }
    
    private func updateComboLabel() {
        if let s = selectedShengmu, let y = selectedYunmu {
            comboLabel.text = s + y
        } else if let s = selectedShengmu {
            comboLabel.text = s + "_"
        } else if let y = selectedYunmu {
            comboLabel.text = "_" + y
        } else {
            comboLabel.text = "点击声母和韵母组合"
        }
        comboHintLabel.text = ""
    }
    
    @objc private func speakCombo() {
        if let s = selectedShengmu, let y = selectedYunmu {
            let pinyin = s + y
            speakPinyin(pinyin)
            comboHintLabel.text = "拼读: \(s) - \(y) - \(pinyin)"
        } else {
            speakPinyin("请选择声母和韵母")
        }
    }
    
    @objc private func clearCombo() {
        selectedShengmu = nil
        selectedYunmu = nil
        updateComboLabel()
        collectionView.reloadData()
    }
    
    private func speakPinyin(_ text: String) {
        let synthesizer = AVSpeechSynthesizer()
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "zh-CN")
        utterance.rate = 0.4
        synthesizer.speak(utterance)
    }
    
    private func getCurrentData() -> [(String, String)] {
        switch currentCategory {
        case 0: return shengmu
        case 1: return yunmu
        case 2: return ztren
        default: return []
        }
    }
}

extension PinyinViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if currentCategory == 3 {
            return shengmu.count + yunmu.count
        }
        return getCurrentData().count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PinyinCell", for: indexPath) as! PinyinCell
        
        if currentCategory == 3 {
            if indexPath.item < shengmu.count {
                let item = shengmu[indexPath.item]
                let isSelected = selectedShengmu == item.0
                cell.configure(pinyin: item.0, hint: item.1, isSelected: isSelected, color: Theme.electricBlue)
            } else {
                let item = yunmu[indexPath.item - shengmu.count]
                let isSelected = selectedYunmu == item.0
                cell.configure(pinyin: item.0, hint: item.1, isSelected: isSelected, color: Theme.neonPink)
            }
        } else {
            let item = getCurrentData()[indexPath.item]
            let color: UIColor
            switch currentCategory {
            case 0: color = Theme.electricBlue
            case 1: color = Theme.neonPink
            default: color = UIColor(hex: "4CAF50")
            }
            cell.configure(pinyin: item.0, hint: item.1, isSelected: false, color: color)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if currentCategory == 3 {
            if indexPath.item < shengmu.count {
                let item = shengmu[indexPath.item]
                selectedShengmu = item.0
                speakPinyin(item.0)
            } else {
                let item = yunmu[indexPath.item - shengmu.count]
                selectedYunmu = item.0
                speakPinyin(item.0)
            }
            updateComboLabel()
            collectionView.reloadData()
        } else {
            let item = getCurrentData()[indexPath.item]
            speakPinyin(item.0)
            
            if let cell = collectionView.cellForItem(at: indexPath) as? PinyinCell {
                cell.animateTap()
            }
        }
    }
}

class PinyinCell: UICollectionViewCell {
    private let pinyinLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let hintLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 12
        contentView.addSubview(pinyinLabel)
        contentView.addSubview(hintLabel)
        
        NSLayoutConstraint.activate([
            pinyinLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            pinyinLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            hintLabel.topAnchor.constraint(equalTo: pinyinLabel.bottomAnchor, constant: 2),
            hintLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(pinyin: String, hint: String, isSelected: Bool, color: UIColor) {
        pinyinLabel.text = pinyin
        pinyinLabel.textColor = isSelected ? .white : color
        hintLabel.text = hint
        hintLabel.textColor = color.withAlphaComponent(0.7)
        
        contentView.backgroundColor = isSelected ? color : Theme.cardBackground.withAlphaComponent(0.6)
        contentView.layer.borderWidth = isSelected ? 0 : 2
        contentView.layer.borderColor = color.withAlphaComponent(0.5).cgColor
    }
    
    func animateTap() {
        UIView.animate(withDuration: 0.1, animations: {
            self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.transform = .identity
            }
        }
    }
}
