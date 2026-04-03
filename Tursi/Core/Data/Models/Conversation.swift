import Foundation
import GRDB

public struct Conversation: Identifiable, Codable, Sendable {
    public let id: UUID
    public var title: String
    public let createdAt: Date
    public var updatedAt: Date
    public var isArchived: Bool

    public init(id: UUID = UUID(), title: String = "New Conversation", isArchived: Bool = false) {
        self.id = id
        self.title = title
        self.createdAt = Date()
        self.updatedAt = Date()
        self.isArchived = isArchived
    }
}

extension Conversation: FetchableRecord, PersistableRecord {
    public static let databaseTableName = "conversation"
}
