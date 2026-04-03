import Foundation
import GRDB

/// Local memory storage backed by SQLite.
final class MemoryStore: Sendable {
    private let db: Database

    init(db: Database) {
        self.db = db
    }

    // MARK: - CRUD

    func save(_ memory: Memory) throws {
        let record = MemoryRecord(from: memory)
        try db.dbQueue.write { db in
            try record.save(db)
        }
    }

    func delete(_ memoryId: UUID) throws {
        try db.dbQueue.write { db in
            _ = try MemoryRecord.deleteOne(db, key: memoryId)
        }
    }

    func togglePin(_ memoryId: UUID) throws {
        try db.dbQueue.write { db in
            guard var record = try MemoryRecord.fetchOne(db, key: memoryId) else { return }
            record = MemoryRecord(from: {
                var m = record.toMemory()
                m.isPinned.toggle()
                m.importance = m.isPinned ? 1.0 : 0.5
                m.updatedAt = Date()
                return m
            }())
            try record.update(db)
        }
    }

    func get(_ memoryId: UUID) throws -> Memory? {
        try db.dbQueue.read { db in
            try MemoryRecord.fetchOne(db, key: memoryId)?.toMemory()
        }
    }

    // MARK: - Fetch

    func fetchAll() throws -> [Memory] {
        try db.dbQueue.read { db in
            try MemoryRecord
                .order(Column("isPinned").desc, Column("importance").desc, Column("updatedAt").desc)
                .fetchAll(db)
                .map { $0.toMemory() }
        }
    }

    // MARK: - Search

    func search(query: String) throws -> [Memory] {
        guard !query.isEmpty else { return try fetchAll() }
        let pattern = "%\(query)%"
        return try db.dbQueue.read { db in
            try MemoryRecord
                .filter(
                    Column("description").like(pattern)
                    || Column("content").like(pattern)
                    || Column("tagsJSON").like(pattern)
                )
                .order(Column("isPinned").desc, Column("importance").desc)
                .fetchAll(db)
                .map { $0.toMemory() }
        }
    }

    // MARK: - Context injection

    func relevantMemories(for query: String, limit: Int = 10) throws -> [Memory] {
        let pinned = try db.dbQueue.read { db in
            try MemoryRecord
                .filter(Column("isPinned") == true)
                .fetchAll(db)
                .map { $0.toMemory() }
        }

        let remaining = limit - pinned.count
        guard remaining > 0, !query.isEmpty else { return pinned }

        let pattern = "%\(query)%"
        let searched = try db.dbQueue.read { db in
            try MemoryRecord
                .filter(Column("isPinned") == false)
                .filter(
                    Column("description").like(pattern)
                    || Column("content").like(pattern)
                )
                .order(Column("importance").desc)
                .limit(remaining)
                .fetchAll(db)
                .map { $0.toMemory() }
        }

        return pinned + searched
    }
}
