import SwiftUI
import TursiCore

struct MemoryDetailView: View {
    @State var memory: Memory
    let store: MemoryStore
    @Environment(\.dismiss) private var dismiss
    @State private var isEditing = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Summary") {
                    if isEditing {
                        TextField("Description", text: $memory.description)
                    } else {
                        Text(memory.description)
                    }
                }

                Section("Content") {
                    if isEditing {
                        TextEditor(text: $memory.content)
                            .frame(minHeight: 100)
                    } else {
                        Text(memory.content)
                    }
                }

                Section("Details") {
                    LabeledContent("Type", value: memory.type.displayName)
                    LabeledContent("Pinned", value: memory.isPinned ? "Yes" : "No")
                    LabeledContent("Importance", value: String(format: "%.0f%%", memory.importance * 100))
                    LabeledContent("Created", value: memory.createdAt.formatted())
                }

                if !memory.tags.isEmpty {
                    Section("Tags") {
                        FlowLayout(spacing: 8) {
                            ForEach(memory.tags, id: \.self) { tag in
                                Text(tag.rawValue)
                                    .font(.caption)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(.blue.opacity(0.15), in: Capsule())
                                    .foregroundStyle(.blue)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Memory")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Save" : "Edit") {
                        if isEditing {
                            Task {
                                try? await store.save(memory)
                                dismiss()
                            }
                        }
                        isEditing.toggle()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Simple flow layout for tags

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = layout(in: proposal.width ?? 0, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = layout(in: bounds.width, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }

    private func layout(in width: CGFloat, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var maxWidth: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > width && x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
            maxWidth = max(maxWidth, x)
        }

        return (CGSize(width: maxWidth, height: y + rowHeight), positions)
    }
}
