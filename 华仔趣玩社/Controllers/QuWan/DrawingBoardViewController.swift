import UIKit

enum DrawingMode: Int {
    case freeDraw = 0
    case colorFill = 1
}

enum BrushType: Int {
    case normal = 0
    case round = 1
    case square = 2
    case spray = 3
    case highlighter = 4
}

class DrawingBoardViewController: UIViewController {
    
    private var canvasView: DrawingCanvasView!
    private var topBar: UIView!
    private var toolBar: UIScrollView!
    private var modeLabel: UILabel!
    private var currentColorPreview: UIView!
    private var colorButtons: [UIButton] = []
    private var brushButtons: [UIButton] = []
    
    private var currentMode: DrawingMode = .freeDraw
    private var currentColor: UIColor = .black
    private var currentBrushSize: CGFloat = 8.0
    private var currentBrushType: BrushType = .normal
    
    private var importManager: ImageImportManager!
    private var cachedOutlineImage: UIImage?
    
    private let colors: [UIColor] = [
        .black, UIColor(hex: "333333"), .gray, .white,
        .red, .orange, .yellow, .green,
        .cyan, .blue, .purple, .brown,
        UIColor(hex: "FF6B6B"), UIColor(hex: "FF8E72"), UIColor(hex: "FFE66D"), UIColor(hex: "7BED9F"),
        UIColor(hex: "70A1FF"), UIColor(hex: "5352ED"), UIColor(hex: "AA96DA"), UIColor(hex: "FCBAD3"),
        UIColor(hex: "FF9FF3"), UIColor(hex: "F368E0"), UIColor(hex: "FF6B6B"), UIColor(hex: "EE5A24")
    ]
    
    private let brushTypes: [(name: String, icon: String)] = [
        ("普通笔", "✏️"),
        ("圆头笔", "⚫"),
        ("方头笔", "◼️"),
        ("喷枪", "💨"),
        ("荧光笔", "💡")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        importManager = ImageImportManager(vc: self)
    }
    
    private func setupUI() {
        view.backgroundColor = Theme.gradientTop
        
        topBar = UIView()
        topBar.backgroundColor = Theme.cardBackground.withAlphaComponent(0.9)
        topBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topBar)
        
        let titleLabel = UILabel()
        titleLabel.text = "宝贝画板"
        titleLabel.font = Theme.Font.bold(size: 22)
        titleLabel.textColor = Theme.brightWhite
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        topBar.addSubview(titleLabel)
        
        modeLabel = UILabel()
        modeLabel.text = "自由绘画"
        modeLabel.font = Theme.Font.regular(size: 14)
        modeLabel.textColor = Theme.electricBlue
        modeLabel.translatesAutoresizingMaskIntoConstraints = false
        topBar.addSubview(modeLabel)
        
        currentColorPreview = UIView()
        currentColorPreview.backgroundColor = currentColor
        currentColorPreview.layer.cornerRadius = 15
        currentColorPreview.layer.borderWidth = 3
        currentColorPreview.layer.borderColor = Theme.brightWhite.cgColor
        currentColorPreview.translatesAutoresizingMaskIntoConstraints = false
        topBar.addSubview(currentColorPreview)
        
        let modeButton = UIButton(type: .system)
        modeButton.setTitle("切换模式", for: .normal)
        modeButton.titleLabel?.font = Theme.Font.bold(size: 14)
        modeButton.setTitleColor(Theme.neonPink, for: .normal)
        modeButton.layer.cornerRadius = 8
        modeButton.layer.borderWidth = 1
        modeButton.layer.borderColor = Theme.neonPink.cgColor
        modeButton.translatesAutoresizingMaskIntoConstraints = false
        modeButton.addTarget(self, action: #selector(switchMode), for: .touchUpInside)
        topBar.addSubview(modeButton)
        
        let clearButton = UIButton(type: .system)
        clearButton.setTitle("清空", for: .normal)
        clearButton.titleLabel?.font = Theme.Font.bold(size: 14)
        clearButton.setTitleColor(Theme.brightWhite, for: .normal)
        clearButton.backgroundColor = UIColor.red.withAlphaComponent(0.7)
        clearButton.layer.cornerRadius = 8
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        clearButton.addTarget(self, action: #selector(clearCanvas), for: .touchUpInside)
        topBar.addSubview(clearButton)
        
        NSLayoutConstraint.activate([
            topBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topBar.heightAnchor.constraint(equalToConstant: 70),
            
            titleLabel.leadingAnchor.constraint(equalTo: topBar.leadingAnchor, constant: 20),
            titleLabel.topAnchor.constraint(equalTo: topBar.topAnchor, constant: 12),
            
            modeLabel.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 12),
            modeLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            
            currentColorPreview.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            currentColorPreview.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            currentColorPreview.widthAnchor.constraint(equalToConstant: 30),
            currentColorPreview.heightAnchor.constraint(equalToConstant: 30),
            
            clearButton.trailingAnchor.constraint(equalTo: topBar.trailingAnchor, constant: -16),
            clearButton.centerYAnchor.constraint(equalTo: topBar.centerYAnchor),
            clearButton.widthAnchor.constraint(equalToConstant: 60),
            clearButton.heightAnchor.constraint(equalToConstant: 36),
            
            modeButton.trailingAnchor.constraint(equalTo: clearButton.leadingAnchor, constant: -12),
            modeButton.centerYAnchor.constraint(equalTo: topBar.centerYAnchor),
            modeButton.widthAnchor.constraint(equalToConstant: 80),
            modeButton.heightAnchor.constraint(equalToConstant: 36)
        ])
        
        canvasView = DrawingCanvasView(frame: .zero)
        canvasView.backgroundColor = .white
        canvasView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(canvasView)
        
        NSLayoutConstraint.activate([
            canvasView.topAnchor.constraint(equalTo: topBar.bottomAnchor, constant: 8),
            canvasView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            canvasView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -240),
            canvasView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8)
        ])
        
        setupToolBar()
        
        title = "宝贝画板"
    }
    
    private func setupToolBar() {
        toolBar = UIScrollView()
        toolBar.backgroundColor = Theme.cardBackground.withAlphaComponent(0.9)
        toolBar.layer.cornerRadius = Theme.cornerRadius
        toolBar.translatesAutoresizingMaskIntoConstraints = false
        toolBar.alwaysBounceVertical = true
        toolBar.showsVerticalScrollIndicator = true
        view.addSubview(toolBar)
        
        NSLayoutConstraint.activate([
            toolBar.topAnchor.constraint(equalTo: topBar.bottomAnchor, constant: 8),
            toolBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            toolBar.widthAnchor.constraint(equalToConstant: 220),
            toolBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8)
        ])
        
        setupFreeDrawTools()
    }
    
    private func setupFreeDrawTools() {
        for subview in toolBar.subviews {
            subview.removeFromSuperview()
        }
        colorButtons.removeAll()
        brushButtons.removeAll()
        
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        toolBar.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: toolBar.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: toolBar.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: toolBar.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: toolBar.widthAnchor),
            contentView.bottomAnchor.constraint(equalTo: toolBar.bottomAnchor)
        ])
        
        let brushLabel = UILabel()
        brushLabel.text = "画笔类型"
        brushLabel.font = Theme.Font.bold(size: 16)
        brushLabel.textColor = Theme.brightWhite
        brushLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(brushLabel)
        
        let brushStack = UIStackView()
        brushStack.axis = .horizontal
        brushStack.spacing = 8
        brushStack.distribution = .fillEqually
        brushStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(brushStack)
        
        for (index, brush) in brushTypes.enumerated() {
            let btn = UIButton()
            btn.setTitle(brush.icon, for: .normal)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 20)
            btn.backgroundColor = currentBrushType.rawValue == index ? Theme.neonPink.withAlphaComponent(0.8) : Theme.cardBackground
            btn.layer.cornerRadius = 8
            btn.layer.borderWidth = 2
            btn.layer.borderColor = currentBrushType.rawValue == index ? Theme.neonPink.cgColor : Theme.mutedGray.cgColor
            btn.tag = index
            btn.addTarget(self, action: #selector(brushTypeSelected(_:)), for: .touchUpInside)
            brushStack.addArrangedSubview(btn)
            brushButtons.append(btn)
        }
        
        let sizeLabel = UILabel()
        sizeLabel.text = "画笔大小"
        sizeLabel.font = Theme.Font.bold(size: 16)
        sizeLabel.textColor = Theme.brightWhite
        sizeLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(sizeLabel)
        
        let sizeValueLabel = UILabel()
        sizeValueLabel.text = "\(Int(currentBrushSize))"
        sizeValueLabel.font = Theme.Font.bold(size: 14)
        sizeValueLabel.textColor = Theme.electricBlue
        sizeValueLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(sizeValueLabel)
        
        let brushSlider = UISlider()
        brushSlider.minimumValue = 1
        brushSlider.maximumValue = 50
        brushSlider.value = Float(currentBrushSize)
        brushSlider.tintColor = Theme.electricBlue
        brushSlider.translatesAutoresizingMaskIntoConstraints = false
        brushSlider.addTarget(self, action: #selector(brushSizeChanged(_:)), for: .valueChanged)
        contentView.addSubview(brushSlider)
        
        let colorLabel = UILabel()
        colorLabel.text = "选择颜色"
        colorLabel.font = Theme.Font.bold(size: 16)
        colorLabel.textColor = Theme.brightWhite
        colorLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(colorLabel)
        
        let colorGrid = UIView()
        colorGrid.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(colorGrid)
        
        let cols = 4
        let spacing: CGFloat = 8
        let btnSize: CGFloat = 40
        
        for (index, color) in colors.enumerated() {
            let row = index / cols
            let col = index % cols
            
            let btn = UIButton()
            btn.backgroundColor = color
            btn.layer.cornerRadius = btnSize / 2
            btn.layer.borderWidth = currentColor.isEqual(color) ? 4 : 2
            btn.layer.borderColor = currentColor.isEqual(color) ? Theme.neonPink.cgColor : UIColor.white.withAlphaComponent(0.5).cgColor
            btn.tag = index
            btn.translatesAutoresizingMaskIntoConstraints = false
            btn.addTarget(self, action: #selector(colorSelected(_:)), for: .touchUpInside)
            colorGrid.addSubview(btn)
            colorButtons.append(btn)
            
            NSLayoutConstraint.activate([
                btn.leadingAnchor.constraint(equalTo: colorGrid.leadingAnchor, constant: CGFloat(col) * (btnSize + spacing)),
                btn.topAnchor.constraint(equalTo: colorGrid.topAnchor, constant: CGFloat(row) * (btnSize + spacing)),
                btn.widthAnchor.constraint(equalToConstant: btnSize),
                btn.heightAnchor.constraint(equalToConstant: btnSize)
            ])
        }
        
        let rows = (colors.count + cols - 1) / cols
        let colorGridHeight = CGFloat(rows) * (btnSize + spacing) - spacing
        
        let undoBtn = UIButton(type: .system)
        undoBtn.setTitle("撤销", for: .normal)
        undoBtn.titleLabel?.font = Theme.Font.bold(size: 16)
        undoBtn.setTitleColor(Theme.brightWhite, for: .normal)
        undoBtn.backgroundColor = Theme.electricBlue
        undoBtn.layer.cornerRadius = 10
        undoBtn.translatesAutoresizingMaskIntoConstraints = false
        undoBtn.addTarget(self, action: #selector(undoAction), for: .touchUpInside)
        contentView.addSubview(undoBtn)
        
        let saveBtn = UIButton(type: .system)
        saveBtn.setTitle("保存", for: .normal)
        saveBtn.titleLabel?.font = Theme.Font.bold(size: 16)
        saveBtn.setTitleColor(Theme.brightWhite, for: .normal)
        saveBtn.backgroundColor = Theme.neonPink
        saveBtn.layer.cornerRadius = 10
        saveBtn.translatesAutoresizingMaskIntoConstraints = false
        saveBtn.addTarget(self, action: #selector(saveAction), for: .touchUpInside)
        contentView.addSubview(saveBtn)
        
        NSLayoutConstraint.activate([
            brushLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            brushLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            
            brushStack.topAnchor.constraint(equalTo: brushLabel.bottomAnchor, constant: 8),
            brushStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            brushStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            brushStack.heightAnchor.constraint(equalToConstant: 44),
            
            sizeLabel.topAnchor.constraint(equalTo: brushStack.bottomAnchor, constant: 20),
            sizeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            
            sizeValueLabel.centerYAnchor.constraint(equalTo: sizeLabel.centerYAnchor),
            sizeValueLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            
            brushSlider.topAnchor.constraint(equalTo: sizeLabel.bottomAnchor, constant: 8),
            brushSlider.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            brushSlider.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            
            colorLabel.topAnchor.constraint(equalTo: brushSlider.bottomAnchor, constant: 20),
            colorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            
            colorGrid.topAnchor.constraint(equalTo: colorLabel.bottomAnchor, constant: 12),
            colorGrid.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            colorGrid.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            colorGrid.heightAnchor.constraint(equalToConstant: colorGridHeight),
            
            undoBtn.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            undoBtn.trailingAnchor.constraint(equalTo: contentView.centerXAnchor, constant: -6),
            undoBtn.topAnchor.constraint(equalTo: colorGrid.bottomAnchor, constant: 20),
            undoBtn.heightAnchor.constraint(equalToConstant: 44),
            
            saveBtn.leadingAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 6),
            saveBtn.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            saveBtn.topAnchor.constraint(equalTo: undoBtn.topAnchor),
            saveBtn.heightAnchor.constraint(equalToConstant: 44),
            
            contentView.bottomAnchor.constraint(equalTo: saveBtn.bottomAnchor, constant: 20)
        ])
        
        toolBar.contentSize = CGSize(width: 220, height: colorGridHeight + 380)
    }
    
    private func setupColorFillTools() {
        for subview in toolBar.subviews {
            subview.removeFromSuperview()
        }
        colorButtons.removeAll()
        
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        toolBar.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: toolBar.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: toolBar.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: toolBar.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: toolBar.widthAnchor)
        ])
        
        let importBtn = UIButton(type: .system)
        importBtn.setTitle("导入图片", for: .normal)
        importBtn.titleLabel?.font = Theme.Font.bold(size: 18)
        importBtn.setTitleColor(Theme.brightWhite, for: .normal)
        importBtn.backgroundColor = Theme.electricBlue
        importBtn.layer.cornerRadius = 12
        importBtn.translatesAutoresizingMaskIntoConstraints = false
        importBtn.addTarget(self, action: #selector(importImage), for: .touchUpInside)
        contentView.addSubview(importBtn)
        
        let resetBtn = UIButton(type: .system)
        resetBtn.setTitle("重置轮廓", for: .normal)
        resetBtn.titleLabel?.font = Theme.Font.bold(size: 18)
        resetBtn.setTitleColor(Theme.brightWhite, for: .normal)
        resetBtn.backgroundColor = UIColor.orange
        resetBtn.layer.cornerRadius = 12
        resetBtn.translatesAutoresizingMaskIntoConstraints = false
        resetBtn.addTarget(self, action: #selector(resetOutline), for: .touchUpInside)
        contentView.addSubview(resetBtn)
        
        let colorLabel = UILabel()
        colorLabel.text = "填色颜色"
        colorLabel.font = Theme.Font.bold(size: 16)
        colorLabel.textColor = Theme.brightWhite
        colorLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(colorLabel)
        
        let colorGrid = UIView()
        colorGrid.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(colorGrid)
        
        let cols = 4
        let spacing: CGFloat = 8
        let btnSize: CGFloat = 40
        
        for (index, color) in colors.enumerated() {
            let row = index / cols
            let col = index % cols
            
            let btn = UIButton()
            btn.backgroundColor = color
            btn.layer.cornerRadius = btnSize / 2
            btn.layer.borderWidth = currentColor.isEqual(color) ? 4 : 2
            btn.layer.borderColor = currentColor.isEqual(color) ? Theme.neonPink.cgColor : UIColor.white.withAlphaComponent(0.5).cgColor
            btn.tag = index
            btn.translatesAutoresizingMaskIntoConstraints = false
            btn.addTarget(self, action: #selector(colorSelected(_:)), for: .touchUpInside)
            colorGrid.addSubview(btn)
            colorButtons.append(btn)
            
            NSLayoutConstraint.activate([
                btn.leadingAnchor.constraint(equalTo: colorGrid.leadingAnchor, constant: CGFloat(col) * (btnSize + spacing)),
                btn.topAnchor.constraint(equalTo: colorGrid.topAnchor, constant: CGFloat(row) * (btnSize + spacing)),
                btn.widthAnchor.constraint(equalToConstant: btnSize),
                btn.heightAnchor.constraint(equalToConstant: btnSize)
            ])
        }
        
        let rows = (colors.count + cols - 1) / cols
        let colorGridHeight = CGFloat(rows) * (btnSize + spacing) - spacing
        
        let saveBtn = UIButton(type: .system)
        saveBtn.setTitle("保存作品", for: .normal)
        saveBtn.titleLabel?.font = Theme.Font.bold(size: 18)
        saveBtn.setTitleColor(Theme.brightWhite, for: .normal)
        saveBtn.backgroundColor = Theme.neonPink
        saveBtn.layer.cornerRadius = 12
        saveBtn.translatesAutoresizingMaskIntoConstraints = false
        saveBtn.addTarget(self, action: #selector(saveAction), for: .touchUpInside)
        contentView.addSubview(saveBtn)
        
        NSLayoutConstraint.activate([
            importBtn.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            importBtn.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            importBtn.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            importBtn.heightAnchor.constraint(equalToConstant: 50),
            
            resetBtn.topAnchor.constraint(equalTo: importBtn.bottomAnchor, constant: 12),
            resetBtn.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            resetBtn.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            resetBtn.heightAnchor.constraint(equalToConstant: 50),
            
            colorLabel.topAnchor.constraint(equalTo: resetBtn.bottomAnchor, constant: 24),
            colorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            
            colorGrid.topAnchor.constraint(equalTo: colorLabel.bottomAnchor, constant: 12),
            colorGrid.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            colorGrid.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            colorGrid.heightAnchor.constraint(equalToConstant: colorGridHeight),
            
            saveBtn.topAnchor.constraint(equalTo: colorGrid.bottomAnchor, constant: 20),
            saveBtn.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            saveBtn.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            saveBtn.heightAnchor.constraint(equalToConstant: 50),
            
            contentView.bottomAnchor.constraint(equalTo: saveBtn.bottomAnchor, constant: 20)
        ])
        
        toolBar.contentSize = CGSize(width: 220, height: colorGridHeight + 280)
    }
    
    @objc private func switchMode() {
        currentMode = currentMode == .freeDraw ? .colorFill : .freeDraw
        
        UIView.animate(withDuration: 0.3) {
            self.canvasView.alpha = 0
        } completion: { _ in
            if self.currentMode == .freeDraw {
                self.modeLabel.text = "自由绘画"
                self.modeLabel.textColor = Theme.electricBlue
                self.canvasView.clear()
                self.canvasView.setMode(.freeDraw)
                self.setupFreeDrawTools()
            } else {
                self.modeLabel.text = "填色乐园"
                self.modeLabel.textColor = Theme.neonPink
                self.canvasView.clear()
                self.canvasView.setMode(.colorFill)
                self.setupColorFillTools()
            }
            
            UIView.animate(withDuration: 0.3) {
                self.canvasView.alpha = 1
            }
        }
    }
    
    @objc private func brushTypeSelected(_ button: UIButton) {
        let index = button.tag
        if let brushType = BrushType(rawValue: index) {
            currentBrushType = brushType
            canvasView.setBrushType(brushType)
            
            for (i, btn) in brushButtons.enumerated() {
                btn.backgroundColor = i == index ? Theme.neonPink.withAlphaComponent(0.8) : Theme.cardBackground
                btn.layer.borderColor = i == index ? Theme.neonPink.cgColor : Theme.mutedGray.cgColor
            }
            
            animateButtonFeedback(button)
        }
    }
    
    @objc private func brushSizeChanged(_ slider: UISlider) {
        currentBrushSize = CGFloat(slider.value)
        canvasView.setBrushSize(currentBrushSize)
        
        if let sizeLabel = toolBar.subviews.first?.subviews.compactMap({ $0 as? UILabel }).first(where: { $0.text?.contains("画笔大小") == false && $0.textColor == Theme.electricBlue }) {
            sizeLabel.text = "\(Int(currentBrushSize))"
        }
    }
    
    @objc private func colorSelected(_ button: UIButton) {
        let index = button.tag
        if index < colors.count {
            currentColor = colors[index]
            canvasView.setColor(currentColor)
            
            currentColorPreview.backgroundColor = currentColor
            
            for (i, btn) in colorButtons.enumerated() {
                let isSelected = i == index
                btn.layer.borderWidth = isSelected ? 4 : 2
                btn.layer.borderColor = isSelected ? Theme.neonPink.cgColor : UIColor.white.withAlphaComponent(0.5).cgColor
            }
            
            animateColorButtonFeedback(button)
        }
    }
    
    private func animateButtonFeedback(_ button: UIButton) {
        UIView.animate(withDuration: 0.1, animations: {
            button.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                button.transform = .identity
            }
        }
    }
    
    private func animateColorButtonFeedback(_ button: UIButton) {
        UIView.animate(withDuration: 0.15, animations: {
            button.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            button.alpha = 0.7
        }) { _ in
            UIView.animate(withDuration: 0.15) {
                button.transform = .identity
                button.alpha = 1.0
            }
        }
    }
    
    @objc private func clearCanvas() {
        canvasView.clear()
    }
    
    @objc private func undoAction() {
        canvasView.undo()
    }
    
    @objc private func importImage() {
        importManager.openPhotoLibrary { [weak self] image in
            guard let self = self, let image = image else { return }
            self.processImportedImage(image)
        }
    }
    
    private func processImportedImage(_ image: UIImage) {
        let alert = UIAlertController(title: "处理中", message: "正在转换为填色轮廓...", preferredStyle: .alert)
        present(alert, animated: true)
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            let outline = image.convertToColoringOutline()
            
            DispatchQueue.main.async {
                alert.dismiss(animated: true) {
                    if let outline = outline {
                        self.cachedOutlineImage = outline
                        self.canvasView.setBackgroundImage(outline)
                    } else {
                        let errorAlert = UIAlertController(title: "处理失败", message: "无法转换图片，请尝试其他图片", preferredStyle: .alert)
                        errorAlert.addAction(UIAlertAction(title: "好的", style: .default))
                        self.present(errorAlert, animated: true)
                    }
                }
            }
        }
    }
    
    @objc private func resetOutline() {
        if let outline = cachedOutlineImage {
            canvasView.setBackgroundImage(outline)
        } else {
            let alert = UIAlertController(title: "提示", message: "请先导入图片", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "好的", style: .default))
            present(alert, animated: true)
        }
    }
    
    @objc private func saveAction() {
        guard let image = canvasView.exportImage() else { return }
        
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(imageSaved(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc private func imageSaved(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeMutableRawPointer) {
        if let error = error {
            let alert = UIAlertController(title: "保存失败", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "好的", style: .default))
            present(alert, animated: true)
        } else {
            let alert = UIAlertController(title: "保存成功", message: "作品已保存到相册", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "好的", style: .default))
            present(alert, animated: true)
        }
    }
}
