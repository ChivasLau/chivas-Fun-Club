import UIKit
import CoreImage

extension UIImage {
    
    func convertToColoringOutline() -> UIImage? {
        guard let ciImage = CIImage(image: self) else { return nil }
        
        let context = CIContext(options: [.useSoftwareRenderer: true])
        
        guard let grayscaleFilter = CIFilter(name: "CIPhotoEffectNoir") else { return nil }
        grayscaleFilter.setValue(ciImage, forKey: kCIInputImageKey)
        
        guard let grayscaleOutput = grayscaleFilter.outputImage else { return nil }
        
        guard let edgeFilter = CIFilter(name: "CIEdges") else { return nil }
        edgeFilter.setValue(grayscaleOutput, forKey: kCIInputImageKey)
        edgeFilter.setValue(1.0, forKey: kCIInputIntensityKey)
        
        guard let edgeOutput = edgeFilter.outputImage else { return nil }
        
        let invertedFilter = CIFilter(name: "CIColorInvert")
        invertedFilter?.setValue(edgeOutput, forKey: kCIInputImageKey)
        
        guard let finalOutput = invertedFilter?.outputImage ?? edgeOutput else { return nil }
        
        guard let cgImage = context.createCGImage(finalOutput, from: finalOutput.extent) else { return nil }
        
        return UIImage(cgImage: cgImage)
    }
    
    func convertToGrayscale() -> UIImage? {
        guard let ciImage = CIImage(image: self) else { return nil }
        
        let context = CIContext(options: [.useSoftwareRenderer: true])
        
        guard let filter = CIFilter(name: "CIPhotoEffectMono") else { return nil }
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        
        guard let output = filter.outputImage else { return nil }
        
        guard let cgImage = context.createCGImage(output, from: output.extent) else { return nil }
        
        return UIImage(cgImage: cgImage)
    }
}
