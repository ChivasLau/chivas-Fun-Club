import UIKit

class DrawingBoardViewController: UIViewController {
    
    private var canvasView: DrawingCanvasView!
    private var topBar: UIView!
    private var toolBarContainer: UIView!
    private var toolBarScrollView: UIScrollView!
    
    private var currentMode: DrawingMode = .freeDraw
    private var currentColor: UIColor = .black
    private var currentBrushSize: CGFloat = 8.0
    private var currentBrushType: BrushType = .normal
    
    private var isToolBarExpanded = true
    private var importManager: ImageImportManager?
    private var cachedOutlineImage: UIImage?
    private var isImporting = false
    
    private var colorButtons: [UIButton] = []
    private var brushButtons: [UIButton] = []
    private var sizeValueLabel: UILabel!
    
    private let colors: [UIColor] = [
        .black, UIColor(hex: "333333"), .gray, .white,
        .red, .orange, .yellow, .green,
        .cyan, .blue, .purple, .brown,
        UIColor(hex: "FF6B6B"), UIColor(hex: "FF8E72"), UIColor(hex: "FFE66D"), UIColor(hex: "7BED9F"),
        UIColor(hex: "70A1FF"), UIColor(hex: "5352ED"), UIColor(hex: "AA96DA"), UIColor(hex: "FCBAD3"),
        UIColor(hex: "FF9FF3"), UIColor(hex: "F368E0"), UIColor(hex: "FF6B6B"), UIColor(hex: "EE5A24")
    ]
    
    private let brushTypes: [(name: String, icon: String, type: BrushType)] = [
        ("普通笔", "✏️", .normal),
        ("圆头笔", "⚫", .round),
        ("方头笔", "◼️", .square),
        ("喷枪", "💨", .spray),
        ("荧光笔", "💡", .highlighter),
        ("星星", "⭐", .star),
        ("爱心", "❤️", .heart),
        ("三角", "🔺", .triangle),
        ("钻石", "💎", .diamond),
        ("彩虹笔", "🌈", .rainbow)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        importManager = ImageImportManager(vc: self)
    }
    
    override var prefersStatusBarHidden: Bool { return true }
    override var prefersHomeIndicatorAutoHidden: Bool { return false }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        canvasView = DrawingCanvasView(frame: view.bounds)
        canvasView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(canvasView)
        
        setupTopBar()
        setupToolBar()
    }
    
    private func setupTopBar() {
        topBar = UIView()
        topBar.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        topBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topBar)
        
        let toggleButton = UIButton(type: .system)
        toggleButton.setTitle("☰", for: .normal)
        toggleButton.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        toggleButton.setTitleColor(.white, for: .normal)
        toggleButton.translatesAutoresizingMaskIntoConstraints = false
        toggleButton.addTarget(self, action: #selector(toggleToolBar), for: .touchUpInside)
        topBar.addSubview(toggleButton)
        
        let modeButton = UIButton(type: .system)
        modeButton.setTitle("切换模式", for: .normal)
        modeButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        modeButton.setTitleColor(UIColor(hex: "00D4AA"), for: .normal)
        modeButton.layer.cornerRadius = 8
        modeButton.layer.borderWidth = 1
        modeButton.layer.borderColor = UIColor(hex: "00D4AA").cgColor
        modeButton.translatesAutoresizingMaskIntoConstraints = false
        modeButton.addTarget(self, action: #selector(switchMode), for: .touchUpInside)
        topBar.addSubview(modeButton)
        
        let undoButton = UIButton(type: .system)
        undoButton.setTitle("↩️", for: .normal)
        undoButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        undoButton.translatesAutoresizingMaskIntoConstraints = false
        undoButton.addTarget(self, action: #selector(undoAction), for: .touchUpInside)
        topBar.addSubview(undoButton)
        
        let clearButton = UIButton(type: .system)
        clearButton.setTitle("🗑️", for: .normal)
        clearButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        clearButton.addTarget(self, action: #selector(clearCanvas), for: .touchUpInside)
        topBar.addSubview(clearButton)
        
        let saveButton = UIButton(type: .system)
        saveButton.setTitle("💾", for: .normal)
        saveButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.addTarget(self, action: #selector(saveAction), for: .touchUpInside)
        topBar.addSubview(saveButton)
        
        NSLayoutConstraint.activate([
            topBar.topAnchor.constraint(equalTo: view.topAnchor),
            topBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topBar.heightAnchor.constraint(equalToConstant: 60),
            
            toggleButton.leadingAnchor.constraint(equalTo: topBar.leadingAnchor, constant: 16),
            toggleButton.centerYAnchor.constraint(equalTo: topBar.centerYAnchor),
            toggleButton.widthAnchor.constraint(equalToConstant: 44),
            
            modeButton.leadingAnchor.constraint(equalTo: toggleButton.trailingAnchor, constant: 12),
            modeButton.centerYAnchor.constraint(equalTo: topBar.centerYAnchor),
            modeButton.widthAnchor.constraint(equalToConstant: 80),
            modeButton.heightAnchor.constraint(equalToConstant: 32),
            
            saveButton.trailingAnchor.constraint(equalTo: topBar.trailingAnchor, constant: -16),
            saveButton.centerYAnchor.constraint(equalTo: topBar.centerYAnchor),
            saveButton.widthAnchor.constraint(equalToConstant: 44),
            
            clearButton.trailingAnchor.constraint(equalTo: saveButton.leadingAnchor, constant: -8),
            clearButton.centerYAnchor.constraint(equalTo: topBar.centerYAnchor),
            clearButton.widthAnchor.constraint(equalToConstant: 44),
            
            undoButton.trailingAnchor.constraint(equalTo: clearButton.leadingAnchor, constant: -8),
            undoButton.centerYAnchor.constraint(equalTo: topBar.centerYAnchor),
            undoButton.widthAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func setupToolBar() {
        toolBarContainer = UIView()
        toolBarContainer.backgroundColor = UIColor.black.withAlphaComponent(0.85)
        toolBarContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toolBarContainer)
        
        toolBarScrollView = UIScrollView()
        toolBarScrollView.translatesAutoresizingMaskIntoConstraints = false
        toolBarScrollView.alwaysBounceVertical = true
        toolBarContainer.addSubview(toolBarScrollView)
        
        NSLayoutConstraint.activate([
            toolBarContainer.topAnchor.constraint(equalTo: topBar.bottomAnchor),
            toolBarContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolBarContainer.widthAnchor.constraint(equalToConstant: 80),
            toolBarContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            
            toolBarScrollView.topAnchor.constraint(equalTo: toolBarContainer.topAnchor),
            toolBarScrollView.leadingAnchor.constraint(equalTo: toolBarContainer.leadingAnchor),
            toolBarScrollView.trailingAnchor.constraint(equalTo: toolBarContainer.trailingAnchor),
            toolBarScrollView.bottomAnchor.constraint(equalTo: toolBarContainer.bottomAnchor)
        ])
        
        setupFreeDrawTools()
    }
    
    private func setupFreeDrawTools() {
        for subview in toolBarScrollView.subviews {
            subview.removeFromSuperview()
        }
        brushButtons.removeAll()
        colorButtons.removeAll()
        
        let contentStack = UIStackView()
        contentStack.axis = .vertical
        contentStack.spacing = 8
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        toolBarScrollView.addSubview(contentStack)
        
        let brushLabel = UILabel()
        brushLabel.text = "画笔"
        brushLabel.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        brushLabel.textColor = .white
        brushLabel.textAlignment = .center
        contentStack.addArrangedSubview(brushLabel)
        
        let brushStack = UIStackView()
        brushStack.axis = .vertical
        brushStack.spacing = 4
        brushStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.addArrangedSubview(brushStack)
        
        for (index, brush) in brushTypes.enumerated() {
            let btn = UIButton()
            btn.setTitle(brush.icon, for: .normal)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 20)
            btn.backgroundColor = currentBrushType == brush.type ? UIColor(hex: "FF6B6B") : UIColor.white.withAlphaComponent(0.2)
            btn.layer.cornerRadius = 8
            btn.tag = index
            btn.translatesAutoresizingMaskIntoConstraints = false
            btn.addTarget(self, action: #selector(brushTypeSelected(_:)), for: .touchUpInside)
            brushStack.addArrangedSubview(btn)
            brushButtons.append(btn)
            
            NSLayoutConstraint.activate([
                btn.widthAnchor.constraint(equalToConstant: 60),
                btn.heightAnchor.constraint(equalToConstant: 44)
            ])
        }
        
        let sizeLabel = UILabel()
        sizeLabel.text = "大小"
        sizeLabel.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        sizeLabel.textColor = .white
        sizeLabel.textAlignment = .center
        contentStack.addArrangedSubview(sizeLabel)
        
        sizeValueLabel = UILabel()
        sizeValueLabel.text = "\(Int(currentBrushSize))"
        sizeValueLabel.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        sizeValueLabel.textColor = UIColor(hex: "00D4AA")
        sizeValueLabel.textAlignment = .center
        contentStack.addArrangedSubview(sizeValueLabel)
        
        let sizeStepper = UIStepper()
        sizeStepper.minimumValue = 1
        sizeStepper.maximumValue = 50
        sizeStepper.value = Double(currentBrushSize)
        sizeStepper.tintColor = UIColor(hex: "00D4AA")
        sizeStepper.translatesAutoresizingMaskIntoConstraints = false
        sizeStepper.addTarget(self, action: #selector(sizeStepperChanged(_:)), for: .valueChanged)
        contentStack.addArrangedSubview(sizeStepper)
        
        let colorLabel = UILabel()
        colorLabel.text = "颜色"
        colorLabel.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        colorLabel.textColor = .white
        colorLabel.textAlignment = .center
        contentStack.addArrangedSubview(colorLabel)
        
        let colorStack = UIStackView()
        colorStack.axis = .vertical
        colorStack.spacing = 4
        colorStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.addArrangedSubview(colorStack)
        
        let cols = 4
        let btnSize: CGFloat = 14
        for row in 0..<(colors.count + cols - 1) / cols {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.spacing = 2
            rowStack.distribution = .fillEqually
            rowStack.translatesAutoresizingMaskIntoConstraints = false
            colorStack.addArrangedSubview(rowStack)
            
            for col in 0..<cols {
                let index = row * cols + col
                if index >= colors.count { break }
                
                let btn = UIButton()
                btn.backgroundColor = colors[index]
                btn.layer.cornerRadius = btnSize / 2
                btn.layer.borderWidth = currentColor.isEqual(colors[index]) ? 2 : 0
                btn.layer.borderColor = UIColor.white.cgColor
                btn.tag = index
                btn.addTarget(self, action: #selector(colorSelected(_:)), for: .touchUpInside)
                rowStack.addArrangedSubview(btn)
                colorButtons.append(btn)
                
                NSLayoutConstraint.activate([
                    btn.widthAnchor.constraint(equalToConstant: btnSize),
                    btn.heightAnchor.constraint(equalToConstant: btnSize)
                ])
            }
        }
        
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: toolBarScrollView.topAnchor, constant: 12),
            contentStack.leadingAnchor.constraint(equalTo: toolBarScrollView.leadingAnchor, constant: 10),
            contentStack.trailingAnchor.constraint(equalTo: toolBarScrollView.trailingAnchor, constant: -10),
            contentStack.widthAnchor.constraint(equalToConstant: 60),
            contentStack.bottomAnchor.constraint(equalTo: toolBarScrollView.bottomAnchor, constant: -12)
        ])
        
        toolBarScrollView.contentSize = CGSize(width: 80, height: 1000)
    }
    
    private func setupColorFillTools() {
        for subview in toolBarScrollView.subviews {
            subview.removeFromSuperview()
        }
        colorButtons.removeAll()
        
        let contentStack = UIStackView()
        contentStack.axis = .vertical
        contentStack.spacing = 12
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        toolBarScrollView.addSubview(contentStack)
        
        let importBtn = UIButton(type: .system)
        importBtn.setTitle("📷", for: .normal)
        importBtn.titleLabel?.font = UIFont.systemFont(ofSize: 24)
        importBtn.backgroundColor = UIColor(hex: "00D4AA")
        importBtn.layer.cornerRadius = 8
        importBtn.translatesAutoresizingMaskIntoConstraints = false
        importBtn.addTarget(self, action: #selector(importImage), for: .touchUpInside)
        contentStack.addArrangedSubview(importBtn)
        NSLayoutConstraint.activate([importBtn.heightAnchor.constraint(equalToConstant: 50)])
        
        let resetBtn = UIButton(type: .system)
        resetBtn.setTitle("🔄", for: .normal)
        resetBtn.titleLabel?.font = UIFont.systemFont(ofSize: 24)
        resetBtn.backgroundColor = UIColor.orange
        resetBtn.layer.cornerRadius = 8
        resetBtn.translatesAutoresizingMaskIntoConstraints = false
        resetBtn.addTarget(self, action: #selector(resetOutline), for: .touchUpInside)
        contentStack.addArrangedSubview(resetBtn)
        NSLayoutConstraint.activate([resetBtn.heightAnchor.constraint(equalToConstant: 50)])
        
        let colorLabel = UILabel()
        colorLabel.text = "颜色"
        colorLabel.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        colorLabel.textColor = .white
        colorLabel.textAlignment = .center
        contentStack.addArrangedSubview(colorLabel)
        
        let colorStack = UIStackView()
        colorStack.axis = .vertical
        colorStack.spacing = 4
        colorStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.addArrangedSubview(colorStack)
        
        let cols = 4
        let btnSize: CGFloat = 14
        for row in 0..<(colors.count + cols - 1) / cols {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.spacing = 2
            rowStack.distribution = .fillEqually
            rowStack.translatesAutoresizingMaskIntoConstraints = false
            colorStack.addArrangedSubview(rowStack)
            
            for col in 0..<cols {
                let index = row * cols + col
                if index >= colors.count { break }
                
                let btn = UIButton()
                btn.backgroundColor = colors[index]
                btn.layer.cornerRadius = btnSize / 2
                btn.layer.borderWidth = currentColor.isEqual(colors[index]) ? 2 : 0
                btn.layer.borderColor = UIColor.white.cgColor
                btn.tag = index
                btn.addTarget(self, action: #selector(colorSelected(_:)), for: .touchUpInside)
                rowStack.addArrangedSubview(btn)
                colorButtons.append(btn)
                
                NSLayoutConstraint.activate([
                    btn.widthAnchor.constraint(equalToConstant: btnSize),
                    btn.heightAnchor.constraint(equalToConstant: btnSize)
                ])
            }
        }
        
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: toolBarScrollView.topAnchor, constant: 12),
            contentStack.leadingAnchor.constraint(equalTo: toolBarScrollView.leadingAnchor, constant: 10),
            contentStack.trailingAnchor.constraint(equalTo: toolBarScrollView.trailingAnchor, constant: -10),
            contentStack.widthAnchor.constraint(equalToConstant: 60),
            contentStack.bottomAnchor.constraint(equalTo: toolBarScrollView.bottomAnchor, constant: -12)
        ])
        
        toolBarScrollView.contentSize = CGSize(width: 80, height: 600)
    }
    
    @objc private func toggleToolBar() {
        isToolBarExpanded = !isToolBarExpanded
        
        UIView.animate(withDuration: 0.3) {
            self.toolBarContainer.transform = self.isToolBarExpanded ? .identity : CGAffineTransform(translationX: 80, y: 0)
        }
    }
    
    @objc private func switchMode() {
        if currentMode == .freeDraw {
            currentMode = .colorFill
            canvasView.setMode(.colorFill)
            canvasView.clear()
            setupColorFillTools()
        } else {
            currentMode = .freeDraw
            canvasView.setMode(.freeDraw)
            canvasView.clear()
            setupFreeDrawTools()
        }
    }
    
    @objc private func brushTypeSelected(_ button: UIButton) {
        let index = button.tag
        let brush = brushTypes[index]
        currentBrushType = brush.type
        canvasView.setBrushType(brush.type)
        
        for (i, btn) in brushButtons.enumerated() {
            btn.backgroundColor = i == index ? UIColor(hex: "FF6B6B") : UIColor.white.withAlphaComponent(0.2)
        }
    }
    
    @objc private func sizeStepperChanged(_ stepper: UIStepper) {
        currentBrushSize = CGFloat(stepper.value)
        canvasView.setBrushSize(currentBrushSize)
        sizeValueLabel.text = "\(Int(currentBrushSize))"
    }
    
    @objc private func colorSelected(_ button: UIButton) {
        let index = button.tag
        if index < colors.count {
            currentColor = colors[index]
            canvasView.setColor(currentColor)
            
            for (i, btn) in colorButtons.enumerated() {
                btn.layer.borderWidth = i == index ? 2 : 0
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
        guard !isImporting else { return }
        isImporting = true
        
        importManager?.openPhotoLibrary { [weak self] image in
            self?.isImporting = false
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
        let title = error == nil ? "保存成功" : "保存失败"
        let message = error == nil ? "作品已保存到相册" : error?.localizedDescription
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "好的", style: .default))
        present(alert, animated: true)
    }
}
