import Foundation

/// Local memory storage backed by SQLite.
@MainActor
final class MemoryStore: ObservableObject {
    @Published var memories: [Memory] = []

    // MARK: - CRUD

    func save(_ memory: Memory) async throws {
        // TODO: Persist to SQLite via Database
        if let index = memories.firstIndex(where: { $0.id == memory.id }) {
            memories[index] = memory
        } else {
            memories.append(memory)
        }
    }

    func delete(_ memoryId: UUID) async throws {
        // TODO: Delete from SQLite
        memories.removeAll { $0.id == memoryId }
    }

    func togglePin(_ memoryId: UUID) async throws {
        guard let index = memories.firstIndex(where: { $0.id == memoryId }) else { return }
        memories[index].isPinned.toggle()
        memories[index].importance = memories[index].isPinned ? 1.0 : 0.5
        // TODO: Persist change
    }

    // MARK: - Search

    func search(query: String) -> [Memory] {
        guard !query.isEmpty else { return memories }
        let lowered = query.lowercased()
        return memories.filter { memory in
            memory.description.lowercased().contains(lowered)
            || memory.tags.contains { $0.rawValue.contains(lowered) }
            || memory.content.lowercased().contains(lowered)
        }
    }

    // MARK: - Context injection

    /// Returns memories relevant to the current conversation for system prompt injection.
    func relevantMemories(for query: String, limit: Int = 10) -> [Memory] {
        let pinned = memories.filter { $0.isPinned }
        let searched = search(query: query)
            .filter { !$0.isPinned }
            .prefix(limit - pinned.count)
        return pinned + searched
    }

    // MARK: - Load

    func loadAll() async throws {
        // TODO: Load from SQLite
    }
}
