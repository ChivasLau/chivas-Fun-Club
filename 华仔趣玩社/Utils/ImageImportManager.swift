import UIKit
import Photos
import MobileCoreServices
import AVFoundation

class ImageImportManager: NSObject {
    private weak var parentVC: UIViewController?
    private var completion: ((UIImage?) -> Void)?
    
    init(vc: UIViewController) {
        self.parentVC = vc
        super.init()
    }
    
    func openPhotoLibrary(completion: @escaping (UIImage?) -> Void) {
        self.completion = completion
        
        let status = PHPhotoLibrary.authorizationStatus()
        
        switch status {
        case .authorized:
            presentPicker()
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { [weak self] newStatus in
                DispatchQueue.main.async {
                    if newStatus == .authorized {
                        self?.presentPicker()
                    } else {
                        self?.showPermissionAlert()
                    }
                }
            }
        default:
            showPermissionAlert()
        }
    }
    
    private func presentPicker() {
        guard let parentVC = parentVC else { return }
        
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = false
        picker.mediaTypes = [kUTTypeImage as String]
        parentVC.present(picker, animated: true)
    }
    
    func openCamera(completion: @escaping (UIImage?) -> Void) {
        self.completion = completion
        
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            showCameraUnavailableAlert()
            completion(nil)
            return
        }
        
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
        case .authorized:
            presentCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    if granted {
                        self?.presentCamera()
                    } else {
                        self?.showCameraPermissionAlert()
                    }
                }
            }
        default:
            showCameraPermissionAlert()
        }
    }
    
    private func presentCamera() {
        guard let parentVC = parentVC else { return }
        
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        picker.allowsEditing = false
        picker.mediaTypes = [kUTTypeImage as String]
        parentVC.present(picker, animated: true)
    }
    
    private func showCameraPermissionAlert() {
        guard let parentVC = parentVC else { return }
        
        let alert = UIAlertController(
            title: "需要相机权限",
            message: "请在设置中开启相机权限，才能拍照哦～",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "去设置", style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        })
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        parentVC.present(alert, animated: true)
    }
    
    private func showCameraUnavailableAlert() {
        guard let parentVC = parentVC else { return }
        
        let alert = UIAlertController(
            title: "相机不可用",
            message: "您的设备不支持拍照功能",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        parentVC.present(alert, animated: true)
    }
    
    private func showPermissionAlert() {
        guard let parentVC = parentVC else { return }
        
        let alert = UIAlertController(
            title: "需要相册权限",
            message: "请在设置中开启相册权限，才能导入图片哦～",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "去设置", style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        })
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        parentVC.present(alert, animated: true)
    }
    
    private func resizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        let ratio = min(widthRatio, heightRatio, 1.0)
        
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage ?? image
    }
}

extension ImageImportManager: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        var selectedImage: UIImage?
        
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImage = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            selectedImage = originalImage
        }
        
        if let image = selectedImage {
            let resizedImage = resizeImage(image, targetSize: CGSize(width: 1920, height: 1200))
            let completionCopy = completion
            completion = nil
            completionCopy?(resizedImage)
        } else {
            let completionCopy = completion
            completion = nil
            completionCopy?(nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
        let completionCopy = completion
        completion = nil
        completionCopy?(nil)
    }
}
