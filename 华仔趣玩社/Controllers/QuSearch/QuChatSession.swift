import UIKit

struct CodableMessage: Codable {
    let id: String
    let text: String
    let isUser: Bool
    let imagePath: String?
    let videoURL: String?
    let isLoading: Bool
    let timestamp: Date
}

struct ChatSession: Codable {
    let id: String
    var title: String
    var messages: [CodableMessage]
    let createdAt: Date
    var updatedAt: Date
    
    static private var sessionsDir: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dir = docs.appendingPathComponent("ai_sessions", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }
    
    static private func sessionDir(id: String) -> URL {
        let dir = sessionsDir.appendingPathComponent(id, isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }
    
    static private func imagesDir(id: String) -> URL {
        let dir = sessionDir(id: id).appendingPathComponent("images", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }
    
    var jsonURL: URL {
        ChatSession.sessionDir(id: id).appendingPathComponent("session.json")
    }
    
    static func loadAll() -> [ChatSession] {
        let dir = sessionsDir
        guard let contents = try? FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: [.isDirectoryKey]) else { return [] }
        var sessions: [ChatSession] = []
        for item in contents where item.hasDirectoryPath {
            let jsonURL = item.appendingPathComponent("session.json")
            guard let data = try? Data(contentsOf: jsonURL),
                  let session = try? JSONDecoder().decode(ChatSession.self, from: data) else { continue }
            sessions.append(session)
        }
        return sessions.sorted { $0.updatedAt > $1.updatedAt }
    }
    
    func save() {
        try? FileManager.default.createDirectory(at: jsonURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        let data = try? JSONEncoder().encode(self)
        try? data?.write(to: jsonURL)
    }
    
    func delete() {
        let dir = ChatSession.sessionDir(id: id)
        try? FileManager.default.removeItem(at: dir)
    }
    
    static func create(title: String = "新对话") -> ChatSession {
        ChatSession(id: UUID().uuidString, title: title, messages: [], createdAt: Date(), updatedAt: Date())
    }
    
    static func saveImage(_ image: UIImage, sessionId: String, messageId: String) -> String? {
        let dir = imagesDir(id: sessionId)
        let fileURL = dir.appendingPathComponent("\(messageId).png")
        guard let data = image.pngData() else { return nil }
        try? data.write(to: fileURL)
        return fileURL.path
    }
    
    static func loadImage(path: String) -> UIImage? {
        UIImage(contentsOfFile: path)
    }
}
