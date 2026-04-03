import Foundation

/// Orchestrates chat: LLM generation, memory injection, tool calling.
@MainActor
final class ChatViewModel: ObservableObject {
    @Published var conversations: [Conversation] = []
    @Published var activeConversation: Conversation?
    @Published var messages: [Message] = []
    @Published var isGenerating = false
    @Published var streamingText = ""

    private let engine: LLMEngine
    private let memoryStore: MemoryStore
    private let mcpClient: MCPClient
    private let extractor: MemoryExtractor

    init(engine: LLMEngine, memoryStore: MemoryStore, mcpClient: MCPClient) {
        self.engine = engine
        self.memoryStore = memoryStore
        self.mcpClient = mcpClient
        self.extractor = MemoryExtractor(engine: engine, store: memoryStore)
    }

    // MARK: - Conversations

    func newConversation() {
        let conversation = Conversation()
        conversations.insert(conversation, at: 0)
        activeConversation = conversation
        messages = []
    }

    func selectConversation(_ conversation: Conversation) {
        activeConversation = conversation
        // TODO: Load messages from database
    }

    // MARK: - Send message

    func send(_ text: String) async {
        guard let conversation = activeConversation else { return }

        // Add user message
        let userMessage = Message(conversationId: conversation.id, role: .user, content: text)
        messages.append(userMessage)

        // Build system prompt with relevant memories
        let systemPrompt = buildSystemPrompt(for: text)

        // Get available tools
        let tools = await mcpClient.availableTools()

        // Generate response
        isGenerating = true
        streamingText = ""

        do {
            let stream = engine.generate(
                messages: messages,
                systemPrompt: systemPrompt,
                tools: tools.isEmpty ? nil : tools,
                stream: true
            )

            for try await token in stream {
                streamingText += token.text
            }

            // Add assistant message
            let assistantMessage = Message(
                conversationId: conversation.id,
                role: .assistant,
                content: streamingText
            )
            messages.append(assistantMessage)

            // TODO: Handle tool calls in response
            // TODO: Persist messages to database
        } catch {
            // TODO: Show error to user
            print("Generation error: \(error)")
        }

        streamingText = ""
        isGenerating = false
    }

    // MARK: - Memory extraction

    func extractMemories() async {
        guard let conversation = activeConversation, messages.count >= 2 else { return }
        do {
            let newMemories = try await extractor.extract(from: conversation, messages: messages)
            for memory in newMemories {
                try await memoryStore.save(memory)
            }
        } catch {
            print("Memory extraction error: \(error)")
        }
    }

    // MARK: - System prompt

    private func buildSystemPrompt(for query: String) -> String {
        let relevant = memoryStore.relevantMemories(for: query)

        var prompt = "You are a helpful AI assistant.\n"

        if !relevant.isEmpty {
            prompt += "\n## Your Memories\n"
            prompt += "You remember the following about the user:\n"
            for memory in relevant {
                let pin = memory.isPinned ? " [pinned]" : ""
                prompt += "- \(memory.description)\(pin)\n"
            }
            prompt += "\nUse these memories naturally in conversation. Don't list them unless asked.\n"
        }

        return prompt
    }
}
