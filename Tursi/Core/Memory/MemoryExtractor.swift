import Foundation

/// Extracts memories from completed conversations using the local LLM.
final class MemoryExtractor: Sendable {
    private let engine: LLMEngine
    private let store: MemoryStore

    init(engine: LLMEngine, store: MemoryStore) {
        self.engine = engine
        self.store = store
    }

    /// Extract new memories from a conversation.
    func extract(from conversationId: UUID, messages: [Message]) async throws -> [Memory] {
        let existing = try store.fetchAll().map(\.description)

        let prompt = buildExtractionPrompt(messages: messages, existingMemories: existing)

        var fullResponse = ""
        let stream = engine.generate(
            messages: [Message(conversationId: conversationId, role: .user, content: prompt)],
            systemPrompt: extractionSystemPrompt,
            tools: nil,
            stream: false
        )

        for try await token in stream {
            fullResponse += token.text
        }

        let extracted = parseExtractionResponse(fullResponse, conversationId: conversationId)

        for memory in extracted {
            try store.save(memory)
        }

        return extracted
    }

    // MARK: - Prompts

    private let extractionSystemPrompt = """
    You are a memory extraction system. Analyze the conversation and identify \
    important facts, preferences, instructions, and context worth remembering. \
    Return ONLY new information not already captured in existing memories. \
    Respond with a JSON array only.
    """

    private func buildExtractionPrompt(messages: [Message], existingMemories: [String]) -> String {
        var prompt = "## Existing Memories\n"
        if existingMemories.isEmpty {
            prompt += "None yet.\n"
        } else {
            for mem in existingMemories {
                prompt += "- \(mem)\n"
            }
        }

        prompt += "\n## Conversation\n"
        for msg in messages where msg.role == .user || msg.role == .assistant {
            let role = msg.role == .user ? "User" : "Assistant"
            prompt += "\(role): \(msg.content)\n"
        }

        prompt += """
        \n## Instructions
        Extract new memories from this conversation. For each memory return:
        ```json
        [
          {
            "description": "short searchable summary",
            "content": "full detail",
            "type": "preference|fact|instruction|context",
            "tags": ["personal", "work", "preferences", "social", "interests", "health", "travel", "other"]
          }
        ]
        ```
        Return an empty array [] if nothing new is worth remembering.
        """
        return prompt
    }

    // MARK: - Parsing

    private func parseExtractionResponse(_ response: String, conversationId: UUID) -> [Memory] {
        guard let jsonStart = response.firstIndex(of: "["),
              let jsonEnd = response.lastIndex(of: "]") else {
            return []
        }

        let jsonString = String(response[jsonStart...jsonEnd])
        guard let data = jsonString.data(using: .utf8) else { return [] }

        struct ExtractedMemory: Decodable {
            let description: String
            let content: String
            let type: String
            let tags: [String]
        }

        guard let extracted = try? JSONDecoder().decode([ExtractedMemory].self, from: data) else {
            return []
        }

        return extracted.map { item in
            Memory(
                description: item.description,
                content: item.content,
                tags: item.tags.compactMap { MemoryTag(rawValue: $0) },
                type: MemoryType(rawValue: item.type) ?? .fact,
                source: MemorySource(conversationId: conversationId, extractedAt: Date())
            )
        }
    }
}
