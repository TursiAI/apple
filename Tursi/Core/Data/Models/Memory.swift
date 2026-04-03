import Foundation
import GRDB

struct Memory: Identifiable, Codable, Sendable {
    let id: UUID
    var description: String
    var content: String
    var tags: [MemoryTag]
    var type: MemoryType
    var source: MemorySource?
    var isPinned: Bool
    var importance: Float
    let createdAt: Date
    var updatedAt: Date
    var lastAccessedAt: Date

    init(
        id: UUID = UUID(),
        description: String,
        content: String,
        tags: [MemoryTag] = [],
        type: MemoryType = .fact,
        source: MemorySource? = nil,
        isPinned: Bool = false,
        importance: Float = 0.5
    ) {
        self.id = id
        self.description = description
        self.content = content
        self.tags = tags
        self.type = type
        self.source = source
        self.isPinned = isPinned
        self.importance = importance
        self.createdAt = Date()
        self.updatedAt = Date()
        self.lastAccessedAt = Date()
    }
}

enum MemoryType: String, Codable, CaseIterable, Sendable {
    case preference
    case fact
    case instruction
    case context
}

enum MemoryTag: String, Codable, CaseIterable, Sendable {
    case personal
    case work
    case preferences
    case social
    case interests
    case health
    case travel
    case other
}

struct MemorySource: Codable, Sendable {
    let conversationId: UUID
    let extractedAt: Date
}

// MARK: - GRDB

struct MemoryRecord: Codable, FetchableRecord, PersistableRecord {
    static let databaseTableName = "memory"

    let id: UUID
    let description: String
    let content: String
    let tagsJSON: String
    let type: String
    let sourceJSON: String?
    let isPinned: Bool
    let importance: Double
    let createdAt: Date
    let updatedAt: Date
    let lastAccessedAt: Date

    init(from memory: Memory) {
        self.id = memory.id
        self.description = memory.description
        self.content = memory.content
        self.tagsJSON = (try? String(data: JSONEncoder().encode(memory.tags), encoding: .utf8)) ?? "[]"
        self.type = memory.type.rawValue
        self.sourceJSON = memory.source.flatMap { try? String(data: JSONEncoder().encode($0), encoding: .utf8) }
        self.isPinned = memory.isPinned
        self.importance = Double(memory.importance)
        self.createdAt = memory.createdAt
        self.updatedAt = memory.updatedAt
        self.lastAccessedAt = memory.lastAccessedAt
    }

    func toMemory() -> Memory {
        let decoder = JSONDecoder()
        let tags = tagsJSON.data(using: .utf8)
            .flatMap { try? decoder.decode([MemoryTag].self, from: $0) } ?? []
        let source = sourceJSON?
            .data(using: .utf8)
            .flatMap { try? decoder.decode(MemorySource.self, from: $0) }

        return Memory(
            id: id,
            description: description,
            content: content,
            tags: tags,
            type: MemoryType(rawValue: type) ?? .fact,
            source: source,
            isPinned: isPinned,
            importance: Float(importance)
        )
    }
}
