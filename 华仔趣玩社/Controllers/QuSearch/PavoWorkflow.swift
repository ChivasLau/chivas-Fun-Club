import UIKit

enum PavoStep: Int, CaseIterable {
    case requirements = 1
    case outline
    case characters
    case generateImages
    case storyboard
    case keyframes
    case storyboardVideo
    case finalVideo

    var title: String {
        switch self {
        case .requirements: return "需求"
        case .outline: return "大纲"
        case .characters: return "角色设计"
        case .generateImages: return "生图"
        case .storyboard: return "分镜"
        case .keyframes: return "关键帧"
        case .storyboardVideo: return "分镜视频"
        case .finalVideo: return "成片"
        }
    }

    var icon: String {
        switch self {
        case .requirements: return "📋"
        case .outline: return "📝"
        case .characters: return "👥"
        case .generateImages: return "🎨"
        case .storyboard: return "🎬"
        case .keyframes: return "🖼️"
        case .storyboardVideo: return "📹"
        case .finalVideo: return "🎞️"
        }
    }

    var description: String {
        switch self {
        case .requirements: return "输入你的故事灵感"
        case .outline: return "AI 生成故事大纲"
        case .characters: return "设计角色设定"
        case .generateImages: return "生成角色形象"
        case .storyboard: return "分解分镜画面"
        case .keyframes: return "生成关键帧"
        case .storyboardVideo: return "生成分镜视频"
        case .finalVideo: return "完成成片"
        }
    }
}

struct PavoProject: Codable {
    let id: String
    var title: String
    var requirements: String
    var outline: String
    var characters: String
    var storyboard: String
    var currentStep: Int
    var createdAt: Date
    var updatedAt: Date

    static func create(title: String = "新剧本") -> PavoProject {
        PavoProject(id: UUID().uuidString, title: title, requirements: "", outline: "", characters: "", storyboard: "", currentStep: 1, createdAt: Date(), updatedAt: Date())
    }
}

class PavoProjectManager {
    static private var projectsDir: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dir = docs.appendingPathComponent("pavo_projects", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    static func projectDir(id: String) -> URL {
        let dir = projectsDir.appendingPathComponent(id, isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    static func imagesDir(id: String) -> URL {
        let dir = projectDir(id: id).appendingPathComponent("images", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    static func videosDir(id: String) -> URL {
        let dir = projectDir(id: id).appendingPathComponent("videos", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    static func loadAll() -> [PavoProject] {
        guard let contents = try? FileManager.default.contentsOfDirectory(at: projectsDir, includingPropertiesForKeys: [.isDirectoryKey]) else { return [] }
        var projects: [PavoProject] = []
        for item in contents where item.hasDirectoryPath {
            let jsonURL = item.appendingPathComponent("project.json")
            guard let data = try? Data(contentsOf: jsonURL),
                  let project = try? JSONDecoder().decode(PavoProject.self, from: data) else { continue }
            projects.append(project)
        }
        return projects.sorted { $0.updatedAt > $1.updatedAt }
    }

    static func save(_ project: PavoProject) {
        let dir = projectDir(id: project.id)
        let jsonURL = dir.appendingPathComponent("project.json")
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        if let data = try? JSONEncoder().encode(project) {
            try? data.write(to: jsonURL)
        }
    }

    static func delete(_ project: PavoProject) {
        let dir = projectDir(id: project.id)
        try? FileManager.default.removeItem(at: dir)
    }

    static func saveImage(_ image: UIImage, projectId: String, name: String) -> String? {
        let dir = imagesDir(id: projectId)
        let fileURL = dir.appendingPathComponent("\(name).png")
        guard let data = image.pngData() else { return nil }
        try? data.write(to: fileURL)
        return fileURL.path
    }

    static func loadImage(path: String) -> UIImage? {
        UIImage(contentsOfFile: path)
    }

    static func loadImage(projectId: String, name: String) -> UIImage? {
        let path = imagesDir(id: projectId).appendingPathComponent("\(name).png").path
        return UIImage(contentsOfFile: path)
    }

    static func saveVideo(data: Data, projectId: String, name: String) -> URL? {
        let dir = videosDir(id: projectId)
        let fileURL = dir.appendingPathComponent("\(name).mp4")
        try? data.write(to: fileURL)
        return fileURL
    }
}
