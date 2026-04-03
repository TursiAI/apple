import SwiftUI
import TursiCore

struct MemoryListView: View {
    @StateObject private var store = MemoryStore()
    @State private var searchText = ""
    @State private var selectedMemory: Memory?

    private var filteredMemories: [Memory] {
        searchText.isEmpty ? store.memories : store.search(query: searchText)
    }

    private var groupedMemories: [(MemoryType, [Memory])] {
        let grouped = Dictionary(grouping: filteredMemories) { $0.type }
        return MemoryType.allCases.compactMap { type in
            guard let memories = grouped[type], !memories.isEmpty else { return nil }
            return (type, memories)
        }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(groupedMemories, id: \.0) { type, memories in
                    Section(type.displayName) {
                        ForEach(memories) { memory in
                            MemoryRow(memory: memory)
                                .onTapGesture {
                                    selectedMemory = memory
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        Task { try? await store.delete(memory.id) }
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                                .swipeActions(edge: .leading) {
                                    Button {
                                        Task { try? await store.togglePin(memory.id) }
                                    } label: {
                                        Label(
                                            memory.isPinned ? "Unpin" : "Pin",
                                            systemImage: memory.isPinned ? "pin.slash" : "pin"
                                        )
                                    }
                                    .tint(.orange)
                                }
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search memories")
            .navigationTitle("Memory")
            .overlay {
                if store.memories.isEmpty {
                    ContentUnavailableView(
                        "No Memories Yet",
                        systemImage: "brain",
                        description: Text("Memories are automatically extracted from your conversations.")
                    )
                }
            }
            .sheet(item: $selectedMemory) { memory in
                MemoryDetailView(memory: memory, store: store)
            }
        }
    }
}

// MARK: - Memory row

struct MemoryRow: View {
    let memory: Memory

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                if memory.isPinned {
                    Image(systemName: "pin.fill")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
                Text(memory.description)
                    .font(.body)
                    .lineLimit(2)
            }

            HStack(spacing: 8) {
                ForEach(memory.tags, id: \.self) { tag in
                    Text(tag.rawValue)
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(.blue.opacity(0.15), in: Capsule())
                        .foregroundStyle(.blue)
                }

                Spacer()

                Text(memory.createdAt, style: .relative)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Display names

extension MemoryType {
    var displayName: String {
        switch self {
        case .preference: return "Preferences"
        case .fact: return "Facts"
        case .instruction: return "Instructions"
        case .context: return "Context"
        }
    }
}
