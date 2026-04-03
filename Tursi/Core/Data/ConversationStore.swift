import Foundation
import GRDB

/// Persists conversations and messages to SQLite.
public final class ConversationStore: Sendable {
    private let db: Database

    public init(db: Database) {
        self.db = db
    }

    // MARK: - Conversations

    public func save(_ conversation: Conversation) throws {
        try db.dbQueue.write { db in
            try conversation.save(db)
        }
    }

    public func fetchAll() throws -> [Conversation] {
        try db.dbQueue.read { db in
            try Conversation
                .order(Column("updatedAt").desc)
                .fetchAll(db)
        }
    }

    public func delete(_ conversationId: UUID) throws {
        try db.dbQueue.write { db in
            _ = try Conversation.deleteOne(db, key: conversationId)
        }
    }

    public func updateTitle(_ conversationId: UUID, title: String) throws {
        try db.dbQueue.write { db in
            guard var conv = try Conversation.fetchOne(db, key: conversationId) else { return }
            conv.title = title
            conv.updatedAt = Date()
            try conv.update(db)
        }
    }

    // MARK: - Messages

    public func saveMessage(_ message: Message) throws {
        let record = MessageRecord(from: message)
        try db.dbQueue.write { db in
            try record.save(db)
        }
        // Touch conversation updatedAt
        try db.dbQueue.write { db in
            guard var conv = try Conversation.fetchOne(db, key: message.conversationId) else { return }
            conv.updatedAt = Date()
            try conv.update(db)
        }
    }

    public func fetchMessages(for conversationId: UUID) throws -> [Message] {
        try db.dbQueue.read { db in
            try MessageRecord
                .filter(Column("conversationId") == conversationId)
                .order(Column("timestamp").asc)
                .fetchAll(db)
                .map { $0.toMessage() }
        }
    }
}
