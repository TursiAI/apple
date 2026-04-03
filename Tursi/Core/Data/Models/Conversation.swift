import Foundation
import GRDB

struct Conversation: Identifiable, Codable, Sendable {
    let id: UUID
    var title: String
    let createdAt: Date
    var updatedAt: Date
    var isArchived: Bool

    init(id: UUID = UUID(), title: String = "New Conversation", isArchived: Bool = false) {
        self.id = id
        self.title = title
        self.createdAt = Date()
        self.updatedAt = Date()
        self.isArchived = isArchived
    }
}

extension Conversation: FetchableRecord, PersistableRecord {
    static let databaseTableName = "conversation"
}
