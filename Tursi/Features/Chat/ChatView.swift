import SwiftUI

struct ChatView: View {
    @ObservedObject var viewModel: ChatViewModel
    @State private var inputText = ""
    @FocusState private var isInputFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Messages
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.messages) { message in
                            MessageBubble(message: message)
                                .id(message.id)
                        }

                        // Streaming response
                        if viewModel.isGenerating && !viewModel.streamingText.isEmpty {
                            MessageBubble(message: Message(
                                conversationId: UUID(),
                                role: .assistant,
                                content: viewModel.streamingText
                            ))
                            .id("streaming")
                        }

                        // Typing indicator
                        if viewModel.isGenerating && viewModel.streamingText.isEmpty {
                            HStack {
                                TypingIndicator()
                                Spacer()
                            }
                            .padding(.horizontal)
                            .id("typing")
                        }
                    }
                    .padding()
                }
                .onChange(of: viewModel.messages.count) {
                    withAnimation {
                        proxy.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
                    }
                }
                .onChange(of: viewModel.streamingText) {
                    proxy.scrollTo("streaming", anchor: .bottom)
                }
            }

            Divider()

            // Input bar
            HStack(spacing: 12) {
                TextField("Message", text: $inputText, axis: .vertical)
                    .textFieldStyle(.plain)
                    .lineLimit(1...5)
                    .focused($isInputFocused)
                    .onSubmit {
                        sendMessage()
                    }

                Button {
                    sendMessage()
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                        .foregroundStyle(inputText.isEmpty ? .secondary : .blue)
                }
                .disabled(inputText.isEmpty || viewModel.isGenerating)
            }
            .padding()
        }
        .navigationTitle(viewModel.activeConversation?.title ?? "Chat")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }

    private func sendMessage() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        inputText = ""
        Task {
            await viewModel.send(text)
        }
    }
}

// MARK: - Typing indicator

struct TypingIndicator: View {
    @State private var phase = 0

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(.secondary)
                    .frame(width: 8, height: 8)
                    .opacity(phase == index ? 1.0 : 0.3)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.gray.opacity(0.15), in: RoundedRectangle(cornerRadius: 16))
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { _ in
                withAnimation(.easeInOut(duration: 0.3)) {
                    phase = (phase + 1) % 3
                }
            }
        }
    }
}
