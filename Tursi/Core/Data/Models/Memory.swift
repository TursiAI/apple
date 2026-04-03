import Foundation

struct Memory: Identifiable, Codable {
    let id: UUID
    var description: String        // plaintext, searchable summary
    var content: String            // full detail (E2EE in cloud)
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

enum MemoryType: String, Codable, CaseIterable {
    case preference    // "likes oat milk", "prefers concise answers"
    case fact          // "works at Acme Corp", "has a dog named Rex"
    case instruction   // "always respond in Spanish"
    case context       // "working on a Swift app called Tursi"
}

enum MemoryTag: String, Codable, CaseIterable {
    case personal
    case work
    case preferences
    case social
    case interests
    case health
    case travel
    case other
}

struct MemorySource: Codable {
    let conversationId: UUID
    let extractedAt: Date
}
