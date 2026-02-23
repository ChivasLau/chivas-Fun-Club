import UIKit

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
    var frame: CGRect = .zero
    var rotation: CGFloat = 0
    var scale: CGFloat = 1.0
    var type: ElementType = .image
    
    enum ElementType {
        case image
        case text
        case shape
    }
}

class PosterModeViewController: UIViewController {
    
    private var canvasScrollView: UIScrollView!
    private var canvasContainer: UIView!
    private var canvasView: UIView!
    private var drawingImageView: UIImageView!
    private var elementContainerView: UIView!
    
    private var toolBarView: UIView!
    private var isToolBarHidden = false
    
    private var currentCanvasSize: CanvasSize = .a4
    private var currentColor: UIColor = .black
    private var currentBrushSize: CGFloat = 4.0
    private var isEraser = false
    
    private var elements: [PosterElement] = []
    private var selectedElement: PosterElement?
    private var selectedElementView: UIView?
    
    private var importManager: ImageImportManager?
    private var currentPath: UIBezierPath?
    private var drawingLayer: CAShapeLayer?
    
    private let colors: [UIColor] = [
        .black, .white, .red, .orange, .yellow, .green, .cyan, .blue, .purple, .brown,
        UIColor(hex: "FF6B6B"), UIColor(hex: "4ECDC4"), UIColor(hex: "45B7D1"), UIColor(hex: "96CEB4"),
        UIColor(hex: "FFEAA7"), UIColor(hex: "DDA0DD"), UIColor(hex: "F368E0")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        importManager = ImageImportManager(vc: self)
    }
    
    override var prefersStatusBarHidden: Bool { return true }
    override var prefersHomeIndicatorAutoHidden: Bool { return false }
    
    private func setupUI() {
        view.backgroundColor = UIColor(hex: "1a1a2e")
        
        canvasScrollView = UIScrollView()
        canvasScrollView.minimumZoomScale = 0.3
        canvasScrollView.maximumZoomScale = 3.0
        canvasScrollView.showsVerticalScrollIndicator = true
        canvasScrollView.showsHorizontalScrollIndicator = true
        canvasScrollView.backgroundColor = UIColor(hex: "16213e")
        canvasScrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(canvasScrollView)
        
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
        
        NSLayoutConstraint.activate([
            canvasScrollView.topAnchor.constraint(equalTo: view.topAnchor),
            canvasScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            canvasScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            canvasScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            canvasContainer.topAnchor.constraint(equalTo: canvasScrollView.topAnchor, constant: 40),
            canvasContainer.centerXAnchor.constraint(equalTo: canvasScrollView.centerXAnchor),
            canvasContainer.bottomAnchor.constraint(equalTo: canvasScrollView.bottomAnchor, constant: -40),
            
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
        
        updateCanvasSize()
        setupToolBar()
        setupGestures()
    }
    
    private func updateCanvasSize() {
        let size = currentCanvasSize.size
        canvasContainer.widthAnchor.constraint(equalToConstant: size.width).isActive = true
        canvasContainer.heightAnchor.constraint(equalToConstant: size.height).isActive = true
        
        canvasView.widthAnchor.constraint(equalToConstant: size.width).isActive = true
        canvasView.heightAnchor.constraint(equalToConstant: size.height).isActive = true
        
        canvasScrollView.contentSize = CGSize(width: size.width + 80, height: size.height + 80)
    }
    
    private func setupToolBar() {
        toolBarView = UIView()
        toolBarView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        toolBarView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toolBarView)
        
        let toggleBtn = UIButton(type: .system)
        toggleBtn.setTitle("☰", for: .normal)
        toggleBtn.titleLabel?.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        toggleBtn.setTitleColor(.white, for: .normal)
        toggleBtn.translatesAutoresizingMaskIntoConstraints = false
        toggleBtn.addTarget(self, action: #selector(toggleToolBar), for: .touchUpInside)
        toolBarView.addSubview(toggleBtn)
        
        let canvasSizeBtn = UIButton(type: .system)
        canvasSizeBtn.setTitle("📐\(currentCanvasSize.name)", for: .normal)
        canvasSizeBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        canvasSizeBtn.setTitleColor(UIColor(hex: "00D4AA"), for: .normal)
        canvasSizeBtn.translatesAutoresizingMaskIntoConstraints = false
        canvasSizeBtn.addTarget(self, action: #selector(showCanvasSizePicker), for: .touchUpInside)
        toolBarView.addSubview(canvasSizeBtn)
        canvasSizeBtn.tag = 100
        
        let importBtn = UIButton(type: .system)
        importBtn.setTitle("🖼️", for: .normal)
        importBtn.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        importBtn.translatesAutoresizingMaskIntoConstraints = false
        importBtn.addTarget(self, action: #selector(importImage), for: .touchUpInside)
        toolBarView.addSubview(importBtn)
        
        let brushBtn = UIButton(type: .system)
        brushBtn.setTitle("✏️", for: .normal)
        brushBtn.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        brushBtn.translatesAutoresizingMaskIntoConstraints = false
        brushBtn.addTarget(self, action: #selector(showBrushOptions), for: .touchUpInside)
        toolBarView.addSubview(brushBtn)
        
        let fillBtn = UIButton(type: .system)
        fillBtn.setTitle("🪣", for: .normal)
        fillBtn.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        fillBtn.translatesAutoresizingMaskIntoConstraints = false
        fillBtn.addTarget(self, action: #selector(fillCanvas), for: .touchUpInside)
        toolBarView.addSubview(fillBtn)
        
        let eraserBtn = UIButton(type: .system)
        eraserBtn.setTitle("🧹", for: .normal)
        eraserBtn.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        eraserBtn.translatesAutoresizingMaskIntoConstraints = false
        eraserBtn.addTarget(self, action: #selector(toggleEraser), for: .touchUpInside)
        toolBarView.addSubview(eraserBtn)
        eraserBtn.tag = 101
        
        let clearBtn = UIButton(type: .system)
        clearBtn.setTitle("🗑️", for: .normal)
        clearBtn.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        clearBtn.translatesAutoresizingMaskIntoConstraints = false
        clearBtn.addTarget(self, action: #selector(clearCanvas), for: .touchUpInside)
        toolBarView.addSubview(clearBtn)
        
        let saveBtn = UIButton(type: .system)
        saveBtn.setTitle("💾", for: .normal)
        saveBtn.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        saveBtn.translatesAutoresizingMaskIntoConstraints = false
        saveBtn.addTarget(self, action: #selector(showSaveOptions), for: .touchUpInside)
        toolBarView.addSubview(saveBtn)
        
        NSLayoutConstraint.activate([
            toolBarView.topAnchor.constraint(equalTo: view.topAnchor),
            toolBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolBarView.heightAnchor.constraint(equalToConstant: 56),
            
            toggleBtn.leadingAnchor.constraint(equalTo: toolBarView.leadingAnchor, constant: 12),
            toggleBtn.centerYAnchor.constraint(equalTo: toolBarView.centerYAnchor),
            
            canvasSizeBtn.leadingAnchor.constraint(equalTo: toggleBtn.trailingAnchor, constant: 8),
            canvasSizeBtn.centerYAnchor.constraint(equalTo: toolBarView.centerYAnchor),
            
            saveBtn.trailingAnchor.constraint(equalTo: toolBarView.trailingAnchor, constant: -12),
            saveBtn.centerYAnchor.constraint(equalTo: toolBarView.centerYAnchor),
            
            clearBtn.trailingAnchor.constraint(equalTo: saveBtn.leadingAnchor, constant: -8),
            clearBtn.centerYAnchor.constraint(equalTo: toolBarView.centerYAnchor),
            
            eraserBtn.trailingAnchor.constraint(equalTo: clearBtn.leadingAnchor, constant: -8),
            eraserBtn.centerYAnchor.constraint(equalTo: toolBarView.centerYAnchor),
            
            fillBtn.trailingAnchor.constraint(equalTo: eraserBtn.leadingAnchor, constant: -8),
            fillBtn.centerYAnchor.constraint(equalTo: toolBarView.centerYAnchor),
            
            brushBtn.trailingAnchor.constraint(equalTo: fillBtn.leadingAnchor, constant: -8),
            brushBtn.centerYAnchor.constraint(equalTo: toolBarView.centerYAnchor),
            
            importBtn.trailingAnchor.constraint(equalTo: brushBtn.leadingAnchor, constant: -8),
            importBtn.centerYAnchor.constraint(equalTo: toolBarView.centerYAnchor)
        ])
    }
    
    private func setupGestures() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleDrawPan(_:)))
        canvasView.addGestureRecognizer(panGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleCanvasTap(_:)))
        canvasView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func toggleToolBar() {
        isToolBarHidden = !isToolBarHidden
        UIView.animate(withDuration: 0.3) {
            self.toolBarView.transform = self.isToolBarHidden ? CGAffineTransform(translationX: 0, y: -56) : .identity
        }
    }
    
    @objc private func showCanvasSizePicker() {
        let alert = UIAlertController(title: "选择画布尺寸", message: nil, preferredStyle: .actionSheet)
        
        let sizes: [CanvasSize] = [.custom, .a4, .a5, .square, .instagram]
        for size in sizes {
            alert.addAction(UIAlertAction(title: size.name, style: .default) { [weak self] _ in
                self?.currentCanvasSize = size
                if let btn = self?.toolBarView.viewWithTag(100) as? UIButton {
                    btn.setTitle("📐\(size.name)", for: .normal)
                }
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
        if let btn = toolBarView.viewWithTag(101) as? UIButton {
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
        let renderer = UIGraphicsImageRenderer(size: currentCanvasSize.size)
        let image = renderer.image { context in
            canvasView.backgroundColor?.setFill()
            context.fill(CGRect(origin: .zero, size: currentCanvasSize.size))
            drawingImageView.image?.draw(in: CGRect(origin: .zero, size: currentCanvasSize.size))
            
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
        let title = error == nil ? "保存成功" : "保存失败"
        let message = error == nil ? "海报已保存到相册" : error?.localizedDescription
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "好的", style: .default))
        present(alert, animated: true)
    }
}
