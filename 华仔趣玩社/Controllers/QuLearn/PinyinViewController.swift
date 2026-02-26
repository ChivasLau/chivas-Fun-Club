import UIKit
import AVFoundation

enum PinyinType: String, CaseIterable {
    case initial = "声母"
    case final = "韵母"
    case wholeSyllable = "整体认读音节"
}

struct PinyinItem {
    let type: PinyinType
    let pinyin: String
    let phonetic: String
    let tip: String
    let tones: [String]
}

class PinyinViewController: UIViewController {
    
    private let shengmu: [PinyinItem] = [
        PinyinItem(type: .initial, pinyin: "b", phonetic: "[p]", tip: "嘴巴闭紧，轻读", tones: []),
        PinyinItem(type: .initial, pinyin: "p", phonetic: "[pʰ]", tip: "嘴巴闭紧，用力送气", tones: []),
        PinyinItem(type: .initial, pinyin: "m", phonetic: "[m]", tip: "嘴巴闭紧，用鼻音", tones: []),
        PinyinItem(type: .initial, pinyin: "f", phonetic: "[f]", tip: "牙齿碰嘴唇，轻读", tones: []),
        PinyinItem(type: .initial, pinyin: "d", phonetic: "[t]", tip: "舌尖抵住上颚", tones: []),
        PinyinItem(type: .initial, pinyin: "t", phonetic: "[tʰ]", tip: "舌尖抵住，用力送气", tones: []),
        PinyinItem(type: .initial, pinyin: "n", phonetic: "[n]", tip: "舌尖抵住，用鼻音", tones: []),
        PinyinItem(type: .initial, pinyin: "l", phonetic: "[l]", tip: "舌尖抵住，发音时气流从舌头两边流出", tones: []),
        PinyinItem(type: .initial, pinyin: "g", phonetic: "[k]", tip: "舌根抵住软腭", tones: []),
        PinyinItem(type: .initial, pinyin: "k", phonetic: "[kʰ]", tip: "舌根抵住，用力送气", tones: []),
        PinyinItem(type: .initial, pinyin: "h", phonetic: "[x]", tip: "舌根接近软腭，发音时气流从缝隙中挤出", tones: []),
        PinyinItem(type: .initial, pinyin: "j", phonetic: "[tɕ]", tip: "舌面前部抵住硬腭前部", tones: []),
        PinyinItem(type: .initial, pinyin: "q", phonetic: "[tɕʰ]", tip: "舌面前部抵住，用力送气", tones: []),
        PinyinItem(type: .initial, pinyin: "x", phonetic: "[ɕ]", tip: "舌面前部接近硬腭，发音时气流从缝隙中挤出", tones: []),
        PinyinItem(type: .initial, pinyin: "zh", phonetic: "[ʈʂ]", tip: "舌尖翘起，抵住硬腭前部", tones: []),
        PinyinItem(type: .initial, pinyin: "ch", phonetic: "[ʈʂʰ]", tip: "舌尖翘起，用力送气", tones: []),
        PinyinItem(type: .initial, pinyin: "sh", phonetic: "[ʂ]", tip: "舌尖翘起，接近硬腭", tones: []),
        PinyinItem(type: .initial, pinyin: "r", phonetic: "[ɻ]", tip: "舌尖翘起，接近硬腭，发音时声带振动", tones: []),
        PinyinItem(type: .initial, pinyin: "z", phonetic: "[ts]", tip: "舌尖抵住齿背", tones: []),
        PinyinItem(type: .initial, pinyin: "c", phonetic: "[tsʰ]", tip: "舌尖抵住齿背，用力送气", tones: []),
        PinyinItem(type: .initial, pinyin: "s", phonetic: "[s]", tip: "舌尖接近齿背", tones: []),
        PinyinItem(type: .initial, pinyin: "y", phonetic: "[j]", tip: "舌面前部接近硬腭", tones: []),
        PinyinItem(type: .initial, pinyin: "w", phonetic: "[w]", tip: "嘴唇撅起，发音时声带振动", tones: [])
    ]
    
    private let yunmu: [PinyinItem] = [
        PinyinItem(type: .final, pinyin: "a", phonetic: "[a]", tip: "嘴巴张大，舌头放平", tones: ["ā", "á", "ǎ", "à"]),
        PinyinItem(type: .final, pinyin: "o", phonetic: "[o]", tip: "嘴唇撅起，舌头缩后", tones: ["ō", "ó", "ǒ", "ò"]),
        PinyinItem(type: .final, pinyin: "e", phonetic: "[ɤ]", tip: "嘴巴扁扁，舌头放平", tones: ["ē", "é", "ě", "è"]),
        PinyinItem(type: .final, pinyin: "i", phonetic: "[i]", tip: "嘴巴扁扁，舌尖向前", tones: ["ī", "í", "ǐ", "ì"]),
        PinyinItem(type: .final, pinyin: "u", phonetic: "[u]", tip: "嘴唇撅起，舌头缩后", tones: ["ū", "ú", "ǔ", "ù"]),
        PinyinItem(type: .final, pinyin: "ü", phonetic: "[y]", tip: "嘴唇撅起成圆形，舌尖向前", tones: ["ǖ", "ǘ", "ǚ", "ǜ"]),
        PinyinItem(type: .final, pinyin: "ai", phonetic: "[ai]", tip: "先发a，再向i滑动", tones: ["āi", "ái", "ǎi", "ài"]),
        PinyinItem(type: .final, pinyin: "ei", phonetic: "[ei]", tip: "先发e，再向i滑动", tones: ["ēi", "éi", "ěi", "èi"]),
        PinyinItem(type: .final, pinyin: "ui", phonetic: "[uei]", tip: "先发u，再向i滑动", tones: ["uī", "uí", "uǐ", "uì"]),
        PinyinItem(type: .final, pinyin: "ao", phonetic: "[au]", tip: "先发a，再向o滑动", tones: ["āo", "áo", "ǎo", "ào"]),
        PinyinItem(type: .final, pinyin: "ou", phonetic: "[ou]", tip: "先发o，再向u滑动", tones: ["ōu", "óu", "ǒu", "òu"]),
        PinyinItem(type: .final, pinyin: "iu", phonetic: "[iou]", tip: "先发i，再向u滑动", tones: ["iū", "iú", "iǔ", "iù"]),
        PinyinItem(type: .final, pinyin: "ie", phonetic: "[ie]", tip: "先发i，再向e滑动", tones: ["iē", "ié", "iě", "iè"]),
        PinyinItem(type: .final, pinyin: "üe", phonetic: "[ye]", tip: "先发ü，再向e滑动", tones: ["üē", "üé", "üě", "üè"]),
        PinyinItem(type: .final, pinyin: "er", phonetic: "[ɚ]", tip: "舌头向后卷，发音时声带振动", tones: ["ēr", "ér", "ěr", "èr"]),
        PinyinItem(type: .final, pinyin: "an", phonetic: "[an]", tip: "先发a，再用鼻音收尾", tones: ["ān", "án", "ǎn", "àn"]),
        PinyinItem(type: .final, pinyin: "en", phonetic: "[ən]", tip: "先发e，再用鼻音收尾", tones: ["ēn", "én", "ěn", "èn"]),
        PinyinItem(type: .final, pinyin: "in", phonetic: "[in]", tip: "先发i，再用鼻音收尾", tones: ["īn", "ín", "ǐn", "ìn"]),
        PinyinItem(type: .final, pinyin: "un", phonetic: "[uən]", tip: "先发u，再用鼻音收尾", tones: ["ūn", "ún", "ǔn", "ùn"]),
        PinyinItem(type: .final, pinyin: "ün", phonetic: "[yn]", tip: "先发ü，再用鼻音收尾", tones: ["ǖn", "ǘn", "ǚn", "ǜn"]),
        PinyinItem(type: .final, pinyin: "ang", phonetic: "[ɑŋ]", tip: "先发a，舌根抬起，用鼻音收尾", tones: ["āng", "áng", "ǎng", "àng"]),
        PinyinItem(type: .final, pinyin: "eng", phonetic: "[ɤŋ]", tip: "先发e，舌根抬起，用鼻音收尾", tones: ["ēng", "éng", "ěng", "èng"]),
        PinyinItem(type: .final, pinyin: "ing", phonetic: "[iŋ]", tip: "先发i，舌根抬起，用鼻音收尾", tones: ["īng", "íng", "ǐng", "ìng"]),
        PinyinItem(type: .final, pinyin: "ong", phonetic: "[ʊŋ]", tip: "先发o，舌根抬起，用鼻音收尾", tones: ["ōng", "óng", "ǒng", "òng"])
    ]
    
    private let ztren: [PinyinItem] = [
        PinyinItem(type: .wholeSyllable, pinyin: "zhi", phonetic: "[ʈʂʅ]", tip: "整体认读，发音时舌头翘起", tones: ["zhī", "zhí", "zhǐ", "zhì"]),
        PinyinItem(type: .wholeSyllable, pinyin: "chi", phonetic: "[ʈʂʰʅ]", tip: "整体认读，用力送气", tones: ["chī", "chí", "chǐ", "chì"]),
        PinyinItem(type: .wholeSyllable, pinyin: "shi", phonetic: "[ʂʅ]", tip: "整体认读，翘舌音", tones: ["shī", "shí", "shǐ", "shì"]),
        PinyinItem(type: .wholeSyllable, pinyin: "ri", phonetic: "[ɻʅ]", tip: "整体认读，发音时声带振动", tones: ["rī", "rí", "rǐ", "rì"]),
        PinyinItem(type: .wholeSyllable, pinyin: "zi", phonetic: "[tsɿ]", tip: "整体认读，舌尖抵住齿背", tones: ["zī", "zí", "zǐ", "zì"]),
        PinyinItem(type: .wholeSyllable, pinyin: "ci", phonetic: "[tsʰɿ]", tip: "整体认读，用力送气", tones: ["cī", "cí", "cǐ", "cì"]),
        PinyinItem(type: .wholeSyllable, pinyin: "si", phonetic: "[sɿ]", tip: "整体认读，舌尖接近齿背", tones: ["sī", "sí", "sǐ", "sì"]),
        PinyinItem(type: .wholeSyllable, pinyin: "yi", phonetic: "[i]", tip: "整体认读，发音同i", tones: ["yī", "yí", "yǐ", "yì"]),
        PinyinItem(type: .wholeSyllable, pinyin: "wu", phonetic: "[u]", tip: "整体认读，发音同u", tones: ["wū", "wú", "wǔ", "wù"]),
        PinyinItem(type: .wholeSyllable, pinyin: "yu", phonetic: "[y]", tip: "整体认读，发音同ü", tones: ["yū", "yú", "yǔ", "yù"]),
        PinyinItem(type: .wholeSyllable, pinyin: "ye", phonetic: "[ie]", tip: "整体认读，发音同ie", tones: ["yē", "yé", "yě", "yè"]),
        PinyinItem(type: .wholeSyllable, pinyin: "yue", phonetic: "[ye]", tip: "整体认读，先发ü再发e", tones: ["yuē", "yué", "yuě", "yuè"]),
        PinyinItem(type: .wholeSyllable, pinyin: "yuan", phonetic: "[ɥɛn]", tip: "整体认读，发音同ü+an", tones: ["yuān", "yuán", "yuǎn", "yuàn"]),
        PinyinItem(type: .wholeSyllable, pinyin: "yin", phonetic: "[in]", tip: "整体认读，发音同in", tones: ["yīn", "yín", "yǐn", "yìn"]),
        PinyinItem(type: .wholeSyllable, pinyin: "yun", phonetic: "[yn]", tip: "整体认读，发音同ün", tones: ["yūn", "yún", "yǔn", "yùn"]),
        PinyinItem(type: .wholeSyllable, pinyin: "ying", phonetic: "[iŋ]", tip: "整体认读，发音同ing", tones: ["yīng", "yíng", "yǐng", "yìng"])
    ]
    
    private var collectionView: UICollectionView!
    private var currentCategory: Int = 0
    private var selectedShengmu: PinyinItem?
    private var selectedYunmu: PinyinItem?
    private var comboLabel: UILabel!
    private var comboHintLabel: UILabel!
    private var tipLabel: UILabel!
    private var phoneticLabel: UILabel!
    
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
        
        let infoContainer = UIView()
        infoContainer.backgroundColor = Theme.cardBackground.withAlphaComponent(0.6)
        infoContainer.layer.cornerRadius = 12
        infoContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(infoContainer)
        
        phoneticLabel = UILabel()
        phoneticLabel.font = UIFont.systemFont(ofSize: 16)
        phoneticLabel.textColor = Theme.electricBlue
        phoneticLabel.textAlignment = .center
        phoneticLabel.translatesAutoresizingMaskIntoConstraints = false
        infoContainer.addSubview(phoneticLabel)
        
        tipLabel = UILabel()
        tipLabel.font = Theme.Font.regular(size: 14)
        tipLabel.textColor = Theme.mutedGray
        tipLabel.textAlignment = .center
        tipLabel.numberOfLines = 2
        tipLabel.translatesAutoresizingMaskIntoConstraints = false
        infoContainer.addSubview(tipLabel)
        
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
        comboHintLabel.font = Theme.Font.regular(size: 14)
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
            phoneticLabel.topAnchor.constraint(equalTo: infoContainer.topAnchor, constant: 8),
            phoneticLabel.centerXAnchor.constraint(equalTo: infoContainer.centerXAnchor),
            
            tipLabel.topAnchor.constraint(equalTo: phoneticLabel.bottomAnchor, constant: 4),
            tipLabel.leadingAnchor.constraint(equalTo: infoContainer.leadingAnchor, constant: 12),
            tipLabel.trailingAnchor.constraint(equalTo: infoContainer.trailingAnchor, constant: -12),
            tipLabel.bottomAnchor.constraint(equalTo: infoContainer.bottomAnchor, constant: -8),
            
            comboTitleLabel.topAnchor.constraint(equalTo: comboContainer.topAnchor, constant: 12),
            comboTitleLabel.centerXAnchor.constraint(equalTo: comboContainer.centerXAnchor),
            
            comboLabel.topAnchor.constraint(equalTo: comboTitleLabel.bottomAnchor, constant: 8),
            comboLabel.centerXAnchor.constraint(equalTo: comboContainer.centerXAnchor),
            
            comboHintLabel.topAnchor.constraint(equalTo: comboLabel.bottomAnchor, constant: 4),
            comboHintLabel.centerXAnchor.constraint(equalTo: comboContainer.centerXAnchor),
            
            speakComboButton.topAnchor.constraint(equalTo: comboHintLabel.bottomAnchor, constant: 12),
            speakComboButton.leadingAnchor.constraint(equalTo: comboContainer.leadingAnchor, constant: 20),
            speakComboButton.heightAnchor.constraint(equalToConstant: 40),
            
            clearComboButton.topAnchor.constraint(equalTo: comboHintLabel.bottomAnchor, constant: 12),
            clearComboButton.trailingAnchor.constraint(equalTo: comboContainer.trailingAnchor, constant: -20),
            clearComboButton.heightAnchor.constraint(equalToConstant: 40),
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
            
            infoContainer.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 12),
            infoContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            infoContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            comboContainer.topAnchor.constraint(equalTo: infoContainer.bottomAnchor, constant: 12),
            comboContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            comboContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            collectionView.topAnchor.constraint(equalTo: comboContainer.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
        
        title = "识拼音"
        updateInfoLabel(nil)
    }
    
    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        currentCategory = sender.selectedSegmentIndex
        selectedShengmu = nil
        selectedYunmu = nil
        updateComboLabel()
        collectionView.reloadData()
        
        let comboContainer = view.viewWithTag(100)
        comboContainer?.isHidden = currentCategory != 3
        updateInfoLabel(nil)
    }
    
    private func updateComboLabel() {
        if let s = selectedShengmu, let y = selectedYunmu {
            comboLabel.text = s.pinyin + y.pinyin
        } else if let s = selectedShengmu {
            comboLabel.text = s.pinyin + "_"
        } else if let y = selectedYunmu {
            comboLabel.text = "_" + y.pinyin
        } else {
            comboLabel.text = "点击声母和韵母组合"
        }
        comboHintLabel.text = ""
    }
    
    private func updateInfoLabel(_ item: PinyinItem?) {
        if let item = item {
            phoneticLabel.text = item.phonetic
            tipLabel.text = item.tip
        } else {
            phoneticLabel.text = "点击拼音查看发音提示"
            tipLabel.text = ""
        }
    }
    
    @objc private func speakCombo() {
        if let s = selectedShengmu, let y = selectedYunmu {
            let pinyin = s.pinyin + y.pinyin
            speakPinyin(pinyin)
            comboHintLabel.text = "拼读: \(s.pinyin) + \(y.pinyin) = \(pinyin)"
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
        utterance.pitchMultiplier = 1.1
        synthesizer.speak(utterance)
    }
    
    private func getCurrentData() -> [PinyinItem] {
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
                let isSelected = selectedShengmu?.pinyin == item.pinyin
                cell.configure(item: item, isSelected: isSelected, color: Theme.electricBlue)
            } else {
                let item = yunmu[indexPath.item - shengmu.count]
                let isSelected = selectedYunmu?.pinyin == item.pinyin
                cell.configure(item: item, isSelected: isSelected, color: Theme.neonPink)
            }
        } else {
            let item = getCurrentData()[indexPath.item]
            let color: UIColor
            switch currentCategory {
            case 0: color = Theme.electricBlue
            case 1: color = Theme.neonPink
            default: color = UIColor(hex: "4CAF50")
            }
            cell.configure(item: item, isSelected: false, color: color)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if currentCategory == 3 {
            if indexPath.item < shengmu.count {
                let item = shengmu[indexPath.item]
                selectedShengmu = item
                speakPinyin(item.pinyin)
                updateInfoLabel(item)
            } else {
                let item = yunmu[indexPath.item - shengmu.count]
                selectedYunmu = item
                speakPinyin(item.pinyin)
                updateInfoLabel(item)
            }
            updateComboLabel()
            collectionView.reloadData()
        } else {
            let item = getCurrentData()[indexPath.item]
            speakPinyin(item.pinyin)
            updateInfoLabel(item)
            
            if let cell = collectionView.cellForItem(at: indexPath) as? PinyinCell {
                cell.animateTap()
            }
        }
    }
}

class PinyinCell: UICollectionViewCell {
    private let pinyinLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let tipLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 9)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 12
        contentView.addSubview(pinyinLabel)
        contentView.addSubview(tipLabel)
        
        NSLayoutConstraint.activate([
            pinyinLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            pinyinLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            tipLabel.topAnchor.constraint(equalTo: pinyinLabel.bottomAnchor, constant: 2),
            tipLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 2),
            tipLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -2)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(item: PinyinItem, isSelected: Bool, color: UIColor) {
        pinyinLabel.text = item.pinyin
        pinyinLabel.textColor = isSelected ? .white : color
        
        if item.type == .initial {
            tipLabel.text = "声母"
        } else if item.type == .final {
            if !item.tones.isEmpty {
                tipLabel.text = item.tones.first
            } else {
                tipLabel.text = "韵母"
            }
        } else {
            tipLabel.text = "整体"
        }
        tipLabel.textColor = color.withAlphaComponent(0.7)
        
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
