import SwiftUI

struct ChatListView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = ChatViewModel(
        engine: AppleEngine(),
        memoryStore: MemoryStore(),
        mcpClient: MCPClient()
    )

    var body: some View {
        NavigationSplitView {
            List(selection: Binding(
                get: { viewModel.activeConversation?.id },
                set: { id in
                    if let conv = viewModel.conversations.first(where: { $0.id == id }) {
                        viewModel.selectConversation(conv)
                    }
                }
            )) {
                ForEach(viewModel.conversations) { conversation in
                    NavigationLink(value: conversation.id) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(conversation.title)
                                .font(.body)
                                .foregroundStyle(.primary)
                            Text(conversation.updatedAt, style: .relative)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Chats")
            .toolbar {
                Button {
                    viewModel.newConversation()
                } label: {
                    Image(systemName: "square.and.pencil")
                }
            }
            .overlay {
                if viewModel.conversations.isEmpty {
                    ContentUnavailableView(
                        "No Conversations",
                        systemImage: "bubble.left.and.bubble.right",
                        description: Text("Start a new chat to begin.")
                    )
                }
            }
        } detail: {
            if viewModel.activeConversation != nil {
                ChatView(viewModel: viewModel)
            } else {
                ContentUnavailableView(
                    "Select a Chat",
                    systemImage: "bubble.left",
                    description: Text("Choose a conversation or start a new one.")
                )
            }
        }
    }
}
