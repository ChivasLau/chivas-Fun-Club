import UIKit

class DrawingBoardViewController: UIViewController {
    
    private var canvasView: DrawingCanvasView!
    private var toolBarContainer: UIView!
    private var toolBarScrollView: UIScrollView!
    private var expandButton: UIButton!
    
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
    private var sizeLabel: UILabel!
    
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
        
        setupToolBar()
    }
    
    private func setupToolBar() {
        toolBarContainer = UIView()
        toolBarContainer.backgroundColor = UIColor.black.withAlphaComponent(0.85)
        toolBarContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toolBarContainer)
        
        expandButton = UIButton(type: .system)
        expandButton.setTitle("◀", for: .normal)
        expandButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        expandButton.setTitleColor(.white, for: .normal)
        expandButton.backgroundColor = UIColor(hex: "FF6B6B")
        expandButton.layer.cornerRadius = 25
        expandButton.translatesAutoresizingMaskIntoConstraints = false
        expandButton.addTarget(self, action: #selector(toggleToolBar), for: .touchUpInside)
        view.addSubview(expandButton)
        
        let topBar = UIView()
        topBar.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        topBar.translatesAutoresizingMaskIntoConstraints = false
        toolBarContainer.addSubview(topBar)
        
        let modeButton = UIButton(type: .system)
        modeButton.setTitle("切换", for: .normal)
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
        undoButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        undoButton.translatesAutoresizingMaskIntoConstraints = false
        undoButton.addTarget(self, action: #selector(undoAction), for: .touchUpInside)
        topBar.addSubview(undoButton)
        
        let clearButton = UIButton(type: .system)
        clearButton.setTitle("🗑️", for: .normal)
        clearButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        clearButton.addTarget(self, action: #selector(clearCanvas), for: .touchUpInside)
        topBar.addSubview(clearButton)
        
        let saveButton = UIButton(type: .system)
        saveButton.setTitle("💾", for: .normal)
        saveButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.addTarget(self, action: #selector(saveAction), for: .touchUpInside)
        topBar.addSubview(saveButton)
        
        toolBarScrollView = UIScrollView()
        toolBarScrollView.translatesAutoresizingMaskIntoConstraints = false
        toolBarScrollView.alwaysBounceVertical = true
        toolBarContainer.addSubview(toolBarScrollView)
        
        NSLayoutConstraint.activate([
            toolBarContainer.topAnchor.constraint(equalTo: view.topAnchor),
            toolBarContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolBarContainer.widthAnchor.constraint(equalToConstant: 100),
            toolBarContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            expandButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            expandButton.trailingAnchor.constraint(equalTo: toolBarContainer.leadingAnchor, constant: -8),
            expandButton.widthAnchor.constraint(equalToConstant: 50),
            expandButton.heightAnchor.constraint(equalToConstant: 50),
            
            topBar.topAnchor.constraint(equalTo: toolBarContainer.topAnchor),
            topBar.leadingAnchor.constraint(equalTo: toolBarContainer.leadingAnchor),
            topBar.trailingAnchor.constraint(equalTo: toolBarContainer.trailingAnchor),
            topBar.heightAnchor.constraint(equalToConstant: 50),
            
            modeButton.leadingAnchor.constraint(equalTo: topBar.leadingAnchor, constant: 8),
            modeButton.centerYAnchor.constraint(equalTo: topBar.centerYAnchor),
            modeButton.widthAnchor.constraint(equalToConstant: 50),
            modeButton.heightAnchor.constraint(equalToConstant: 30),
            
            saveButton.trailingAnchor.constraint(equalTo: topBar.trailingAnchor, constant: -8),
            saveButton.centerYAnchor.constraint(equalTo: topBar.centerYAnchor),
            
            clearButton.trailingAnchor.constraint(equalTo: saveButton.leadingAnchor, constant: -8),
            clearButton.centerYAnchor.constraint(equalTo: topBar.centerYAnchor),
            
            undoButton.trailingAnchor.constraint(equalTo: clearButton.leadingAnchor, constant: -8),
            undoButton.centerYAnchor.constraint(equalTo: topBar.centerYAnchor),
            
            toolBarScrollView.topAnchor.constraint(equalTo: topBar.bottomAnchor, constant: 8),
            toolBarScrollView.leadingAnchor.constraint(equalTo: toolBarContainer.leadingAnchor),
            toolBarScrollView.trailingAnchor.constraint(equalTo: toolBarContainer.trailingAnchor),
            toolBarScrollView.bottomAnchor.constraint(equalTo: toolBarContainer.bottomAnchor, constant: -8)
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
        contentStack.spacing = 12
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        toolBarScrollView.addSubview(contentStack)
        
        let brushLabel = UILabel()
        brushLabel.text = "画笔"
        brushLabel.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        brushLabel.textColor = .white
        brushLabel.textAlignment = .center
        contentStack.addArrangedSubview(brushLabel)
        
        let brushGrid = UIStackView()
        brushGrid.axis = .vertical
        brushGrid.spacing = 4
        brushGrid.distribution = .fillEqually
        brushGrid.translatesAutoresizingMaskIntoConstraints = false
        contentStack.addArrangedSubview(brushGrid)
        
        let rows = brushTypes.count % 2 == 0 ? brushTypes.count / 2 : (brushTypes.count + 1) / 2
        for row in 0..<rows {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.spacing = 4
            rowStack.distribution = .fillEqually
            rowStack.translatesAutoresizingMaskIntoConstraints = false
            brushGrid.addArrangedSubview(rowStack)
            
            for col in 0..<2 {
                let index = row * 2 + col
                if index >= brushTypes.count { break }
                
                let brush = brushTypes[index]
                let btn = UIButton()
                btn.setTitle(brush.icon, for: .normal)
                btn.titleLabel?.font = UIFont.systemFont(ofSize: 22)
                btn.backgroundColor = currentBrushType == brush.type ? UIColor(hex: "FF6B6B") : UIColor.white.withAlphaComponent(0.15)
                btn.layer.cornerRadius = 8
                btn.tag = index
                btn.translatesAutoresizingMaskIntoConstraints = false
                btn.addTarget(self, action: #selector(brushTypeSelected(_:)), for: .touchUpInside)
                rowStack.addArrangedSubview(btn)
                brushButtons.append(btn)
                
                NSLayoutConstraint.activate([
                    btn.heightAnchor.constraint(equalToConstant: 40)
                ])
            }
        }
        
        let sizeLabelTitle = UILabel()
        sizeLabelTitle.text = "大小"
        sizeLabelTitle.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        sizeLabelTitle.textColor = .white
        sizeLabelTitle.textAlignment = .center
        contentStack.addArrangedSubview(sizeLabelTitle)
        
        sizeLabel = UILabel()
        sizeLabel.text = "\(Int(currentBrushSize))"
        sizeLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        sizeLabel.textColor = UIColor(hex: "00D4AA")
        sizeLabel.textAlignment = .center
        contentStack.addArrangedSubview(sizeLabel)
        
        let sizeSlider = UISlider()
        sizeSlider.minimumValue = 1
        sizeSlider.maximumValue = 50
        sizeSlider.value = Float(currentBrushSize)
        sizeSlider.tintColor = UIColor(hex: "00D4AA")
        sizeSlider.translatesAutoresizingMaskIntoConstraints = false
        sizeSlider.addTarget(self, action: #selector(sizeSliderChanged(_:)), for: .valueChanged)
        contentStack.addArrangedSubview(sizeSlider)
        
        let colorLabel = UILabel()
        colorLabel.text = "颜色"
        colorLabel.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        colorLabel.textColor = .white
        colorLabel.textAlignment = .center
        contentStack.addArrangedSubview(colorLabel)
        
        let colorGrid = UIStackView()
        colorGrid.axis = .vertical
        colorGrid.spacing = 6
        colorGrid.translatesAutoresizingMaskIntoConstraints = false
        contentStack.addArrangedSubview(colorGrid)
        
        let cols = 4
        let colorRows = (colors.count + cols - 1) / cols
        for row in 0..<colorRows {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.spacing = 4
            rowStack.distribution = .fillEqually
            rowStack.translatesAutoresizingMaskIntoConstraints = false
            colorGrid.addArrangedSubview(rowStack)
            
            for col in 0..<cols {
                let index = row * cols + col
                if index >= colors.count { break }
                
                let btn = UIButton()
                btn.backgroundColor = colors[index]
                btn.layer.cornerRadius = 10
                btn.layer.borderWidth = currentColor.isEqual(colors[index]) ? 3 : 1
                btn.layer.borderColor = currentColor.isEqual(colors[index]) ? UIColor.white.cgColor : UIColor.white.withAlphaComponent(0.3).cgColor
                btn.tag = index
                btn.translatesAutoresizingMaskIntoConstraints = false
                btn.addTarget(self, action: #selector(colorSelected(_:)), for: .touchUpInside)
                rowStack.addArrangedSubview(btn)
                colorButtons.append(btn)
                
                NSLayoutConstraint.activate([
                    btn.heightAnchor.constraint(equalToConstant: 20)
                ])
            }
        }
        
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: toolBarScrollView.topAnchor, constant: 8),
            contentStack.leadingAnchor.constraint(equalTo: toolBarScrollView.leadingAnchor, constant: 8),
            contentStack.trailingAnchor.constraint(equalTo: toolBarScrollView.trailingAnchor, constant: -8),
            contentStack.bottomAnchor.constraint(lessThanOrEqualTo: toolBarScrollView.bottomAnchor, constant: -8),
            contentStack.widthAnchor.constraint(equalToConstant: 84)
        ])
        
        toolBarScrollView.contentSize = CGSize(width: 100, height: 700)
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
        importBtn.setTitle("📷\n导入", for: .normal)
        importBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        importBtn.titleLabel?.numberOfLines = 2
        importBtn.titleLabel?.textAlignment = .center
        importBtn.setTitleColor(.white, for: .normal)
        importBtn.backgroundColor = UIColor(hex: "00D4AA")
        importBtn.layer.cornerRadius = 10
        importBtn.translatesAutoresizingMaskIntoConstraints = false
        importBtn.addTarget(self, action: #selector(importImage), for: .touchUpInside)
        contentStack.addArrangedSubview(importBtn)
        
        let resetBtn = UIButton(type: .system)
        resetBtn.setTitle("🔄\n重置", for: .normal)
        resetBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        resetBtn.titleLabel?.numberOfLines = 2
        resetBtn.titleLabel?.textAlignment = .center
        resetBtn.setTitleColor(.white, for: .normal)
        resetBtn.backgroundColor = UIColor.orange
        resetBtn.layer.cornerRadius = 10
        resetBtn.translatesAutoresizingMaskIntoConstraints = false
        resetBtn.addTarget(self, action: #selector(resetOutline), for: .touchUpInside)
        contentStack.addArrangedSubview(resetBtn)
        
        NSLayoutConstraint.activate([
            importBtn.heightAnchor.constraint(equalToConstant: 60),
            resetBtn.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        let colorLabel = UILabel()
        colorLabel.text = "填色颜色"
        colorLabel.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        colorLabel.textColor = .white
        colorLabel.textAlignment = .center
        contentStack.addArrangedSubview(colorLabel)
        
        let colorGrid = UIStackView()
        colorGrid.axis = .vertical
        colorGrid.spacing = 6
        colorGrid.translatesAutoresizingMaskIntoConstraints = false
        contentStack.addArrangedSubview(colorGrid)
        
        let cols = 4
        let colorRows = (colors.count + cols - 1) / cols
        for row in 0..<colorRows {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.spacing = 4
            rowStack.distribution = .fillEqually
            rowStack.translatesAutoresizingMaskIntoConstraints = false
            colorGrid.addArrangedSubview(rowStack)
            
            for col in 0..<cols {
                let index = row * cols + col
                if index >= colors.count { break }
                
                let btn = UIButton()
                btn.backgroundColor = colors[index]
                btn.layer.cornerRadius = 10
                btn.layer.borderWidth = currentColor.isEqual(colors[index]) ? 3 : 1
                btn.layer.borderColor = currentColor.isEqual(colors[index]) ? UIColor.white.cgColor : UIColor.white.withAlphaComponent(0.3).cgColor
                btn.tag = index
                btn.translatesAutoresizingMaskIntoConstraints = false
                btn.addTarget(self, action: #selector(colorSelected(_:)), for: .touchUpInside)
                rowStack.addArrangedSubview(btn)
                colorButtons.append(btn)
                
                NSLayoutConstraint.activate([
                    btn.heightAnchor.constraint(equalToConstant: 20)
                ])
            }
        }
        
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: toolBarScrollView.topAnchor, constant: 8),
            contentStack.leadingAnchor.constraint(equalTo: toolBarScrollView.leadingAnchor, constant: 8),
            contentStack.trailingAnchor.constraint(equalTo: toolBarScrollView.trailingAnchor, constant: -8),
            contentStack.bottomAnchor.constraint(lessThanOrEqualTo: toolBarScrollView.bottomAnchor, constant: -8),
            contentStack.widthAnchor.constraint(equalToConstant: 84)
        ])
        
        toolBarScrollView.contentSize = CGSize(width: 100, height: 500)
    }
    
    @objc private func toggleToolBar() {
        isToolBarExpanded = !isToolBarExpanded
        
        UIView.animate(withDuration: 0.3) {
            if self.isToolBarExpanded {
                self.toolBarContainer.transform = .identity
                self.expandButton.setTitle("◀", for: .normal)
            } else {
                self.toolBarContainer.transform = CGAffineTransform(translationX: 100, y: 0)
                self.expandButton.setTitle("▶", for: .normal)
            }
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
            btn.backgroundColor = i == index ? UIColor(hex: "FF6B6B") : UIColor.white.withAlphaComponent(0.15)
        }
    }
    
    @objc private func sizeSliderChanged(_ slider: UISlider) {
        currentBrushSize = CGFloat(slider.value)
        canvasView.setBrushSize(currentBrushSize)
        sizeLabel.text = "\(Int(currentBrushSize))"
    }
    
    @objc private func colorSelected(_ button: UIButton) {
        let index = button.tag
        if index < colors.count {
            currentColor = colors[index]
            canvasView.setColor(currentColor)
            
            for (i, btn) in colorButtons.enumerated() {
                btn.layer.borderWidth = i == index ? 3 : 1
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
