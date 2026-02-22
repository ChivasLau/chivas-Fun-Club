import UIKit

enum DrawingMode: Int {
    case freeDraw = 0
    case colorFill = 1
}

class DrawingBoardViewController: UIViewController {
    
    private var canvasView: DrawingCanvasView!
    private var topBar: UIView!
    private var toolBar: UIView!
    private var modeLabel: UILabel!
    
    private var currentMode: DrawingMode = .freeDraw
    private var currentColor: UIColor = .black
    private var currentBrushSize: CGFloat = 5.0
    
    private var importManager: ImageImportManager!
    private var cachedOutlineImage: UIImage?
    
    private let colors: [UIColor] = [
        .black, .white, .red, .orange, .yellow, .green, .cyan, .blue, .purple, .brown, .gray,
        UIColor(hex: "FF6B6B"), UIColor(hex: "4ECDC4"), UIColor(hex: "FFE66D"), UIColor(hex: "95E1D3"),
        UIColor(hex: "F38181"), UIColor(hex: "AA96DA"), UIColor(hex: "FCBAD3"), UIColor(hex: "A8D8EA")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        importManager = ImageImportManager(vc: self)
    }
    
    private func setupUI() {
        view.backgroundColor = Theme.gradientTop
        
        topBar = UIView()
        topBar.backgroundColor = Theme.cardBackground.withAlphaComponent(0.8)
        topBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topBar)
        
        let titleLabel = UILabel()
        titleLabel.text = "宝贝画板"
        titleLabel.font = Theme.Font.bold(size: 20)
        titleLabel.textColor = Theme.brightWhite
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        topBar.addSubview(titleLabel)
        
        modeLabel = UILabel()
        modeLabel.text = "自由绘画"
        modeLabel.font = Theme.Font.regular(size: 14)
        modeLabel.textColor = Theme.electricBlue
        modeLabel.translatesAutoresizingMaskIntoConstraints = false
        topBar.addSubview(modeLabel)
        
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
        clearButton.backgroundColor = UIColor.red.withAlphaComponent(0.6)
        clearButton.layer.cornerRadius = 8
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        clearButton.addTarget(self, action: #selector(clearCanvas), for: .touchUpInside)
        topBar.addSubview(clearButton)
        
        NSLayoutConstraint.activate([
            topBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topBar.heightAnchor.constraint(equalToConstant: 60),
            
            titleLabel.leadingAnchor.constraint(equalTo: topBar.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: topBar.centerYAnchor),
            
            modeLabel.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 12),
            modeLabel.centerYAnchor.constraint(equalTo: topBar.centerYAnchor),
            
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
            canvasView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -220),
            canvasView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8)
        ])
        
        setupToolBar()
        
        title = "宝贝画板"
    }
    
    private func setupToolBar() {
        toolBar = UIView()
        toolBar.backgroundColor = Theme.cardBackground.withAlphaComponent(0.8)
        toolBar.layer.cornerRadius = Theme.cornerRadius
        toolBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toolBar)
        
        NSLayoutConstraint.activate([
            toolBar.topAnchor.constraint(equalTo: topBar.bottomAnchor, constant: 8),
            toolBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            toolBar.widthAnchor.constraint(equalToConstant: 200),
            toolBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8)
        ])
        
        setupFreeDrawTools()
    }
    
    private func setupFreeDrawTools() {
        for subview in toolBar.subviews {
            subview.removeFromSuperview()
        }
        
        let brushLabel = UILabel()
        brushLabel.text = "画笔大小"
        brushLabel.font = Theme.Font.bold(size: 14)
        brushLabel.textColor = Theme.brightWhite
        brushLabel.translatesAutoresizingMaskIntoConstraints = false
        toolBar.addSubview(brushLabel)
        
        let brushSlider = UISlider()
        brushSlider.minimumValue = 1
        brushSlider.maximumValue = 30
        brushSlider.value = Float(currentBrushSize)
        brushSlider.tintColor = Theme.electricBlue
        brushSlider.translatesAutoresizingMaskIntoConstraints = false
        brushSlider.addTarget(self, action: #selector(brushSizeChanged(_:)), for: .valueChanged)
        toolBar.addSubview(brushSlider)
        
        let colorLabel = UILabel()
        colorLabel.text = "颜色"
        colorLabel.font = Theme.Font.bold(size: 14)
        colorLabel.textColor = Theme.brightWhite
        colorLabel.translatesAutoresizingMaskIntoConstraints = false
        toolBar.addSubview(colorLabel)
        
        let colorStack = UIStackView()
        colorStack.axis = .horizontal
        colorStack.spacing = 8
        colorStack.distribution = .fillEqually
        colorStack.translatesAutoresizingMaskIntoConstraints = false
        toolBar.addSubview(colorStack)
        
        for (index, color) in colors.prefix(10).enumerated() {
            let colorBtn = UIButton()
            colorBtn.backgroundColor = color
            colorBtn.layer.cornerRadius = 15
            colorBtn.layer.borderWidth = 2
            colorBtn.layer.borderColor = currentColor == color ? Theme.neonPink.cgColor : UIColor.clear.cgColor
            colorBtn.tag = index
            colorBtn.addTarget(self, action: #selector(colorSelected(_:)), for: .touchUpInside)
            colorStack.addArrangedSubview(colorBtn)
        }
        
        let undoBtn = UIButton(type: .system)
        undoBtn.setTitle("撤销", for: .normal)
        undoBtn.titleLabel?.font = Theme.Font.bold(size: 14)
        undoBtn.setTitleColor(Theme.brightWhite, for: .normal)
        undoBtn.backgroundColor = Theme.electricBlue.withAlphaComponent(0.6)
        undoBtn.layer.cornerRadius = 8
        undoBtn.translatesAutoresizingMaskIntoConstraints = false
        undoBtn.addTarget(self, action: #selector(undoAction), for: .touchUpInside)
        toolBar.addSubview(undoBtn)
        
        let saveBtn = UIButton(type: .system)
        saveBtn.setTitle("保存", for: .normal)
        saveBtn.titleLabel?.font = Theme.Font.bold(size: 14)
        saveBtn.setTitleColor(Theme.brightWhite, for: .normal)
        saveBtn.backgroundColor = Theme.neonPink.withAlphaComponent(0.6)
        saveBtn.layer.cornerRadius = 8
        saveBtn.translatesAutoresizingMaskIntoConstraints = false
        saveBtn.addTarget(self, action: #selector(saveAction), for: .touchUpInside)
        toolBar.addSubview(saveBtn)
        
        NSLayoutConstraint.activate([
            brushLabel.topAnchor.constraint(equalTo: toolBar.topAnchor, constant: 16),
            brushLabel.leadingAnchor.constraint(equalTo: toolBar.leadingAnchor, constant: 16),
            brushLabel.trailingAnchor.constraint(equalTo: toolBar.trailingAnchor, constant: -16),
            
            brushSlider.topAnchor.constraint(equalTo: brushLabel.bottomAnchor, constant: 8),
            brushSlider.leadingAnchor.constraint(equalTo: toolBar.leadingAnchor, constant: 16),
            brushSlider.trailingAnchor.constraint(equalTo: toolBar.trailingAnchor, constant: -16),
            
            colorLabel.topAnchor.constraint(equalTo: brushSlider.bottomAnchor, constant: 20),
            colorLabel.leadingAnchor.constraint(equalTo: toolBar.leadingAnchor, constant: 16),
            
            colorStack.topAnchor.constraint(equalTo: colorLabel.bottomAnchor, constant: 8),
            colorStack.leadingAnchor.constraint(equalTo: toolBar.leadingAnchor, constant: 16),
            colorStack.trailingAnchor.constraint(equalTo: toolBar.trailingAnchor, constant: -16),
            colorStack.heightAnchor.constraint(equalToConstant: 30),
            
            undoBtn.leadingAnchor.constraint(equalTo: toolBar.leadingAnchor, constant: 16),
            undoBtn.trailingAnchor.constraint(equalTo: toolBar.centerXAnchor, constant: -8),
            undoBtn.bottomAnchor.constraint(equalTo: saveBtn.topAnchor, constant: -12),
            undoBtn.heightAnchor.constraint(equalToConstant: 40),
            
            saveBtn.leadingAnchor.constraint(equalTo: toolBar.centerXAnchor, constant: 8),
            saveBtn.trailingAnchor.constraint(equalTo: toolBar.trailingAnchor, constant: -16),
            saveBtn.bottomAnchor.constraint(equalTo: toolBar.bottomAnchor, constant: -20),
            saveBtn.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    private func setupColorFillTools() {
        for subview in toolBar.subviews {
            subview.removeFromSuperview()
        }
        
        let importBtn = UIButton(type: .system)
        importBtn.setTitle("导入图片", for: .normal)
        importBtn.titleLabel?.font = Theme.Font.bold(size: 16)
        importBtn.setTitleColor(Theme.brightWhite, for: .normal)
        importBtn.backgroundColor = Theme.electricBlue
        importBtn.layer.cornerRadius = 12
        importBtn.translatesAutoresizingMaskIntoConstraints = false
        importBtn.addTarget(self, action: #selector(importImage), for: .touchUpInside)
        toolBar.addSubview(importBtn)
        
        let resetBtn = UIButton(type: .system)
        resetBtn.setTitle("重置轮廓", for: .normal)
        resetBtn.titleLabel?.font = Theme.Font.bold(size: 16)
        resetBtn.setTitleColor(Theme.brightWhite, for: .normal)
        resetBtn.backgroundColor = UIColor.orange.withAlphaComponent(0.7)
        resetBtn.layer.cornerRadius = 12
        resetBtn.translatesAutoresizingMaskIntoConstraints = false
        resetBtn.addTarget(self, action: #selector(resetOutline), for: .touchUpInside)
        toolBar.addSubview(resetBtn)
        
        let colorLabel = UILabel()
        colorLabel.text = "填色颜色"
        colorLabel.font = Theme.Font.bold(size: 14)
        colorLabel.textColor = Theme.brightWhite
        colorLabel.translatesAutoresizingMaskIntoConstraints = false
        toolBar.addSubview(colorLabel)
        
        let colorStack = UIStackView()
        colorStack.axis = .horizontal
        colorStack.spacing = 8
        colorStack.distribution = .fillEqually
        colorStack.translatesAutoresizingMaskIntoConstraints = false
        toolBar.addSubview(colorStack)
        
        for (index, color) in colors.prefix(10).enumerated() {
            let colorBtn = UIButton()
            colorBtn.backgroundColor = color
            colorBtn.layer.cornerRadius = 15
            colorBtn.layer.borderWidth = 2
            colorBtn.layer.borderColor = currentColor == color ? Theme.neonPink.cgColor : UIColor.clear.cgColor
            colorBtn.tag = index
            colorBtn.addTarget(self, action: #selector(colorSelected(_:)), for: .touchUpInside)
            colorStack.addArrangedSubview(colorBtn)
        }
        
        let saveBtn = UIButton(type: .system)
        saveBtn.setTitle("保存作品", for: .normal)
        saveBtn.titleLabel?.font = Theme.Font.bold(size: 16)
        saveBtn.setTitleColor(Theme.brightWhite, for: .normal)
        saveBtn.backgroundColor = Theme.neonPink
        saveBtn.layer.cornerRadius = 12
        saveBtn.translatesAutoresizingMaskIntoConstraints = false
        saveBtn.addTarget(self, action: #selector(saveAction), for: .touchUpInside)
        toolBar.addSubview(saveBtn)
        
        NSLayoutConstraint.activate([
            importBtn.topAnchor.constraint(equalTo: toolBar.topAnchor, constant: 20),
            importBtn.leadingAnchor.constraint(equalTo: toolBar.leadingAnchor, constant: 16),
            importBtn.trailingAnchor.constraint(equalTo: toolBar.trailingAnchor, constant: -16),
            importBtn.heightAnchor.constraint(equalToConstant: 50),
            
            resetBtn.topAnchor.constraint(equalTo: importBtn.bottomAnchor, constant: 12),
            resetBtn.leadingAnchor.constraint(equalTo: toolBar.leadingAnchor, constant: 16),
            resetBtn.trailingAnchor.constraint(equalTo: toolBar.trailingAnchor, constant: -16),
            resetBtn.heightAnchor.constraint(equalToConstant: 50),
            
            colorLabel.topAnchor.constraint(equalTo: resetBtn.bottomAnchor, constant: 24),
            colorLabel.leadingAnchor.constraint(equalTo: toolBar.leadingAnchor, constant: 16),
            
            colorStack.topAnchor.constraint(equalTo: colorLabel.bottomAnchor, constant: 8),
            colorStack.leadingAnchor.constraint(equalTo: toolBar.leadingAnchor, constant: 16),
            colorStack.trailingAnchor.constraint(equalTo: toolBar.trailingAnchor, constant: -16),
            colorStack.heightAnchor.constraint(equalToConstant: 30),
            
            saveBtn.leadingAnchor.constraint(equalTo: toolBar.leadingAnchor, constant: 16),
            saveBtn.trailingAnchor.constraint(equalTo: toolBar.trailingAnchor, constant: -16),
            saveBtn.bottomAnchor.constraint(equalTo: toolBar.bottomAnchor, constant: -20),
            saveBtn.heightAnchor.constraint(equalToConstant: 50)
        ])
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
    
    @objc private func brushSizeChanged(_ slider: UISlider) {
        currentBrushSize = CGFloat(slider.value)
        canvasView.setBrushSize(currentBrushSize)
    }
    
    @objc private func colorSelected(_ button: UIButton) {
        let index = button.tag
        if index < colors.count {
            currentColor = colors[index]
            canvasView.setColor(currentColor)
            
            for case let btn as UIButton in toolBar.subviews {
                if btn.backgroundColor?.isEqual(colors.first { $0.isEqual(btn.backgroundColor) }) == true {
                    btn.layer.borderColor = currentColor.isEqual(btn.backgroundColor) ? Theme.neonPink.cgColor : UIColor.clear.cgColor
                }
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
