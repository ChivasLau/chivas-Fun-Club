import UIKit
import AVFoundation

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
    case star = 5
    case heart = 6
    case triangle = 7
    case diamond = 8
    case rainbow = 9
}

class DrawingCanvasView: UIView {
    
    private var currentMode: DrawingMode = .freeDraw
    private var currentColor: UIColor = .black
    private var brushSize: CGFloat = 8.0
    private var brushType: BrushType = .normal
    
    private var drawingImage: UIImage?
    private var backgroundImage: UIImage?
    
    private var undoStack: [UIImage] = []
    private let maxUndoCount = 30
    
    private var lastPoint: CGPoint?
    private var rainbowHue: CGFloat = 0
    
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
    
    func setBrushType(_ type: BrushType) {
        brushType = type
    }
    
    func setBackgroundImage(_ image: UIImage) {
        backgroundImage = image
        drawingImage = nil
        undoStack.removeAll()
        setNeedsDisplay()
    }
    
    func clear() {
        saveForUndo()
        drawingImage = nil
        paths.removeAll()
        setNeedsDisplay()
    }
    
    func undo() {
        guard !undoStack.isEmpty else { return }
        drawingImage = undoStack.removeLast()
        setNeedsDisplay()
    }
    
    func canUndo() -> Bool {
        return !undoStack.isEmpty
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
            lastPoint = location
            
        case .changed:
            if let last = lastPoint {
                drawLine(from: last, to: location)
            }
            lastPoint = location
            
        case .ended, .cancelled:
            lastPoint = nil
            
        default:
            break
        }
    }
    
    private func drawLine(from start: CGPoint, to end: CGPoint) {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        
        drawingImage?.draw(in: bounds)
        
        let context = UIGraphicsGetCurrentContext()
        
        switch brushType {
        case .normal:
            drawNormalStroke(context: context, from: start, to: end)
        case .round:
            drawRoundStroke(context: context, from: start, to: end)
        case .square:
            drawSquareStroke(context: context, from: start, to: end)
        case .spray:
            drawSprayStroke(from: start, to: end)
        case .highlighter:
            drawHighlighterStroke(context: context, from: start, to: end)
        case .star:
            drawShapeStroke(from: start, to: end, shape: .star)
        case .heart:
            drawShapeStroke(from: start, to: end, shape: .heart)
        case .triangle:
            drawShapeStroke(from: start, to: end, shape: .triangle)
        case .diamond:
            drawShapeStroke(from: start, to: end, shape: .diamond)
        case .rainbow:
            drawRainbowStroke(context: context, from: start, to: end)
        }
        
        drawingImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        setNeedsDisplay()
    }
    
    private func drawNormalStroke(context: CGContext?, from start: CGPoint, to end: CGPoint) {
        context?.setStrokeColor(currentColor.cgColor)
        context?.setLineWidth(brushSize)
        context?.setLineCap(.round)
        context?.setLineJoin(.round)
        context?.move(to: start)
        context?.addLine(to: end)
        context?.strokePath()
    }
    
    private func drawRoundStroke(context: CGContext?, from start: CGPoint, to end: CGPoint) {
        context?.setStrokeColor(currentColor.cgColor)
        context?.setLineWidth(brushSize * 1.2)
        context?.setLineCap(.round)
        context?.setLineJoin(.round)
        context?.setShadow(offset: .zero, blur: brushSize / 2, color: currentColor.withAlphaComponent(0.3).cgColor)
        context?.move(to: start)
        context?.addLine(to: end)
        context?.strokePath()
    }
    
    private func drawSquareStroke(context: CGContext?, from start: CGPoint, to end: CGPoint) {
        context?.setStrokeColor(currentColor.cgColor)
        context?.setLineWidth(brushSize)
        context?.setLineCap(.square)
        context?.setLineJoin(.miter)
        context?.move(to: start)
        context?.addLine(to: end)
        context?.strokePath()
    }
    
    private func drawSprayStroke(from start: CGPoint, to end: CGPoint) {
        let distance = hypot(end.x - start.x, end.y - start.y)
        let steps = max(Int(distance / 3), 1)
        
        for step in 0...steps {
            let t = CGFloat(step) / CGFloat(steps)
            let x = start.x + (end.x - start.x) * t
            let y = start.y + (end.y - start.y) * t
            
            let dotCount = Int(brushSize * 2)
            for _ in 0..<dotCount {
                let angle = CGFloat.random(in: 0..<CGFloat.pi * 2)
                let radius = CGFloat.random(in: 0..<brushSize)
                let dotX = x + cos(angle) * radius
                let dotY = y + sin(angle) * radius
                
                let dotSize = CGFloat.random(in: 1...3)
                let path = UIBezierPath(arcCenter: CGPoint(x: dotX, y: dotY), radius: dotSize / 2, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
                currentColor.withAlphaComponent(CGFloat.random(in: 0.5...1.0)).setFill()
                path.fill()
            }
        }
    }
    
    private func drawHighlighterStroke(context: CGContext?, from start: CGPoint, to end: CGPoint) {
        context?.setStrokeColor(currentColor.withAlphaComponent(0.4).cgColor)
        context?.setLineWidth(brushSize * 2)
        context?.setLineCap(.square)
        context?.setBlendMode(.multiply)
        context?.move(to: start)
        context?.addLine(to: end)
        context?.strokePath()
        context?.setBlendMode(.normal)
    }
    
    private enum ShapeType {
        case star, heart, triangle, diamond
    }
    
    private func drawShapeStroke(from start: CGPoint, to end: CGPoint, shape: ShapeType) {
        let distance = hypot(end.x - start.x, end.y - start.y)
        let steps = max(Int(distance / (brushSize * 2)), 1)
        
        for step in 0...steps {
            let t = CGFloat(step) / CGFloat(steps)
            let x = start.x + (end.x - start.x) * t
            let y = start.y + (end.y - start.y) * t
            
            let shapeSize = brushSize
            let rect = CGRect(x: x - shapeSize/2, y: y - shapeSize/2, width: shapeSize, height: shapeSize)
            
            currentColor.setFill()
            
            switch shape {
            case .star:
                drawStar(in: rect)
            case .heart:
                drawHeart(in: rect)
            case .triangle:
                drawTriangle(in: rect)
            case .diamond:
                drawDiamond(in: rect)
            }
        }
    }
    
    private func drawStar(in rect: CGRect) {
        let path = UIBezierPath()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = rect.width / 2
        let innerRadius = radius * 0.4
        
        for i in 0..<10 {
            let angle = CGFloat(i) * .pi / 5 - .pi / 2
            let r = i % 2 == 0 ? radius : innerRadius
            let x = center.x + r * cos(angle)
            let y = center.y + r * sin(angle)
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        path.close()
        path.fill()
    }
    
    private func drawHeart(in rect: CGRect) {
        let path = UIBezierPath()
        let x = rect.midX
        let y = rect.midY
        let size = rect.width / 2
        
        path.move(to: CGPoint(x: x, y: y - size * 0.3))
        path.addCurve(to: CGPoint(x: x - size, y: y - size * 0.8),
                      controlPoint1: CGPoint(x: x - size * 0.5, y: y - size * 1.2),
                      controlPoint2: CGPoint(x: x - size, y: y - size))
        path.addCurve(to: CGPoint(x: x, y: y + size * 0.8),
                      controlPoint1: CGPoint(x: x - size, y: y),
                      controlPoint2: CGPoint(x: x, y: y + size * 0.5))
        path.addCurve(to: CGPoint(x: x + size, y: y - size * 0.8),
                      controlPoint1: CGPoint(x: x, y: y + size * 0.5),
                      controlPoint2: CGPoint(x: x + size, y: y))
        path.addCurve(to: CGPoint(x: x, y: y - size * 0.3),
                      controlPoint1: CGPoint(x: x + size, y: y - size),
                      controlPoint2: CGPoint(x: x + size * 0.5, y: y - size * 1.2))
        path.fill()
    }
    
    private func drawTriangle(in rect: CGRect) {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.close()
        path.fill()
    }
    
    private func drawDiamond(in rect: CGRect) {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        path.close()
        path.fill()
    }
    
    private func drawRainbowStroke(context: CGContext?, from start: CGPoint, to end: CGPoint) {
        rainbowHue = (rainbowHue + 0.02).truncatingRemainder(dividingBy: 1.0)
        let color = UIColor(hue: rainbowHue, saturation: 1.0, brightness: 1.0, alpha: 1.0)
        
        context?.setStrokeColor(color.cgColor)
        context?.setLineWidth(brushSize)
        context?.setLineCap(.round)
        context?.setLineJoin(.round)
        context?.move(to: start)
        context?.addLine(to: end)
        context?.strokePath()
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        guard currentMode == .colorFill, backgroundImage != nil else { return }
        
        let location = gesture.location(in: self)
        saveForUndo()
        floodFill(at: location, with: currentColor)
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
            
            let currentColorPixel = getPixelColor(data: data, x: cx, y: cy, width: width)
            
            if abs(Int(currentColorPixel.r) - Int(targetColor.r)) > tolerance ||
               abs(Int(currentColorPixel.g) - Int(targetColor.g)) > tolerance ||
               abs(Int(currentColorPixel.b) - Int(targetColor.b)) > tolerance {
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
