import UIKit

class DrawingCanvasView: UIView {
    
    private var currentMode: DrawingMode = .freeDraw
    private var currentColor: UIColor = .black
    private var brushSize: CGFloat = 5.0
    
    private var drawingImage: UIImage?
    private var backgroundImage: UIImage?
    
    private var paths: [(path: UIBezierPath, color: UIColor, width: CGFloat)] = []
    private var currentPath: UIBezierPath?
    private var undoStack: [UIImage] = []
    private let maxUndoCount = 20
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = .white
        layer.cornerRadius = 12
        clipsToBounds = true
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 1
        addGestureRecognizer(panGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(tapGesture)
    }
    
    func setMode(_ mode: DrawingMode) {
        currentMode = mode
        setNeedsDisplay()
    }
    
    func setColor(_ color: UIColor) {
        currentColor = color
    }
    
    func setBrushSize(_ size: CGFloat) {
        brushSize = size
    }
    
    func setBackgroundImage(_ image: UIImage) {
        backgroundImage = image
        drawingImage = nil
        paths.removeAll()
        undoStack.removeAll()
        setNeedsDisplay()
    }
    
    func clear() {
        drawingImage = nil
        paths.removeAll()
        undoStack.removeAll()
        setNeedsDisplay()
    }
    
    func undo() {
        guard !undoStack.isEmpty else { return }
        drawingImage = undoStack.removeLast()
        setNeedsDisplay()
    }
    
    func exportImage() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        
        UIColor.white.setFill()
        UIRectFill(bounds)
        
        if let bg = backgroundImage {
            let rect = AVMakeRect(aspectRatio: bg.size, insideRect: bounds)
            bg.draw(in: rect)
        }
        
        drawingImage?.draw(in: bounds)
        
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard currentMode == .freeDraw else { return }
        
        let location = gesture.location(in: self)
        
        switch gesture.state {
        case .began:
            saveForUndo()
            currentPath = UIBezierPath()
            currentPath?.lineCapStyle = .round
            currentPath?.lineJoinStyle = .round
            currentPath?.move(to: location)
            
        case .changed:
            currentPath?.addLine(to: location)
            drawCurrentPath()
            
        case .ended, .cancelled:
            if let path = currentPath {
                paths.append((path: path, color: currentColor, width: brushSize))
                mergePathsToImage()
            }
            currentPath = nil
            
        default:
            break
        }
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        guard currentMode == .colorFill, backgroundImage != nil else { return }
        
        let location = gesture.location(in: self)
        saveForUndo()
        floodFill(at: location, with: currentColor)
    }
    
    private func drawCurrentPath() {
        guard let path = currentPath else { return }
        
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        
        drawingImage?.draw(in: bounds)
        
        currentColor.setStroke()
        path.lineWidth = brushSize
        path.stroke()
        
        drawingImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        setNeedsDisplay()
    }
    
    private func mergePathsToImage() {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        
        UIColor.white.setFill()
        UIRectFill(bounds)
        
        drawingImage?.draw(in: bounds)
        
        for item in paths {
            item.color.setStroke()
            item.path.lineWidth = item.width
            item.path.stroke()
        }
        
        drawingImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        paths.removeAll()
        setNeedsDisplay()
    }
    
    private func floodFill(at point: CGPoint, with color: UIColor) {
        guard let bgImage = backgroundImage else { return }
        
        let rect = AVMakeRect(aspectRatio: bgImage.size, insideRect: bounds)
        
        guard rect.contains(point) else { return }
        
        let imageX = (point.x - rect.origin.x) / rect.width * bgImage.size.width
        let imageY = (point.y - rect.origin.y) / rect.height * bgImage.size.height
        let imagePoint = CGPoint(x: imageX, y: imageY)
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            if let filledImage = self.floodFillImage(bgImage, at: imagePoint, with: color) {
                DispatchQueue.main.async {
                    self.backgroundImage = filledImage
                    self.setNeedsDisplay()
                }
            }
        }
    }
    
    private func floodFillImage(_ image: UIImage, at point: CGPoint, with fillColor: UIColor) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        
        let width = cgImage.width
        let height = cgImage.height
        
        guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB),
              let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            return nil
        }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        guard let pixelData = context.data else { return nil }
        let data = pixelData.assumingMemoryBound(to: UInt8.self)
        
        let x = Int(point.x)
        let y = Int(point.y)
        
        guard x >= 0, x < width, y >= 0, y < height else { return nil }
        
        let targetColor = getPixelColor(data: data, x: x, y: y, width: width)
        
        var fillRed: CGFloat = 0
        var fillGreen: CGFloat = 0
        var fillBlue: CGFloat = 0
        var fillAlpha: CGFloat = 0
        fillColor.getRed(&fillRed, green: &fillGreen, blue: &fillBlue, alpha: &fillAlpha)
        
        let fillR = UInt8(fillRed * 255)
        let fillG = UInt8(fillGreen * 255)
        let fillB = UInt8(fillBlue * 255)
        
        if abs(Int(targetColor.r) - Int(fillR)) < 10 &&
           abs(Int(targetColor.g) - Int(fillG)) < 10 &&
           abs(Int(targetColor.b) - Int(fillB)) < 10 {
            return image
        }
        
        var stack: [(Int, Int)] = [(x, y)]
        var visited = Set<String>()
        
        let tolerance: UInt8 = 30
        
        while !stack.isEmpty {
            let (cx, cy) = stack.removeLast()
            let key = "\(cx),\(cy)"
            
            if visited.contains(key) { continue }
            if cx < 0 || cx >= width || cy < 0 || cy >= height { continue }
            
            let currentColor = getPixelColor(data: data, x: cx, y: cy, width: width)
            
            if abs(Int(currentColor.r) - Int(targetColor.r)) > tolerance ||
               abs(Int(currentColor.g) - Int(targetColor.g)) > tolerance ||
               abs(Int(currentColor.b) - Int(targetColor.b)) > tolerance {
                continue
            }
            
            visited.insert(key)
            setPixelColor(data: data, x: cx, y: cy, width: width, r: fillR, g: fillG, b: fillB)
            
            stack.append((cx + 1, cy))
            stack.append((cx - 1, cy))
            stack.append((cx, cy + 1))
            stack.append((cx, cy - 1))
            
            if visited.count > 500000 { break }
        }
        
        if let newCGImage = context.makeImage() {
            return UIImage(cgImage: newCGImage)
        }
        
        return nil
    }
    
    private func getPixelColor(data: UnsafeMutablePointer<UInt8>, x: Int, y: Int, width: Int) -> (r: UInt8, g: UInt8, b: UInt8, a: UInt8) {
        let offset = 4 * (y * width + x)
        return (data[offset], data[offset + 1], data[offset + 2], data[offset + 3])
    }
    
    private func setPixelColor(data: UnsafeMutablePointer<UInt8>, x: Int, y: Int, width: Int, r: UInt8, g: UInt8, b: UInt8) {
        let offset = 4 * (y * width + x)
        data[offset] = r
        data[offset + 1] = g
        data[offset + 2] = b
        data[offset + 3] = 255
    }
    
    private func saveForUndo() {
        guard let image = exportImage() else { return }
        undoStack.append(image)
        if undoStack.count > maxUndoCount {
            undoStack.removeFirst()
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        UIColor.white.setFill()
        context.fill(bounds)
        
        if let bg = backgroundImage {
            let rect = AVMakeRect(aspectRatio: bg.size, insideRect: bounds)
            context.interpolationQuality = .high
            context.draw(bg.cgImage!, in: rect)
        }
        
        drawingImage?.draw(in: bounds)
    }
}
