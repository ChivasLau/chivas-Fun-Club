import UIKit
import Photos

enum PosterMode: String, CaseIterable {
    case kid = "幼儿模式"
    case normal = "普通模式"
}

enum KidPosterScene: String, CaseIterable {
    case award = "成长奖状"
    case daily = "每日打卡"
    case holiday = "节日祝福"
    case birthday = "生日纪念"
    case welcome = "入园通知"
    case handmade = "亲子手工"
    
    var icon: String {
        switch self {
        case .award: return "🏆"
        case .daily: return "📅"
        case .holiday: return "🎉"
        case .birthday: return "🎂"
        case .welcome: return "🏫"
        case .handmade: return "✂️"
        }
    }
    
    var backgroundColor: UIColor {
        switch self {
        case .award: return UIColor(hex: "FFE4B5")
        case .daily: return UIColor(hex: "E0F7FA")
        case .holiday: return UIColor(hex: "FFF0F5")
        case .birthday: return UIColor(hex: "FCE4EC")
        case .welcome: return UIColor(hex: "E8F5E9")
        case .handmade: return UIColor(hex: "FFF8E1")
        }
    }
    
    var defaultText: String {
        switch self {
        case .award: return "XX小朋友真棒！"
        case .daily: return "今日打卡完成"
        case .holiday: return "节日快乐！"
        case .birthday: return "生日快乐！"
        case .welcome: return "欢迎小朋友！"
        case .handmade: return "亲子时光"
        }
    }
}

enum KidStickerCategory: String, CaseIterable {
    case fruit = "水果"
    case animal = "动物"
    case number = "数字"
    case pinyin = "拼音"
    case holiday = "节日"
    case reward = "奖励"
    
    var icons: [String] {
        switch self {
        case .fruit: return ["🍎", "🍊", "🍋", "🍇", "🍓", "🍑", "🍒", "🥝", "🍌", "🍉"]
        case .animal: return ["🐱", "🐶", "🐰", "🐻", "🦊", "🐼", "🐨", "🦁", "🐸", "🐵"]
        case .number: return ["1️⃣", "2️⃣", "3️⃣", "4️⃣", "5️⃣", "6️⃣", "7️⃣", "8️⃣", "9️⃣", "🔟"]
        case .pinyin: return ["ㄅ", "ㄆ", "ㄇ", "ㄈ", "ㄉ", "ㄊ", "ㄋ", "ㄌ", "ㄍ", "ㄎ"]
        case .holiday: return ["🎈", "🎁", "🎀", "🌈", "⭐", "🌸", "🌺", "🍰", "🎂", "🎉"]
        case .reward: return ["🌟", "🏆", "🎖️", "👍", "💖", "❤️", "💯", "🎵", "🎶", "💫"]
        }
    }
}

enum KidTextPreset: String, CaseIterable {
    case great = "XX小朋友真棒！"
    case done = "每日打卡完成"
    case happy = "生日快乐！"
    case holiday = "节日快乐！"
    case welcome = "欢迎小朋友！"
    case good = "你真厉害！"
    case love = "我爱你！"
    case goodJob = "做得好！"
}

enum PosterBrushType: String, CaseIterable {
    case normal = "普通笔"
    case marker = "马克笔"
    case highlighter = "荧光笔"
    case crayon = "蜡笔"
    case watercolor = "水彩笔"
    case brush = "毛笔"
    case rainbow = "彩虹笔"
    case glitter = "闪光笔"
    case star = "星星笔"
}

enum MaterialCategory: String, CaseIterable {
    case animal = "动物"
    case fruit = "水果"
    case border = "边框"
    case background = "背景"
    case cartoon = "卡通"
    case stars = "星星"
    case flower = "花朵"
    case emoji = "表情"
    
    var icons: [String] {
        switch self {
        case .animal: return ["🐱", "🐶", "🐰", "🐻", "🦊", "🐼", "🐨", "🦁", "🐸", "🐵", "🦋", "🐠", "🐢", "🦆", "🐕"]
        case .fruit: return ["🍎", "🍊", "🍋", "🍇", "🍓", "🍑", "🍒", "🥝", "🍌", "🍉", "🥭", "🍍", "🥥", "🥑", "🍆"]
        case .border: return ["⬜", "▫️", "🟦", "🟧", "🟪", "🟩", "❤️", "💙", "💚", "🖤", "🤍", "💜"]
        case .background: return ["🌈", "☁️", "🌸", "🌺", "🍀", "⭐", "🌙", "☀️", "🌊", "🔥", "❄️", "🍂"]
        case .cartoon: return ["🎈", "🎁", "🎀", "🎗️", "🎟️", "🎫", "🎪", "🎨", "🎭", "🎬", "🎤", "🎧", "🎼", "🎹", "🥁"]
        case .stars: return ["⭐", "🌟", "💫", "✨", "🌠", "🌌", "🪐", "🌙", "☀️", "🌤️", "⛅", "🌈", "☁️", "💧", "🔥"]
        case .flower: return ["🌸", "🌺", "🌻", "🌼", "💐", "🌹", "🥀", "🌷", "🌱", "🍀", "🌿", "☘️", "🍃", "🍂", "🍁"]
        case .emoji: return ["😀", "😍", "🤩", "😎", "🤗", "🥳", "😇", "🤠", "😺", "🐶", "🦊", "🐰", "🐻", "🐼", "🐨"]
        }
    }
}

enum KidColor: String, CaseIterable {
    case red = "红色"
    case yellow = "黄色"
    case blue = "蓝色"
    case pink = "粉色"
    case green = "绿色"
    case orange = "橙色"
    case purple = "紫色"
    case white = "白色"
    
    var color: UIColor {
        switch self {
        case .red: return UIColor(hex: "FF6B6B")
        case .yellow: return UIColor(hex: "FFD93D")
        case .blue: return UIColor(hex: "4ECDC4")
        case .pink: return UIColor(hex: "FF6B9D")
        case .green: return UIColor(hex: "6BCB77")
        case .orange: return UIColor(hex: "FF9F43")
        case .purple: return UIColor(hex: "A55EEA")
        case .white: return .white
        }
    }
    
    var emoji: String {
        switch self {
        case .red: return "🔴"
        case .yellow: return "🟡"
        case .blue: return "🔵"
        case .pink: return "💗"
        case .green: return "🟢"
        case .orange: return "🟠"
        case .purple: return "🟣"
        case .white: return "⚪"
        }
    }
}

enum CanvasSize: Int {
    case custom = 0
    case a4 = 1
    case a5 = 2
    case square = 3
    case instagram = 4
    
    var name: String {
        switch self {
        case .custom: return "自定义"
        case .a4: return "A4纸"
        case .a5: return "A5纸"
        case .square: return "正方形"
        case .instagram: return "Instagram"
        }
    }
    
    var size: CGSize {
        switch self {
        case .custom: return CGSize(width: 800, height: 1200)
        case .a4: return CGSize(width: 794, height: 1123)
        case .a5: return CGSize(width: 559, height: 794)
        case .square: return CGSize(width: 800, height: 800)
        case .instagram: return CGSize(width: 1080, height: 1080)
        }
    }
}

class PosterElement: NSObject {
    var image: UIImage?
    var text: String?
    var frame: CGRect = .zero
    var rotation: CGFloat = 0
    var scale: CGFloat = 1.0
    var type: ElementType = .image
    var textColor: UIColor = .black
    var fontSize: CGFloat = 32
    
    enum ElementType {
        case image
        case text
        case shape
    }
}

class PosterModeViewController: UIViewController {
    
    private var modeSelectionView: UIView!
    private var editorView: UIView!
    private var currentMode: PosterMode = .kid
    
    private var kidScene: KidPosterScene?
    
    private var canvasScrollView: UIScrollView!
    private var canvasContainer: UIView!
    private var canvasView: UIView!
    private var drawingImageView: UIImageView!
    private var elementContainerView: UIView!
    
    private var kidToolBar: UIView!
    private var normalToolBar: UIView!
    
    private var currentCanvasSize: CanvasSize = .a4
    private var currentColor: UIColor = .black
    private var currentBrushSize: CGFloat = 4.0
    private var isEraser = false
    
    private var elements: [PosterElement] = []
    private var selectedElementView: UIView?
    
    private var importManager: ImageImportManager?
    private var currentPath: UIBezierPath?
    private var drawingLayer: CAShapeLayer?
    
    private var materialSidebar: UIView?
    private var brushPanel: UIView?
    private var isSidebarVisible = false
    private var isBrushPanelVisible = false
    
    private var undoStack: [UIImage] = []
    private var redoStack: [UIImage] = []
    private var currentBrushType: PosterBrushType = .normal
    
    private var undoBtn: UIButton?
    private var redoBtn: UIButton?
    
    private let colors: [UIColor] = [
        .black, .white, .red, .orange, .yellow, .green, .cyan, .blue, .purple, .brown,
        UIColor(hex: "FF6B6B"), UIColor(hex: "4ECDC4"), UIColor(hex: "45B7D1"), UIColor(hex: "96CEB4"),
        UIColor(hex: "FFEAA7"), UIColor(hex: "DDA0DD"), UIColor(hex: "F368E0")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupModeSelection()
        importManager = ImageImportManager(vc: self)
    }
    
    override var prefersStatusBarHidden: Bool { return true }
    override var prefersHomeIndicatorAutoHidden: Bool { return false }
    
    private func setupModeSelection() {
        view.backgroundColor = UIColor(hex: "1a1a2e")
        
        modeSelectionView = UIView()
        modeSelectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(modeSelectionView)
        
        NSLayoutConstraint.activate([
            modeSelectionView.topAnchor.constraint(equalTo: view.topAnchor),
            modeSelectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            modeSelectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            modeSelectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        let titleLabel = UILabel()
        titleLabel.text = "🎨 海报设计"
        titleLabel.font = Theme.Font.bold(size: 32)
        titleLabel.textColor = Theme.brightWhite
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        modeSelectionView.addSubview(titleLabel)
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = "选择你喜欢的模式开始制作"
        subtitleLabel.font = Theme.Font.regular(size: 18)
        subtitleLabel.textColor = Theme.mutedGray
        subtitleLabel.textAlignment = .center
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        modeSelectionView.addSubview(subtitleLabel)
        
        let modeStack = UIStackView()
        modeStack.axis = .vertical
        modeStack.spacing = 20
        modeStack.translatesAutoresizingMaskIntoConstraints = false
        modeSelectionView.addSubview(modeStack)
        
        let kidButton = createModeButton(
            title: "👶 幼儿模式",
            subtitle: "3-6岁专属 · 简单有趣",
            color: UIColor(hex: "FF6B6B"),
            tag: 1
        )
        kidButton.addTarget(self, action: #selector(kidModeTapped), for: .touchUpInside)
        modeStack.addArrangedSubview(kidButton)
        
        let normalButton = createModeButton(
            title: "📝 普通模式",
            subtitle: "功能丰富 · 自由创作",
            color: UIColor(hex: "4ECDC4"),
            tag: 2
        )
        normalButton.addTarget(self, action: #selector(normalModeTapped), for: .touchUpInside)
        modeStack.addArrangedSubview(normalButton)
        
        let draftButton = UIButton(type: .system)
        draftButton.setTitle("📁 我的草稿", for: .normal)
        draftButton.titleLabel?.font = Theme.Font.bold(size: 18)
        draftButton.setTitleColor(Theme.electricBlue, for: .normal)
        draftButton.translatesAutoresizingMaskIntoConstraints = false
        modeSelectionView.addSubview(draftButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: modeSelectionView.safeAreaLayoutGuide.topAnchor, constant: 40),
            titleLabel.centerXAnchor.constraint(equalTo: modeSelectionView.centerXAnchor),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            subtitleLabel.centerXAnchor.constraint(equalTo: modeSelectionView.centerXAnchor),
            
            modeStack.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 40),
            modeStack.leadingAnchor.constraint(equalTo: modeSelectionView.leadingAnchor, constant: 40),
            modeStack.trailingAnchor.constraint(equalTo: modeSelectionView.trailingAnchor, constant: -40),
            
            draftButton.topAnchor.constraint(equalTo: modeStack.bottomAnchor, constant: 40),
            draftButton.centerXAnchor.constraint(equalTo: modeSelectionView.centerXAnchor)
        ])
    }
    
    private func createModeButton(title: String, subtitle: String, color: UIColor, tag: Int) -> UIButton {
        let button = UIButton(type: .system)
        button.backgroundColor = color.withAlphaComponent(0.2)
        button.layer.cornerRadius = 20
        button.layer.borderWidth = 3
        button.layer.borderColor = color.cgColor
        button.tag = tag
        button.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = Theme.Font.bold(size: 24)
        titleLabel.textColor = color
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        button.addSubview(titleLabel)
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.font = Theme.Font.regular(size: 14)
        subtitleLabel.textColor = Theme.mutedGray
        subtitleLabel.textAlignment = .center
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        button.addSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 100),
            titleLabel.topAnchor.constraint(equalTo: button.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.centerXAnchor.constraint(equalTo: button.centerXAnchor)
        ])
        
        return button
    }
    
    @objc private func kidModeTapped() {
        currentMode = .kid
        showKidTemplateSelection()
    }
    
    @objc private func normalModeTapped() {
        currentMode = .normal
        showNormalEditor()
    }
    
    private func showKidTemplateSelection() {
        for subview in modeSelectionView.subviews {
            subview.removeFromSuperview()
        }
        
        let backButton = UIButton(type: .system)
        backButton.setTitle("‹ 返回", for: .normal)
        backButton.titleLabel?.font = Theme.Font.bold(size: 18)
        backButton.setTitleColor(Theme.electricBlue, for: .normal)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.addTarget(self, action: #selector(backToModeSelection), for: .touchUpInside)
        modeSelectionView.addSubview(backButton)
        
        let titleLabel = UILabel()
        titleLabel.text = "👶 幼儿模式"
        titleLabel.font = Theme.Font.bold(size: 28)
        titleLabel.textColor = Theme.brightWhite
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        modeSelectionView.addSubview(titleLabel)
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = "选择一个模板开始制作"
        subtitleLabel.font = Theme.Font.regular(size: 16)
        subtitleLabel.textColor = Theme.mutedGray
        subtitleLabel.textAlignment = .center
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        modeSelectionView.addSubview(subtitleLabel)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(KidTemplateCell.self, forCellWithReuseIdentifier: "KidTemplateCell")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.tag = 300
        modeSelectionView.addSubview(collectionView)
        
        let blankButton = UIButton(type: .system)
        blankButton.setTitle("➕ 新建空白海报", for: .normal)
        blankButton.titleLabel?.font = Theme.Font.bold(size: 20)
        blankButton.setTitleColor(Theme.brightWhite, for: .normal)
        blankButton.backgroundColor = Theme.neonPink
        blankButton.layer.cornerRadius = 25
        blankButton.translatesAutoresizingMaskIntoConstraints = false
        blankButton.addTarget(self, action: #selector(createBlankKidPoster), for: .touchUpInside)
        modeSelectionView.addSubview(blankButton)
        
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: modeSelectionView.safeAreaLayoutGuide.topAnchor, constant: 16),
            backButton.leadingAnchor.constraint(equalTo: modeSelectionView.leadingAnchor, constant: 16),
            
            titleLabel.topAnchor.constraint(equalTo: modeSelectionView.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: modeSelectionView.centerXAnchor),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.centerXAnchor.constraint(equalTo: modeSelectionView.centerXAnchor),
            
            collectionView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: modeSelectionView.leadingAnchor, constant: 20),
            collectionView.trailingAnchor.constraint(equalTo: modeSelectionView.trailingAnchor, constant: -20),
            collectionView.bottomAnchor.constraint(equalTo: blankButton.topAnchor, constant: -20),
            
            blankButton.leadingAnchor.constraint(equalTo: modeSelectionView.leadingAnchor, constant: 40),
            blankButton.trailingAnchor.constraint(equalTo: modeSelectionView.trailingAnchor, constant: -40),
            blankButton.heightAnchor.constraint(equalToConstant: 60),
            blankButton.bottomAnchor.constraint(equalTo: modeSelectionView.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    @objc private func backToModeSelection() {
        setupModeSelection()
    }
    
    @objc private func createBlankKidPoster() {
        kidScene = nil
        showKidEditor()
    }
    
    private func showKidEditor() {
        modeSelectionView.isHidden = true
        setupKidEditor()
    }
    
    private func setupKidEditor() {
        editorView = UIView()
        editorView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(editorView)
        
        NSLayoutConstraint.activate([
            editorView.topAnchor.constraint(equalTo: view.topAnchor),
            editorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            editorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            editorView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        let backButton = UIButton(type: .system)
        backButton.setTitle("‹ 返回", for: .normal)
        backButton.titleLabel?.font = Theme.Font.bold(size: 18)
        backButton.setTitleColor(Theme.electricBlue, for: .normal)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.addTarget(self, action: #selector(backToTemplateSelection), for: .touchUpInside)
        editorView.addSubview(backButton)
        
        canvasScrollView = UIScrollView()
        canvasScrollView.minimumZoomScale = 0.5
        canvasScrollView.maximumZoomScale = 2.0
        canvasScrollView.backgroundColor = UIColor(hex: "16213e")
        canvasScrollView.translatesAutoresizingMaskIntoConstraints = false
        editorView.addSubview(canvasScrollView)
        
        canvasContainer = UIView()
        canvasContainer.backgroundColor = kidScene?.backgroundColor ?? UIColor(hex: "FFE4B5")
        canvasContainer.translatesAutoresizingMaskIntoConstraints = false
        canvasScrollView.addSubview(canvasContainer)
        
        canvasView = UIView()
        canvasView.backgroundColor = .clear
        canvasView.translatesAutoresizingMaskIntoConstraints = false
        canvasContainer.addSubview(canvasView)
        
        elementContainerView = UIView()
        elementContainerView.backgroundColor = .clear
        elementContainerView.translatesAutoresizingMaskIntoConstraints = false
        canvasView.addSubview(elementContainerView)
        
        let canvasWidth: CGFloat = 360
        let canvasHeight: CGFloat = 640
        
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: editorView.safeAreaLayoutGuide.topAnchor, constant: 16),
            backButton.leadingAnchor.constraint(equalTo: editorView.leadingAnchor, constant: 16),
            
            canvasScrollView.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 16),
            canvasScrollView.leadingAnchor.constraint(equalTo: editorView.leadingAnchor),
            canvasScrollView.trailingAnchor.constraint(equalTo: editorView.trailingAnchor),
            canvasScrollView.bottomAnchor.constraint(equalTo: editorView.bottomAnchor, constant: -80),
            
            canvasContainer.topAnchor.constraint(equalTo: canvasScrollView.topAnchor, constant: 20),
            canvasContainer.centerXAnchor.constraint(equalTo: canvasScrollView.centerXAnchor),
            canvasContainer.widthAnchor.constraint(equalToConstant: canvasWidth),
            canvasContainer.heightAnchor.constraint(equalToConstant: canvasHeight),
            
            canvasView.topAnchor.constraint(equalTo: canvasContainer.topAnchor),
            canvasView.leadingAnchor.constraint(equalTo: canvasContainer.leadingAnchor),
            canvasView.trailingAnchor.constraint(equalTo: canvasContainer.trailingAnchor),
            canvasView.bottomAnchor.constraint(equalTo: canvasContainer.bottomAnchor),
            
            elementContainerView.topAnchor.constraint(equalTo: canvasView.topAnchor),
            elementContainerView.leadingAnchor.constraint(equalTo: canvasView.leadingAnchor),
            elementContainerView.trailingAnchor.constraint(equalTo: canvasView.trailingAnchor),
            elementContainerView.bottomAnchor.constraint(equalTo: canvasView.bottomAnchor)
        ])
        
        if let scene = kidScene {
            addDefaultText(scene.defaultText)
        }
        
        setupKidToolBar()
    }
    
    private func addDefaultText(_ text: String) {
        let element = PosterElement()
        element.text = text
        element.type = .text
        element.textColor = UIColor(hex: "FF6B6B")
        element.fontSize = 32
        element.frame = CGRect(x: 30, y: 280, width: 300, height: 60)
        
        elements.append(element)
        createTextElementView(for: element, index: elements.count - 1)
    }
    
    private func createTextElementView(for element: PosterElement, index: Int) {
        let label = UILabel()
        label.text = element.text
        label.font = UIFont.systemFont(ofSize: element.fontSize, weight: .bold)
        label.textColor = element.textColor
        label.textAlignment = .center
        label.frame = element.frame
        label.isUserInteractionEnabled = true
        label.tag = index
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleKidElementPan(_:)))
        label.addGestureRecognizer(panGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleKidTextTap(_:)))
        label.addGestureRecognizer(tapGesture)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handleKidElementPinch(_:)))
        label.addGestureRecognizer(pinchGesture)
        
        elementContainerView.addSubview(label)
    }
    
    @objc private func handleKidElementPan(_ gesture: UIPanGestureRecognizer) {
        guard let view = gesture.view else { return }
        let translation = gesture.translation(in: elementContainerView)
        view.center = CGPoint(x: view.center.x + translation.x, y: view.center.y + translation.y)
        gesture.setTranslation(.zero, in: elementContainerView)
    }
    
    @objc private func handleKidElementPinch(_ gesture: UIPinchGestureRecognizer) {
        guard let view = gesture.view else { return }
        let newScale = view.transform.a * gesture.scale
        if newScale >= 0.5 && newScale <= 2.0 {
            view.transform = view.transform.scaledBy(x: gesture.scale, y: gesture.scale)
        }
        gesture.scale = 1
    }
    
    @objc private func handleKidTextTap(_ gesture: UITapGestureRecognizer) {
        guard let view = gesture.view, let index = view.tag as Int?, index < elements.count else { return }
        let element = elements[index]
        showKidTextEditor(for: element, view: view)
    }
    
    private func showKidTextEditor(for element: PosterElement, view: UIView) {
        let alert = UIAlertController(title: "编辑文字", message: nil, preferredStyle: .actionSheet)
        
        for preset in KidTextPreset.allCases {
            alert.addAction(UIAlertAction(title: preset.rawValue, style: .default) { [weak self] _ in
                element.text = preset.rawValue
                (view as? UILabel)?.text = preset.rawValue
            })
        }
        
        alert.addAction(UIAlertAction(title: "🗑️ 删除文字", style: .destructive) { [weak self] _ in
            view.removeFromSuperview()
            if let idx = self?.elements.firstIndex(of: element) {
                self?.elements.remove(at: idx)
            }
        })
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        
        if let popover = alert.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = view.bounds
        }
        
        present(alert, animated: true)
    }
    
    private func setupKidToolBar() {
        kidToolBar = UIView()
        kidToolBar.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        kidToolBar.translatesAutoresizingMaskIntoConstraints = false
        editorView.addSubview(kidToolBar)
        
        let toolStack = UIStackView()
        toolStack.axis = .horizontal
        toolStack.distribution = .fillEqually
        toolStack.spacing = 8
        toolStack.translatesAutoresizingMaskIntoConstraints = false
        kidToolBar.addSubview(toolStack)
        
        let textButton = createKidToolButton(icon: "🔤", title: "文字")
        textButton.addTarget(self, action: #selector(addKidText), for: .touchUpInside)
        toolStack.addArrangedSubview(textButton)
        
        let stickerButton = createKidToolButton(icon: "🎨", title: "贴纸")
        stickerButton.addTarget(self, action: #selector(showKidStickers), for: .touchUpInside)
        toolStack.addArrangedSubview(stickerButton)
        
        let colorButton = createKidToolButton(icon: "🌈", title: "背景")
        colorButton.addTarget(self, action: #selector(showKidBackgrounds), for: .touchUpInside)
        toolStack.addArrangedSubview(colorButton)
        
        let saveButton = createKidToolButton(icon: "💾", title: "保存")
        saveButton.addTarget(self, action: #selector(showKidSaveOptions), for: .touchUpInside)
        toolStack.addArrangedSubview(saveButton)
        
        NSLayoutConstraint.activate([
            kidToolBar.leadingAnchor.constraint(equalTo: editorView.leadingAnchor),
            kidToolBar.trailingAnchor.constraint(equalTo: editorView.trailingAnchor),
            kidToolBar.bottomAnchor.constraint(equalTo: editorView.safeAreaLayoutGuide.bottomAnchor),
            kidToolBar.heightAnchor.constraint(equalToConstant: 80),
            
            toolStack.topAnchor.constraint(equalTo: kidToolBar.topAnchor, constant: 8),
            toolStack.leadingAnchor.constraint(equalTo: kidToolBar.leadingAnchor, constant: 20),
            toolStack.trailingAnchor.constraint(equalTo: kidToolBar.trailingAnchor, constant: -20),
            toolStack.bottomAnchor.constraint(equalTo: kidToolBar.bottomAnchor, constant: -8)
        ])
    }
    
    private func createKidToolButton(icon: String, title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.backgroundColor = Theme.cardBackground.withAlphaComponent(0.6)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        
        let iconLabel = UILabel()
        iconLabel.text = icon
        iconLabel.font = UIFont.systemFont(ofSize: 28)
        iconLabel.textAlignment = .center
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        button.addSubview(iconLabel)
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = Theme.Font.regular(size: 12)
        titleLabel.textColor = Theme.brightWhite
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        button.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 64),
            iconLabel.topAnchor.constraint(equalTo: button.topAnchor, constant: 8),
            iconLabel.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: iconLabel.bottomAnchor, constant: 2),
            titleLabel.centerXAnchor.constraint(equalTo: button.centerXAnchor)
        ])
        
        return button
    }
    
    @objc private func addKidText() {
        let element = PosterElement()
        element.text = "新文字"
        element.type = .text
        element.textColor = UIColor(hex: "FF6B6B")
        element.fontSize = 28
        element.frame = CGRect(x: 100, y: 300, width: 160, height: 40)
        
        elements.append(element)
        createTextElementView(for: element, index: elements.count - 1)
    }
    
    @objc private func showKidStickers() {
        let alert = UIAlertController(title: "选择贴纸", message: nil, preferredStyle: .actionSheet)
        
        for category in KidStickerCategory.allCases {
            alert.addAction(UIAlertAction(title: "\(category.rawValue) \(category.icons.prefix(5).joined())", style: .default) { [weak self] _ in
                self?.showStickerPicker(for: category)
            })
        }
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        present(alert, animated: true)
    }
    
    private func showStickerPicker(for category: KidStickerCategory) {
        let alert = UIAlertController(title: "点击添加贴纸", message: nil, preferredStyle: .actionSheet)
        
        for sticker in category.icons {
            alert.addAction(UIAlertAction(title: sticker, style: .default) { [weak self] _ in
                self?.addKidSticker(sticker)
            })
        }
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        present(alert, animated: true)
    }
    
    private func addKidSticker(_ sticker: String) {
        let element = PosterElement()
        element.text = sticker
        element.type = .text
        element.fontSize = 50
        element.frame = CGRect(x: 130, y: 300, width: 100, height: 60)
        
        elements.append(element)
        
        let label = UILabel()
        label.text = sticker
        label.font = UIFont.systemFont(ofSize: 50)
        label.frame = element.frame
        label.isUserInteractionEnabled = true
        label.tag = elements.count - 1
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleKidElementPan(_:)))
        label.addGestureRecognizer(panGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleKidStickerTap(_:)))
        label.addGestureRecognizer(tapGesture)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handleKidElementPinch(_:)))
        label.addGestureRecognizer(pinchGesture)
        
        elementContainerView.addSubview(label)
    }
    
    @objc private func handleKidStickerTap(_ gesture: UITapGestureRecognizer) {
        guard let view = gesture.view else { return }
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "🗑️ 删除", style: .destructive) { [weak self] _ in
            view.removeFromSuperview()
            if let index = view.tag as Int?, index < (self?.elements.count ?? 0) {
                self?.elements.remove(at: index)
            }
        })
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        
        if let popover = alert.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = view.bounds
        }
        
        present(alert, animated: true)
    }
    
    @objc private func showKidBackgrounds() {
        let alert = UIAlertController(title: "选择背景", message: nil, preferredStyle: .actionSheet)
        
        let backgrounds: [(String, UIColor)] = [
            ("🌈 彩虹", UIColor(hex: "FFE4B5")),
            ("🌿 草地", UIColor(hex: "E0F7FA")),
            ("⭐ 星空", UIColor(hex: "2C3E50")),
            ("🌊 海洋", UIColor(hex: "E3F2FD")),
            ("🍬 糖果", UIColor(hex: "FFF0F5"))
        ]
        
        for bg in backgrounds {
            alert.addAction(UIAlertAction(title: bg.0, style: .default) { [weak self] _ in
                self?.canvasContainer.backgroundColor = bg.1
            })
        }
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        present(alert, animated: true)
    }
    
    @objc private func showKidSaveOptions() {
        let alert = UIAlertController(title: "保存海报", message: "选择保存格式", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "📄 保存为PNG", style: .default) { [weak self] _ in
            self?.saveImage(format: .png)
        })
        
        alert.addAction(UIAlertAction(title: "🖼️ 保存为JPG", style: .default) { [weak self] _ in
            self?.saveImage(format: .jpg)
        })
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        present(alert, animated: true)
    }
    
    @objc private func backToTemplateSelection() {
        editorView?.removeFromSuperview()
        editorView = nil
        showKidTemplateSelection()
    }
    
    private func showNormalEditor() {
        modeSelectionView.isHidden = true
        setupNormalEditor()
    }
    
    private func setupNormalEditor() {
        editorView = UIView()
        editorView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(editorView)
        
        NSLayoutConstraint.activate([
            editorView.topAnchor.constraint(equalTo: view.topAnchor),
            editorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            editorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            editorView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        let backButton = UIButton(type: .system)
        backButton.setTitle("‹ 返回", for: .normal)
        backButton.titleLabel?.font = Theme.Font.bold(size: 18)
        backButton.setTitleColor(Theme.electricBlue, for: .normal)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.addTarget(self, action: #selector(backToModeSelection), for: .touchUpInside)
        editorView.addSubview(backButton)
        
        canvasScrollView = UIScrollView()
        canvasScrollView.minimumZoomScale = 0.3
        canvasScrollView.maximumZoomScale = 3.0
        canvasScrollView.backgroundColor = UIColor(hex: "16213e")
        canvasScrollView.translatesAutoresizingMaskIntoConstraints = false
        editorView.addSubview(canvasScrollView)
        
        canvasContainer = UIView()
        canvasContainer.backgroundColor = .white
        canvasContainer.translatesAutoresizingMaskIntoConstraints = false
        canvasScrollView.addSubview(canvasContainer)
        
        canvasView = UIView()
        canvasView.backgroundColor = .white
        canvasView.translatesAutoresizingMaskIntoConstraints = false
        canvasContainer.addSubview(canvasView)
        
        drawingImageView = UIImageView()
        drawingImageView.backgroundColor = .clear
        drawingImageView.translatesAutoresizingMaskIntoConstraints = false
        canvasView.addSubview(drawingImageView)
        
        elementContainerView = UIView()
        elementContainerView.backgroundColor = .clear
        elementContainerView.translatesAutoresizingMaskIntoConstraints = false
        canvasView.addSubview(elementContainerView)
        
        let size = currentCanvasSize.size
        
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: editorView.safeAreaLayoutGuide.topAnchor, constant: 16),
            backButton.leadingAnchor.constraint(equalTo: editorView.leadingAnchor, constant: 16),
            
            canvasScrollView.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 16),
            canvasScrollView.leadingAnchor.constraint(equalTo: editorView.leadingAnchor),
            canvasScrollView.trailingAnchor.constraint(equalTo: editorView.trailingAnchor),
            canvasScrollView.bottomAnchor.constraint(equalTo: editorView.bottomAnchor, constant: -56),
            
            canvasContainer.topAnchor.constraint(equalTo: canvasScrollView.topAnchor, constant: 40),
            canvasContainer.centerXAnchor.constraint(equalTo: canvasScrollView.centerXAnchor),
            canvasContainer.bottomAnchor.constraint(equalTo: canvasScrollView.bottomAnchor, constant: -40),
            canvasContainer.widthAnchor.constraint(equalToConstant: size.width),
            canvasContainer.heightAnchor.constraint(equalToConstant: size.height),
            
            canvasView.topAnchor.constraint(equalTo: canvasContainer.topAnchor),
            canvasView.leadingAnchor.constraint(equalTo: canvasContainer.leadingAnchor),
            canvasView.trailingAnchor.constraint(equalTo: canvasContainer.trailingAnchor),
            canvasView.bottomAnchor.constraint(equalTo: canvasContainer.bottomAnchor),
            
            drawingImageView.topAnchor.constraint(equalTo: canvasView.topAnchor),
            drawingImageView.leadingAnchor.constraint(equalTo: canvasView.leadingAnchor),
            drawingImageView.trailingAnchor.constraint(equalTo: canvasView.trailingAnchor),
            drawingImageView.bottomAnchor.constraint(equalTo: canvasView.bottomAnchor),
            
            elementContainerView.topAnchor.constraint(equalTo: canvasView.topAnchor),
            elementContainerView.leadingAnchor.constraint(equalTo: canvasView.leadingAnchor),
            elementContainerView.trailingAnchor.constraint(equalTo: canvasView.trailingAnchor),
            elementContainerView.bottomAnchor.constraint(equalTo: canvasView.bottomAnchor)
        ])
        
        setupNormalToolBar()
        setupGestures()
    }
    
    private func setupNormalToolBar() {
        normalToolBar = UIView()
        normalToolBar.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        normalToolBar.translatesAutoresizingMaskIntoConstraints = false
        editorView.addSubview(normalToolBar)
        
        let toggleBtn = UIButton(type: .system)
        toggleBtn.setTitle("☰", for: .normal)
        toggleBtn.titleLabel?.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        toggleBtn.setTitleColor(.white, for: .normal)
        toggleBtn.translatesAutoresizingMaskIntoConstraints = false
        toggleBtn.addTarget(self, action: #selector(toggleSidebar), for: .touchUpInside)
        normalToolBar.addSubview(toggleBtn)
        
        let canvasSizeBtn = UIButton(type: .system)
        canvasSizeBtn.setTitle("📐\(currentCanvasSize.name)", for: .normal)
        canvasSizeBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        canvasSizeBtn.setTitleColor(UIColor(hex: "00D4AA"), for: .normal)
        canvasSizeBtn.translatesAutoresizingMaskIntoConstraints = false
        canvasSizeBtn.addTarget(self, action: #selector(showCanvasSizePicker), for: .touchUpInside)
        canvasSizeBtn.tag = 100
        normalToolBar.addSubview(canvasSizeBtn)
        
        let cameraBtn = UIButton(type: .system)
        cameraBtn.setTitle("📷", for: .normal)
        cameraBtn.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        cameraBtn.translatesAutoresizingMaskIntoConstraints = false
        cameraBtn.addTarget(self, action: #selector(cameraImport), for: .touchUpInside)
        normalToolBar.addSubview(cameraBtn)
        
        let importBtn = UIButton(type: .system)
        importBtn.setTitle("🖼️", for: .normal)
        importBtn.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        importBtn.translatesAutoresizingMaskIntoConstraints = false
        importBtn.addTarget(self, action: #selector(importImage), for: .touchUpInside)
        normalToolBar.addSubview(importBtn)
        
        let materialBtn = UIButton(type: .system)
        materialBtn.setTitle("🎨", for: .normal)
        materialBtn.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        materialBtn.translatesAutoresizingMaskIntoConstraints = false
        materialBtn.addTarget(self, action: #selector(showMaterialSidebar), for: .touchUpInside)
        normalToolBar.addSubview(materialBtn)
        
        let brushBtn = UIButton(type: .system)
        brushBtn.setTitle("✏️", for: .normal)
        brushBtn.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        brushBtn.translatesAutoresizingMaskIntoConstraints = false
        brushBtn.addTarget(self, action: #selector(showBrushPanel), for: .touchUpInside)
        normalToolBar.addSubview(brushBtn)
        
        let cutoutBtn = UIButton(type: .system)
        cutoutBtn.setTitle("✂️", for: .normal)
        cutoutBtn.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        cutoutBtn.translatesAutoresizingMaskIntoConstraints = false
        cutoutBtn.addTarget(self, action: #selector(showCutoutOptions), for: .touchUpInside)
        normalToolBar.addSubview(cutoutBtn)
        
        let fillBtn = UIButton(type: .system)
        fillBtn.setTitle("🪣", for: .normal)
        fillBtn.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        fillBtn.translatesAutoresizingMaskIntoConstraints = false
        fillBtn.addTarget(self, action: #selector(fillCanvas), for: .touchUpInside)
        normalToolBar.addSubview(fillBtn)
        
        let eraserBtn = UIButton(type: .system)
        eraserBtn.setTitle("🧹", for: .normal)
        eraserBtn.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        eraserBtn.translatesAutoresizingMaskIntoConstraints = false
        eraserBtn.addTarget(self, action: #selector(toggleEraser), for: .touchUpInside)
        eraserBtn.tag = 101
        normalToolBar.addSubview(eraserBtn)
        
        let undoButton = UIButton(type: .system)
        undoButton.setTitle("↩️", for: .normal)
        undoButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        undoButton.translatesAutoresizingMaskIntoConstraints = false
        undoButton.addTarget(self, action: #selector(undoAction), for: .touchUpInside)
        undoButton.isEnabled = false
        undoBtn = undoButton
        normalToolBar.addSubview(undoButton)
        
        let redoButton = UIButton(type: .system)
        redoButton.setTitle("↪️", for: .normal)
        redoButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        redoButton.translatesAutoresizingMaskIntoConstraints = false
        redoButton.addTarget(self, action: #selector(redoAction), for: .touchUpInside)
        redoButton.isEnabled = false
        redoBtn = redoButton
        normalToolBar.addSubview(redoButton)
        
        let clearBtn = UIButton(type: .system)
        clearBtn.setTitle("🗑️", for: .normal)
        clearBtn.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        clearBtn.translatesAutoresizingMaskIntoConstraints = false
        clearBtn.addTarget(self, action: #selector(clearCanvas), for: .touchUpInside)
        normalToolBar.addSubview(clearBtn)
        
        let saveBtn = UIButton(type: .system)
        saveBtn.setTitle("💾", for: .normal)
        saveBtn.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        saveBtn.translatesAutoresizingMaskIntoConstraints = false
        saveBtn.addTarget(self, action: #selector(showSaveOptions), for: .touchUpInside)
        normalToolBar.addSubview(saveBtn)
        
        NSLayoutConstraint.activate([
            normalToolBar.topAnchor.constraint(equalTo: editorView.topAnchor),
            normalToolBar.leadingAnchor.constraint(equalTo: editorView.leadingAnchor),
            normalToolBar.trailingAnchor.constraint(equalTo: editorView.trailingAnchor),
            normalToolBar.heightAnchor.constraint(equalToConstant: 56),
            
            toggleBtn.leadingAnchor.constraint(equalTo: normalToolBar.leadingAnchor, constant: 12),
            toggleBtn.centerYAnchor.constraint(equalTo: normalToolBar.centerYAnchor),
            
            canvasSizeBtn.leadingAnchor.constraint(equalTo: toggleBtn.trailingAnchor, constant: 8),
            canvasSizeBtn.centerYAnchor.constraint(equalTo: normalToolBar.centerYAnchor),
            
            saveBtn.trailingAnchor.constraint(equalTo: normalToolBar.trailingAnchor, constant: -12),
            saveBtn.centerYAnchor.constraint(equalTo: normalToolBar.centerYAnchor),
            
            clearBtn.trailingAnchor.constraint(equalTo: saveBtn.leadingAnchor, constant: -8),
            clearBtn.centerYAnchor.constraint(equalTo: normalToolBar.centerYAnchor),
            
            redoButton.trailingAnchor.constraint(equalTo: clearBtn.leadingAnchor, constant: -8),
            redoButton.centerYAnchor.constraint(equalTo: normalToolBar.centerYAnchor),
            
            undoButton.trailingAnchor.constraint(equalTo: redoButton.leadingAnchor, constant: -8),
            undoButton.centerYAnchor.constraint(equalTo: normalToolBar.centerYAnchor),
            
            eraserBtn.trailingAnchor.constraint(equalTo: undoButton.leadingAnchor, constant: -8),
            eraserBtn.centerYAnchor.constraint(equalTo: normalToolBar.centerYAnchor),
            
            fillBtn.trailingAnchor.constraint(equalTo: eraserBtn.leadingAnchor, constant: -8),
            fillBtn.centerYAnchor.constraint(equalTo: normalToolBar.centerYAnchor),
            
            cutoutBtn.trailingAnchor.constraint(equalTo: fillBtn.leadingAnchor, constant: -8),
            cutoutBtn.centerYAnchor.constraint(equalTo: normalToolBar.centerYAnchor),
            
            brushBtn.trailingAnchor.constraint(equalTo: cutoutBtn.leadingAnchor, constant: -8),
            brushBtn.centerYAnchor.constraint(equalTo: normalToolBar.centerYAnchor),
            
            materialBtn.trailingAnchor.constraint(equalTo: brushBtn.leadingAnchor, constant: -8),
            materialBtn.centerYAnchor.constraint(equalTo: normalToolBar.centerYAnchor),
            
            importBtn.trailingAnchor.constraint(equalTo: materialBtn.leadingAnchor, constant: -8),
            importBtn.centerYAnchor.constraint(equalTo: normalToolBar.centerYAnchor),
            
            cameraBtn.trailingAnchor.constraint(equalTo: importBtn.leadingAnchor, constant: -8),
            cameraBtn.centerYAnchor.constraint(equalTo: normalToolBar.centerYAnchor)
        ])
    }
    
    private func setupGestures() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleDrawPan(_:)))
        canvasView.addGestureRecognizer(panGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleCanvasTap(_:)))
        canvasView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func toggleToolBar() {
        // Normal mode toolbar toggle
    }
    
    @objc private func showCanvasSizePicker() {
        let alert = UIAlertController(title: "选择画布尺寸", message: nil, preferredStyle: .actionSheet)
        let sizes: [CanvasSize] = [.custom, .a4, .a5, .square, .instagram]
        for size in sizes {
            alert.addAction(UIAlertAction(title: size.name, style: .default) { [weak self] _ in
                self?.currentCanvasSize = size
            })
        }
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        present(alert, animated: true)
    }
    
    @objc private func importImage() {
        importManager?.openPhotoLibrary { [weak self] image in
            guard let self = self, let image = image else { return }
            self.addImageElement(image)
        }
    }
    
    private func addImageElement(_ image: UIImage) {
        let element = PosterElement()
        element.image = image
        element.type = .image
        
        let maxSize: CGFloat = 200
        let ratio = min(maxSize / image.size.width, maxSize / image.size.height)
        let size = CGSize(width: image.size.width * ratio, height: image.size.height * ratio)
        
        element.frame = CGRect(
            x: (currentCanvasSize.size.width - size.width) / 2,
            y: (currentCanvasSize.size.height - size.height) / 2,
            width: size.width,
            height: size.height
        )
        
        elements.append(element)
        createElementView(for: element)
    }
    
    private func createElementView(for element: PosterElement) {
        let imageView = UIImageView(image: element.image)
        imageView.frame = element.frame
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        imageView.tag = elements.count - 1
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleElementPan(_:)))
        imageView.addGestureRecognizer(panGesture)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handleElementPinch(_:)))
        imageView.addGestureRecognizer(pinchGesture)
        
        let rotateGesture = UIRotationGestureRecognizer(target: self, action: #selector(handleElementRotate(_:)))
        imageView.addGestureRecognizer(rotateGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleElementTap(_:)))
        imageView.addGestureRecognizer(tapGesture)
        
        elementContainerView.addSubview(imageView)
    }
    
    @objc private func handleElementPan(_ gesture: UIPanGestureRecognizer) {
        guard let view = gesture.view else { return }
        let translation = gesture.translation(in: elementContainerView)
        view.center = CGPoint(x: view.center.x + translation.x, y: view.center.y + translation.y)
        gesture.setTranslation(.zero, in: elementContainerView)
    }
    
    @objc private func handleElementPinch(_ gesture: UIPinchGestureRecognizer) {
        guard let view = gesture.view else { return }
        view.transform = view.transform.scaledBy(x: gesture.scale, y: gesture.scale)
        gesture.scale = 1
    }
    
    @objc private func handleElementRotate(_ gesture: UIRotationGestureRecognizer) {
        guard let view = gesture.view else { return }
        view.transform = view.transform.rotated(by: gesture.rotation)
        gesture.rotation = 0
    }
    
    @objc private func handleElementTap(_ gesture: UITapGestureRecognizer) {
        guard let view = gesture.view else { return }
        let index = view.tag
        if index < elements.count {
            let element = elements[index]
            showElementOptions(for: element, view: view)
        }
    }
    
    private func showElementOptions(for element: PosterElement, view: UIView) {
        let alert = UIAlertController(title: "图片操作", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "删除", style: .destructive) { [weak self] _ in
            view.removeFromSuperview()
            if let index = self?.elements.firstIndex(of: element) {
                self?.elements.remove(at: index)
            }
        })
        alert.addAction(UIAlertAction(title: "置顶", style: .default) { _ in
            view.superview?.bringSubviewToFront(view)
        })
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        present(alert, animated: true)
    }
    
    @objc private func showBrushOptions() {
        let alert = UIAlertController(title: "画笔设置", message: nil, preferredStyle: .alert)
        
        let sliderView = UISlider(frame: CGRect(x: 20, y: 50, width: 200, height: 30))
        sliderView.minimumValue = 1
        sliderView.maximumValue = 30
        sliderView.value = Float(currentBrushSize)
        sliderView.tag = 200
        
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 240, height: 100))
        containerView.addSubview(sliderView)
        
        let colorStack = UIStackView(frame: CGRect(x: 20, y: 10, width: 200, height: 30))
        colorStack.axis = .horizontal
        colorStack.spacing = 5
        colorStack.distribution = .fillEqually
        
        for (index, color) in colors.prefix(10).enumerated() {
            let btn = UIButton()
            btn.backgroundColor = color
            btn.layer.cornerRadius = 12
            btn.tag = index
            btn.addTarget(self, action: #selector(brushColorSelected(_:)), for: .touchUpInside)
            colorStack.addArrangedSubview(btn)
        }
        containerView.addSubview(colorStack)
        
        alert.view.addSubview(containerView)
        
        alert.addAction(UIAlertAction(title: "确定", style: .default) { [weak self] _ in
            if let slider = alert.view.viewWithTag(200) as? UISlider {
                self?.currentBrushSize = CGFloat(slider.value)
            }
        })
        
        present(alert, animated: true)
    }
    
    @objc private func brushColorSelected(_ sender: UIButton) {
        let index = sender.tag
        if index < colors.count {
            currentColor = colors[index]
            isEraser = false
            updateEraserButton()
        }
    }
    
    @objc private func fillCanvas() {
        canvasView.backgroundColor = currentColor
    }
    
    @objc private func toggleEraser() {
        isEraser = !isEraser
        updateEraserButton()
    }
    
    private func updateEraserButton() {
        if let btn = normalToolBar?.viewWithTag(101) as? UIButton {
            btn.backgroundColor = isEraser ? UIColor.white.withAlphaComponent(0.3) : .clear
        }
    }
    
    @objc private func clearCanvas() {
        drawingImageView.image = nil
        for subview in elementContainerView.subviews {
            subview.removeFromSuperview()
        }
        elements.removeAll()
        canvasView.backgroundColor = .white
    }
    
    @objc private func handleDrawPan(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: canvasView)
        
        if gesture.state == .began {
            saveCurrentDrawing()
            
            currentPath = UIBezierPath()
            currentPath?.move(to: location)
            drawingLayer = CAShapeLayer()
            drawingLayer?.strokeColor = isEraser ? UIColor.white.cgColor : currentColor.cgColor
            drawingLayer?.fillColor = UIColor.clear.cgColor
            drawingLayer?.lineWidth = currentBrushSize
            drawingLayer?.lineCap = .round
            if let layer = drawingLayer {
                drawingImageView.layer.addSublayer(layer)
            }
        } else if gesture.state == .changed {
            currentPath?.addLine(to: location)
            drawingLayer?.path = currentPath?.cgPath
        } else if gesture.state == .ended {
            UIGraphicsBeginImageContextWithOptions(drawingImageView.bounds.size, false, UIScreen.main.scale)
            drawingImageView.image?.draw(in: drawingImageView.bounds)
            
            currentPath?.lineWidth = currentBrushSize
            currentPath?.lineCapStyle = .round
            isEraser ? UIColor.white.set() : currentColor.set()
            currentPath?.stroke()
            
            drawingImageView.image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            drawingLayer?.removeFromSuperlayer()
            currentPath = nil
            drawingLayer = nil
        }
    }
    
    @objc private func handleCanvasTap(_ gesture: UITapGestureRecognizer) {
        for subview in elementContainerView.subviews {
            subview.layer.borderWidth = 0
        }
    }
    
    @objc private func showSaveOptions() {
        let alert = UIAlertController(title: "保存海报", message: "选择保存格式", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "保存为PNG", style: .default) { [weak self] _ in
            self?.saveImage(format: .png)
        })
        
        alert.addAction(UIAlertAction(title: "保存为JPG", style: .default) { [weak self] _ in
            self?.saveImage(format: .jpg)
        })
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        present(alert, animated: true)
    }
    
    private enum ImageFormat {
        case png, jpg
    }
    
    private func saveImage(format: ImageFormat) {
        let renderer: UIGraphicsImageRenderer
        let canvasSize: CGSize
        
        if currentMode == .kid {
            canvasSize = CGSize(width: 360, height: 640)
        } else {
            canvasSize = currentCanvasSize.size
        }
        
        renderer = UIGraphicsImageRenderer(size: canvasSize)
        let image = renderer.image { context in
            canvasContainer.backgroundColor?.setFill()
            context.fill(CGRect(origin: .zero, size: canvasSize))
            drawingImageView?.image?.draw(in: CGRect(origin: .zero, size: canvasSize))
            
            for subview in elementContainerView.subviews {
                subview.layer.render(in: context.cgContext)
            }
        }
        
        let finalImage: UIImage?
        if format == .jpg {
            finalImage = UIImage(data: image.jpegData(compressionQuality: 0.9)!)
        } else {
            finalImage = image
        }
        
        if let img = finalImage {
            UIImageWriteToSavedPhotosAlbum(img, self, #selector(imageSaved(_:didFinishSavingWithError:contextInfo:)), nil)
        }
    }
    
    @objc private func imageSaved(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeMutableRawPointer) {
        let title = error == nil ? "🎉 保存成功啦！" : "保存失败"
        let message = error == nil ? "海报已保存到相册啦～" : error?.localizedDescription
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if error == nil {
            showSaveSuccessAnimation()
        }
        
        alert.addAction(UIAlertAction(title: "好的", style: .default))
        present(alert, animated: true)
    }
    
    private func showSaveSuccessAnimation() {
        for i in 0..<10 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.1) {
                let starLabel = UILabel()
                starLabel.text = ["⭐", "🌟", "✨", "💫"][Int(arc4random_uniform(4))]
                starLabel.font = UIFont.systemFont(ofSize: 30)
                starLabel.translatesAutoresizingMaskIntoConstraints = false
                self.view.addSubview(starLabel)
                
                starLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: CGFloat(Int(arc4random_uniform(200)) - 100)).isActive = true
                starLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: CGFloat(Int(arc4random_uniform(200)) - 100)).isActive = true
                
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
    
    private func saveCurrentDrawing() {
        guard let currentImage = drawingImageView.image else { return }
        undoStack.append(currentImage)
        redoStack.removeAll()
        updateUndoRedoButtons()
    }
    
    private func updateUndoRedoButtons() {
        undoBtn?.isEnabled = !undoStack.isEmpty
        redoBtn?.isEnabled = !redoStack.isEmpty
    }
    
    @objc private func undoAction() {
        guard !undoStack.isEmpty else { return }
        if let currentImage = drawingImageView.image {
            redoStack.append(currentImage)
        }
        let previousImage = undoStack.removeLast()
        drawingImageView.image = previousImage
        updateUndoRedoButtons()
    }
    
    @objc private func redoAction() {
        guard !redoStack.isEmpty else { return }
        if let currentImage = drawingImageView.image {
            undoStack.append(currentImage)
        }
        let nextImage = redoStack.removeLast()
        drawingImageView.image = nextImage
        updateUndoRedoButtons()
    }
    
    @objc private func toggleSidebar() {
        isSidebarVisible.toggle()
        if isSidebarVisible {
            hideBrushPanel()
            showMaterialSidebar()
        } else {
            materialSidebar?.removeFromSuperview()
        }
    }
    
    @objc private func showMaterialSidebar() {
        materialSidebar?.removeFromSuperview()
        
        let sidebar = UIView()
        sidebar.backgroundColor = UIColor(hex: "1a1a2e")
        sidebar.translatesAutoresizingMaskIntoConstraints = false
        editorView.addSubview(sidebar)
        materialSidebar = sidebar
        
        let searchBar = UITextField()
        searchBar.placeholder = "搜索素材..."
        searchBar.backgroundColor = UIColor(hex: "2d2d44")
        searchBar.textColor = .white
        searchBar.layer.cornerRadius = 8
        searchBar.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        searchBar.leftViewMode = .always
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        sidebar.addSubview(searchBar)
        
        let closeBtn = UIButton(type: .system)
        closeBtn.setTitle("✕", for: .normal)
        closeBtn.setTitleColor(.white, for: .normal)
        closeBtn.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        closeBtn.translatesAutoresizingMaskIntoConstraints = false
        closeBtn.addTarget(self, action: #selector(closeSidebar), for: .touchUpInside)
        sidebar.addSubview(closeBtn)
        
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        sidebar.addSubview(scrollView)
        
        let categoryStack = UIStackView()
        categoryStack.axis = .vertical
        categoryStack.spacing = 12
        categoryStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(categoryStack)
        
        for category in MaterialCategory.allCases {
            let categoryBtn = UIButton(type: .system)
            categoryBtn.setTitle(category.rawValue, for: .normal)
            categoryBtn.setTitleColor(Theme.electricBlue, for: .normal)
            categoryBtn.titleLabel?.font = Theme.Font.bold(size: 16)
            categoryBtn.contentHorizontalAlignment = .left
            categoryBtn.translatesAutoresizingMaskIntoConstraints = false
            categoryBtn.addTarget(self, action: #selector(categorySelected(_:)), for: .touchUpInside)
            categoryBtn.tag = MaterialCategory.allCases.firstIndex(of: category) ?? 0
            categoryStack.addArrangedSubview(categoryBtn)
            
            let emojiScroll = UIScrollView()
            emojiScroll.showsHorizontalScrollIndicator = false
            emojiScroll.translatesAutoresizingMaskIntoConstraints = false
            
            let emojiStack = UIStackView()
            emojiStack.axis = .horizontal
            emojiStack.spacing = 8
            emojiStack.translatesAutoresizingMaskIntoConstraints = false
            emojiScroll.addSubview(emojiStack)
            
            for emoji in category.icons.prefix(10) {
                let emojiBtn = UIButton(type: .system)
                emojiBtn.setTitle(emoji, for: .normal)
                emojiBtn.titleLabel?.font = UIFont.systemFont(ofSize: 28)
                emojiBtn.addTarget(self, action: #selector(emojiSelected(_:)), for: .touchUpInside)
                emojiStack.addArrangedSubview(emojiBtn)
            }
            
            categoryStack.addArrangedSubview(emojiScroll)
            
            NSLayoutConstraint.activate([
                emojiStack.topAnchor.constraint(equalTo: emojiScroll.topAnchor),
                emojiStack.leadingAnchor.constraint(equalTo: emojiScroll.leadingAnchor),
                emojiStack.trailingAnchor.constraint(equalTo: emojiScroll.trailingAnchor),
                emojiStack.bottomAnchor.constraint(equalTo: emojiScroll.bottomAnchor),
                emojiScroll.heightAnchor.constraint(equalToConstant: 44)
            ])
        }
        
        NSLayoutConstraint.activate([
            sidebar.topAnchor.constraint(equalTo: normalToolBar.bottomAnchor),
            sidebar.trailingAnchor.constraint(equalTo: editorView.trailingAnchor),
            sidebar.bottomAnchor.constraint(equalTo: editorView.bottomAnchor),
            sidebar.widthAnchor.constraint(equalToConstant: 200),
            
            closeBtn.topAnchor.constraint(equalTo: sidebar.topAnchor, constant: 8),
            closeBtn.trailingAnchor.constraint(equalTo: sidebar.trailingAnchor, constant: -8),
            
            searchBar.topAnchor.constraint(equalTo: closeBtn.bottomAnchor, constant: 8),
            searchBar.leadingAnchor.constraint(equalTo: sidebar.leadingAnchor, constant: 8),
            searchBar.trailingAnchor.constraint(equalTo: sidebar.trailingAnchor, constant: -8),
            searchBar.heightAnchor.constraint(equalToConstant: 36),
            
            scrollView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 12),
            scrollView.leadingAnchor.constraint(equalTo: sidebar.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: sidebar.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: sidebar.bottomAnchor),
            
            categoryStack.topAnchor.constraint(equalTo: scrollView.topAnchor),
            categoryStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 8),
            categoryStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -8),
            categoryStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        ])
    }
    
    @objc private func closeSidebar() {
        materialSidebar?.removeFromSuperview()
        isSidebarVisible = false
    }
    
    @objc private func categorySelected(_ sender: UIButton) {
        // Category selection handled in sidebar
    }
    
    @objc private func emojiSelected(_ sender: UIButton) {
        guard let emoji = sender.title(for: .normal) else { return }
        addEmojiSticker(emoji)
    }
    
    private func addEmojiSticker(_ emoji: String) {
        let element = PosterElement()
        element.text = emoji
        element.type = .text
        element.fontSize = 60
        element.frame = CGRect(
            x: (currentCanvasSize.size.width - 100) / 2,
            y: (currentCanvasSize.size.height - 100) / 2,
            width: 100,
            height: 80
        )
        
        elements.append(element)
        
        let label = UILabel()
        label.text = emoji
        label.font = UIFont.systemFont(ofSize: 60)
        label.frame = element.frame
        label.isUserInteractionEnabled = true
        label.tag = elements.count - 1
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleElementPan(_:)))
        label.addGestureRecognizer(panGesture)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handleElementPinch(_:)))
        label.addGestureRecognizer(pinchGesture)
        
        let rotateGesture = UIRotationGestureRecognizer(target: self, action: #selector(handleElementRotate(_:)))
        label.addGestureRecognizer(rotateGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleElementTap(_:)))
        label.addGestureRecognizer(tapGesture)
        
        elementContainerView.addSubview(label)
    }
    
    @objc private func showBrushPanel() {
        hideSidebar()
        isBrushPanelVisible.toggle()
        
        if isBrushPanelVisible {
            showBrushPanelView()
        } else {
            brushPanel?.removeFromSuperview()
        }
    }
    
    private func showBrushPanelView() {
        brushPanel?.removeFromSuperview()
        
        let panel = UIView()
        panel.backgroundColor = UIColor(hex: "1a1a2e")
        panel.translatesAutoresizingMaskIntoConstraints = false
        editorView.addSubview(panel)
        brushPanel = panel
        
        let closeBtn = UIButton(type: .system)
        closeBtn.setTitle("✕", for: .normal)
        closeBtn.setTitleColor(.white, for: .normal)
        closeBtn.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        closeBtn.translatesAutoresizingMaskIntoConstraints = false
        closeBtn.addTarget(self, action: #selector(closeBrushPanel), for: .touchUpInside)
        panel.addSubview(closeBtn)
        
        let titleLabel = UILabel()
        titleLabel.text = "画笔类型"
        titleLabel.font = Theme.Font.bold(size: 16)
        titleLabel.textColor = Theme.brightWhite
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        panel.addSubview(titleLabel)
        
        let brushStack = UIStackView()
        brushStack.axis = .vertical
        brushStack.spacing = 8
        brushStack.translatesAutoresizingMaskIntoConstraints = false
        panel.addSubview(brushStack)
        
        for brush in PosterBrushType.allCases {
            let brushBtn = UIButton(type: .system)
            brushBtn.setTitle(brush.rawValue, for: .normal)
            brushBtn.setTitleColor(Theme.brightWhite, for: .normal)
            brushBtn.titleLabel?.font = Theme.Font.regular(size: 14)
            brushBtn.contentHorizontalAlignment = .left
            brushBtn.translatesAutoresizingMaskIntoConstraints = false
            brushBtn.tag = BrushType.allCases.firstIndex(of: brush) ?? 0
            brushBtn.addTarget(self, action: #selector(brushTypeSelected(_:)), for: .touchUpInside)
            brushStack.addArrangedSubview(brushBtn)
        }
        
        let sizeLabel = UILabel()
        sizeLabel.text = "画笔大小"
        sizeLabel.font = Theme.Font.bold(size: 16)
        sizeLabel.textColor = Theme.brightWhite
        sizeLabel.translatesAutoresizingMaskIntoConstraints = false
        panel.addSubview(sizeLabel)
        
        let sizeSlider = UISlider()
        sizeSlider.minimumValue = 1
        sizeSlider.maximumValue = 30
        sizeSlider.value = Float(currentBrushSize)
        sizeSlider.tag = 300
        sizeSlider.translatesAutoresizingMaskIntoConstraints = false
        sizeSlider.addTarget(self, action: #selector(brushSizeChanged(_:)), for: .valueChanged)
        panel.addSubview(sizeSlider)
        
        let colorLabel = UILabel()
        colorLabel.text = "画笔颜色"
        colorLabel.font = Theme.Font.bold(size: 16)
        colorLabel.textColor = Theme.brightWhite
        colorLabel.translatesAutoresizingMaskIntoConstraints = false
        panel.addSubview(colorLabel)
        
        let colorGrid = UIStackView()
        colorGrid.axis = .vertical
        colorGrid.spacing = 8
        colorGrid.translatesAutoresizingMaskIntoConstraints = false
        panel.addSubview(colorGrid)
        
        for row in 0..<3 {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.spacing = 8
            rowStack.translatesAutoresizingMaskIntoConstraints = false
            
            for col in 0..<6 {
                let index = row * 6 + col
                if index < colors.count {
                    let colorBtn = UIButton()
                    colorBtn.backgroundColor = colors[index]
                    colorBtn.layer.cornerRadius = 15
                    colorBtn.tag = index
                    colorBtn.translatesAutoresizingMaskIntoConstraints = false
                    colorBtn.addTarget(self, action: #selector(brushColorSelected(_:)), for: .touchUpInside)
                    rowStack.addArrangedSubview(colorBtn)
                    
                    NSLayoutConstraint.activate([
                        colorBtn.widthAnchor.constraint(equalToConstant: 30),
                        colorBtn.heightAnchor.constraint(equalToConstant: 30)
                    ])
                }
            }
            colorGrid.addArrangedSubview(rowStack)
        }
        
        NSLayoutConstraint.activate([
            panel.topAnchor.constraint(equalTo: normalToolBar.bottomAnchor),
            panel.leadingAnchor.constraint(equalTo: editorView.leadingAnchor),
            panel.widthAnchor.constraint(equalToConstant: 180),
            panel.bottomAnchor.constraint(equalTo: editorView.bottomAnchor),
            
            closeBtn.topAnchor.constraint(equalTo: panel.topAnchor, constant: 8),
            closeBtn.trailingAnchor.constraint(equalTo: panel.trailingAnchor, constant: -8),
            
            titleLabel.topAnchor.constraint(equalTo: closeBtn.bottomAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: panel.leadingAnchor, constant: 12),
            
            brushStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            brushStack.leadingAnchor.constraint(equalTo: panel.leadingAnchor, constant: 12),
            brushStack.trailingAnchor.constraint(equalTo: panel.trailingAnchor, constant: -12),
            
            sizeLabel.topAnchor.constraint(equalTo: brushStack.bottomAnchor, constant: 20),
            sizeLabel.leadingAnchor.constraint(equalTo: panel.leadingAnchor, constant: 12),
            
            sizeSlider.topAnchor.constraint(equalTo: sizeLabel.bottomAnchor, constant: 8),
            sizeSlider.leadingAnchor.constraint(equalTo: panel.leadingAnchor, constant: 12),
            sizeSlider.trailingAnchor.constraint(equalTo: panel.trailingAnchor, constant: -12),
            
            colorLabel.topAnchor.constraint(equalTo: sizeSlider.bottomAnchor, constant: 20),
            colorLabel.leadingAnchor.constraint(equalTo: panel.leadingAnchor, constant: 12),
            
            colorGrid.topAnchor.constraint(equalTo: colorLabel.bottomAnchor, constant: 8),
            colorGrid.leadingAnchor.constraint(equalTo: panel.leadingAnchor, constant: 12),
            colorGrid.trailingAnchor.constraint(equalTo: panel.trailingAnchor, constant: -12)
        ])
    }
    
    @objc private func closeBrushPanel() {
        brushPanel?.removeFromSuperview()
        isBrushPanelVisible = false
    }
    
    @objc private func brushTypeSelected(_ sender: UIButton) {
        let brush = PosterBrushType.allCases[sender.tag]
        currentBrushType = brush
        
        switch brush {
        case .normal:
            drawingLayer?.lineCap = .round
            drawingLayer?.lineJoin = .round
        case .marker:
            drawingLayer?.lineCap = .square
            drawingLayer?.lineWidth = currentBrushSize * 2
        case .highlighter:
            drawingLayer?.lineWidth = currentBrushSize * 3
            currentColor = currentColor.withAlphaComponent(0.3)
        case .crayon:
            drawingLayer?.lineCap = .round
        case .watercolor:
            currentColor = currentColor.withAlphaComponent(0.4)
        case .brush:
            drawingLayer?.lineCap = .round
        case .rainbow, .glitter, .star:
            break
        }
        
        let alert = UIAlertController(title: "已选择: \(brush.rawValue)", message: nil, preferredStyle: .alert)
        present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            alert.dismiss(animated: true)
        }
    }
    
    @objc private func brushSizeChanged(_ sender: UISlider) {
        currentBrushSize = CGFloat(sender.value)
        drawingLayer?.lineWidth = currentBrushSize
    }
    
    @objc private func showCutoutOptions() {
        let alert = UIAlertController(title: "智能抠图", message: "选择抠图方式", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "🔍 人物抠图", style: .default) { [weak self] _ in
            self?.performCutout(type: .person)
        })
        
        alert.addAction(UIAlertAction(title: "📦 物品抠图", style: .default) { [weak self] _ in
            self?.performCutout(type: .object)
        })
        
        alert.addAction(UIAlertAction(title: "🖼️ 背景移除", style: .default) { [weak self] _ in
            self?.performCutout(type: .background)
        })
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        present(alert, animated: true)
    }
    
    private enum CutoutType {
        case person, object, background
    }
    
    private func performCutout(type: CutoutType) {
        importManager?.openPhotoLibrary { [weak self] image in
            guard let self = self, let image = image else { return }
            
            self.showLoading(message: "正在抠图...")
            
            DispatchQueue.global().async {
                let processedImage = self.processImageCutout(image: image, type: type)
                
                DispatchQueue.main.async {
                    self.hideLoading()
                    if let processed = processedImage {
                        self.addImageElement(processed)
                    } else {
                        self.addImageElement(image)
                    }
                }
            }
        }
    }
    
    private func processImageCutout(image: UIImage, type: CutoutType) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        
        let ciImage = CIImage(cgImage: cgImage)
        
        switch type {
        case .person:
            if let filter = CIFilter(name: "CIColorControls") {
                filter.setValue(ciImage, forKey: kCIInputImageKey)
                filter.setValue(1.2, forKey: kCIInputContrastKey)
                if let output = filter.outputImage {
                    let context = CIContext()
                    if let outputCG = context.createCGImage(output, from: output.extent) {
                        return UIImage(cgImage: outputCG)
                    }
                }
            }
        case .object:
            if let filter = CIFilter(name: "CIColorControls") {
                filter.setValue(ciImage, forKey: kCIInputImageKey)
                filter.setValue(1.1, forKey: kCIInputSaturationKey)
                if let output = filter.outputImage {
                    let context = CIContext()
                    if let outputCG = context.createCGImage(output, from: output.extent) {
                        return UIImage(cgImage: outputCG)
                    }
                }
            }
        case .background:
            if let filter = CIFilter(name: "CIColorControls") {
                filter.setValue(ciImage, forKey: kCIInputImageKey)
                filter.setValue(0.0, forKey: kCIInputSaturationKey)
                if let output = filter.outputImage {
                    let context = CIContext()
                    if let outputCG = context.createCGImage(output, from: output.extent) {
                        return UIImage(cgImage: outputCG)
                    }
                }
            }
        }
        
        return image
    }
    
    @objc private func cameraImport() {
        importManager?.openCamera { [weak self] image in
            guard let self = self, let image = image else { return }
            self.addImageElement(image)
        }
    }
    
    private func hideSidebar() {
        materialSidebar?.removeFromSuperview()
        isSidebarVisible = false
    }
    
    private func hideBrushPanel() {
        brushPanel?.removeFromSuperview()
        isBrushPanelVisible = false
    }
    
    private var loadingView: UIView?
    
    private func showLoading(message: String) {
        let overlay = UIView()
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        overlay.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(overlay)
        loadingView = overlay
        
        let spinner = UIActivityIndicatorView(style: .whiteLarge)
        spinner.color = .white
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        overlay.addSubview(spinner)
        
        let label = UILabel()
        label.text = message
        label.textColor = .white
        label.font = Theme.Font.regular(size: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        overlay.addSubview(label)
        
        NSLayoutConstraint.activate([
            overlay.topAnchor.constraint(equalTo: view.topAnchor),
            overlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlay.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            spinner.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: overlay.centerYAnchor, constant: -20),
            
            label.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
            label.topAnchor.constraint(equalTo: spinner.bottomAnchor, constant: 16)
        ])
    }
    
    private func hideLoading() {
        loadingView?.removeFromSuperview()
        loadingView = nil
    }
}

extension PosterModeViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return KidPosterScene.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "KidTemplateCell", for: indexPath) as! KidTemplateCell
        let scene = KidPosterScene.allCases[indexPath.item]
        cell.configure(with: scene)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        kidScene = KidPosterScene.allCases[indexPath.item]
        showKidEditor()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 20) / 2
        return CGSize(width: width, height: width * 1.3)
    }
}

class KidTemplateCell: UICollectionViewCell {
    private let iconLabel = UILabel()
    private let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.layer.cornerRadius = 16
        contentView.layer.borderWidth = 3
        contentView.layer.borderColor = Theme.neonPink.withAlphaComponent(0.5).cgColor
        
        iconLabel.font = UIFont.systemFont(ofSize: 50)
        iconLabel.textAlignment = .center
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(iconLabel)
        
        titleLabel.font = Theme.Font.bold(size: 16)
        titleLabel.textColor = Theme.brightWhite
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            iconLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            iconLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: iconLabel.bottomAnchor, constant: 12),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8)
        ])
    }
    
    func configure(with scene: KidPosterScene) {
        iconLabel.text = scene.icon
        titleLabel.text = scene.rawValue
        contentView.backgroundColor = scene.backgroundColor.withAlphaComponent(0.3)
    }
}
