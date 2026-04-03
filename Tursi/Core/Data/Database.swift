import Foundation
import GRDB

/// Manages the local SQLite database.
final class Database: Sendable {
    let dbQueue: DatabaseQueue

    /// Open (or create) the database at the standard app location.
    init() throws {
        let url = try FileManager.default
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("tursi.sqlite")
        dbQueue = try DatabaseQueue(path: url.path)
        try migrate()
    }

    /// In-memory database for tests.
    init(inMemory: Bool) throws {
        dbQueue = try DatabaseQueue()
        try migrate()
    }

    private func migrate() throws {
        var migrator = DatabaseMigrator()

        migrator.registerMigration("v1") { db in
            try db.create(table: "conversation") { t in
                t.column("id", .text).primaryKey()
                t.column("title", .text).notNull().defaults(to: "New Conversation")
                t.column("createdAt", .datetime).notNull()
                t.column("updatedAt", .datetime).notNull()
                t.column("isArchived", .boolean).notNull().defaults(to: false)
            }

            try db.create(table: "message") { t in
                t.column("id", .text).primaryKey()
                t.column("conversationId", .text).notNull()
                    .references("conversation", onDelete: .cascade)
                t.column("role", .text).notNull()
                t.column("content", .text).notNull()
                t.column("toolCallsJSON", .text)
                t.column("toolResultsJSON", .text)
                t.column("timestamp", .datetime).notNull()
            }

            try db.create(table: "memory") { t in
                t.column("id", .text).primaryKey()
                t.column("description", .text).notNull()
                t.column("content", .text).notNull()
                t.column("tagsJSON", .text).notNull().defaults(to: "[]")
                t.column("type", .text).notNull().defaults(to: "fact")
                t.column("sourceJSON", .text)
                t.column("isPinned", .boolean).notNull().defaults(to: false)
                t.column("importance", .double).notNull().defaults(to: 0.5)
                t.column("createdAt", .datetime).notNull()
                t.column("updatedAt", .datetime).notNull()
                t.column("lastAccessedAt", .datetime).notNull()
            }
        }

        try migrator.migrate(dbQueue)
    }
}
