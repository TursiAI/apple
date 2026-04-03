import Foundation
import GRDB

public struct Memory: Identifiable, Codable, Sendable {
    public let id: UUID
    public var description: String
    public var content: String
    public var tags: [MemoryTag]
    public var type: MemoryType
    public var source: MemorySource?
    public var isPinned: Bool
    public var importance: Float
    public let createdAt: Date
    public var updatedAt: Date
    public var lastAccessedAt: Date

    public init(
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

public enum MemoryType: String, Codable, CaseIterable, Sendable {
    public case preference
    public case fact
    public case instruction
    public case context
}

public enum MemoryTag: String, Codable, CaseIterable, Sendable {
    public case personal
    public case work
    public case preferences
    public case social
    public case interests
    public case health
    public case travel
    public case other
}

public struct MemorySource: Codable, Sendable {
    public let conversationId: UUID
    public let extractedAt: Date
}

// MARK: - GRDB

public struct MemoryRecord: Codable, FetchableRecord, PersistableRecord {
    public static let databaseTableName = "memory"

    public let id: UUID
    public let description: String
    public let content: String
    public let tagsJSON: String
    public let type: String
    public let sourceJSON: String?
    public let isPinned: Bool
    public let importance: Double
    public let createdAt: Date
    public let updatedAt: Date
    public let lastAccessedAt: Date

    public init(from memory: Memory) {
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

    public func toMemory() -> Memory {
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
