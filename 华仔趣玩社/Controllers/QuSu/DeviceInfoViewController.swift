import UIKit

class DeviceInfoViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = Theme.gradientTop
        
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)
        
        let deviceInfo = getDeviceInfo()
        
        for (title, value) in deviceInfo {
            let card = createInfoCard(title: title, value: value)
            stackView.addArrangedSubview(card)
        }
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20)
        ])
        
        title = "设备信息"
    }
    
    private func getDeviceInfo() -> [(String, String)] {
        let device = UIDevice.current
        let processInfo = ProcessInfo.processInfo
        
        var info: [(String, String)] = []
        
        info.append(("设备型号", getDeviceModel()))
        info.append(("设备名称", device.name))
        info.append(("系统版本", "\(device.systemName) \(device.systemVersion)"))
        info.append(("系统架构", getArchitecture()))
        info.append(("总内存", String(format: "%.1f GB", Double(processInfo.physicalMemory) / 1_073_741_824)))
        info.append(("处理器核心", "\(processInfo.processorCount) 核"))
        info.append(("可用存储", getAvailableStorage()))
        info.append(("总存储", getTotalStorage()))
        info.append(("电池状态", device.isBatteryMonitoringEnabled ? "\(Int(device.batteryLevel * 100))%" : "未知"))
        info.append(("屏幕尺寸", getScreenSize()))
        info.append(("屏幕分辨率", getScreenResolution()))
        info.append(("设备语言", device.languageCode ?? "未知"))
        info.append(("时区", TimeZone.current.identifier))
        info.append(("运营商", getCarrier()))
        
        return info
    }
    
    private func getDeviceModel() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        let modelMap: [String: String] = [
            "iPad4,1": "iPad Air (Wi-Fi)",
            "iPad4,2": "iPad Air (Wi-Fi+Cellular)",
            "iPad4,3": "iPad Air (Wi-Fi+Cellular)",
            "iPad5,3": "iPad Air 2 (Wi-Fi)",
            "iPad5,4": "iPad Air 2 (Wi-Fi+Cellular)",
            "iPad11,3": "iPad Air 3 (Wi-Fi)",
            "iPad11,4": "iPad Air 3 (Wi-Fi+Cellular)",
            "iPad13,1": "iPad Air 4 (Wi-Fi)",
            "iPad13,2": "iPad Air 4 (Wi-Fi+Cellular)"
        ]
        
        return modelMap[identifier] ?? identifier
    }
    
    private func getArchitecture() -> String {
        #if arch(arm64)
        return "ARM64"
        #elseif arch(arm)
        return "ARM"
        #elseif arch(x86_64)
        return "x86_64"
        #elseif arch(i386)
        return "i386"
        #else
        return "未知"
        #endif
    }
    
    private func getAvailableStorage() -> String {
        let fileManager = FileManager.default
        do {
            let attributes = try fileManager.attributesOfFileSystem(forPath: NSHomeDirectory())
            if let freeSize = attributes[.systemFreeSize] as? UInt64 {
                return String(format: "%.1f GB", Double(freeSize) / 1_073_741_824)
            }
        } catch {}
        return "未知"
    }
    
    private func getTotalStorage() -> String {
        let fileManager = FileManager.default
        do {
            let attributes = try fileManager.attributesOfFileSystem(forPath: NSHomeDirectory())
            if let totalSize = attributes[.systemSize] as? UInt64 {
                return String(format: "%.1f GB", Double(totalSize) / 1_073_741_824)
            }
        } catch {}
        return "未知"
    }
    
    private func getScreenSize() -> String {
        let screen = UIScreen.main
        let size = screen.bounds.size
        let scale = screen.scale
        let physicalWidth = size.width * scale / 25.4
        let physicalHeight = size.height * scale / 25.4
        let diagonal = sqrt(physicalWidth * physicalWidth + physicalHeight * physicalHeight)
        return String(format: "%.1f 英寸", diagonal)
    }
    
    private func getScreenResolution() -> String {
        let screen = UIScreen.main
        let size = screen.bounds.size
        let scale = screen.scale
        return String(format: "%.0f × %.0f", size.width * scale, size.height * scale)
    }
    
    private func getCarrier() -> String {
        return "未获取"
    }
    
    private func createInfoCard(title: String, value: String) -> UIView {
        let card = UIView()
        card.backgroundColor = Theme.cardBackground.withAlphaComponent(0.6)
        card.layer.cornerRadius = 12
        card.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = Theme.Font.regular(size: 14)
        titleLabel.textColor = Theme.mutedGray
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(titleLabel)
        
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = Theme.Font.bold(size: 18)
        valueLabel.textColor = Theme.brightWhite
        valueLabel.textAlignment = .right
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            card.heightAnchor.constraint(equalToConstant: 60),
            
            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            
            valueLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            valueLabel.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            valueLabel.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 16)
        ])
        
        return card
    }
}

extension UIDevice {
    var languageCode: String? {
        return Locale.preferredLanguages.first?.components(separatedBy: "-").first ?? "zh"
    }
}
