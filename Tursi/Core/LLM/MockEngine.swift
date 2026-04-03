import Foundation

/// A mock LLM engine that echoes back responses for testing and development.
/// Simulates streaming with word-by-word output.
final class MockEngine: LLMEngine {
    var isAvailable: Bool { true }
    var displayName: String { "Mock (Development)" }
    var capabilities: LLMCapabilities {
        LLMCapabilities(supportsToolCalling: false, maxContextTokens: 4096, supportsStreaming: true)
    }

    func generate(
        messages: [Message],
        systemPrompt: String,
        tools: [MCPToolDefinition]?,
        stream: Bool
    ) -> AsyncThrowingStream<LLMToken, Error> {
        let response = buildResponse(for: messages, systemPrompt: systemPrompt)

        return AsyncThrowingStream { continuation in
            Task {
                let words = response.split(separator: " ")
                for (i, word) in words.enumerated() {
                    let isLast = i == words.count - 1
                    let text = (i == 0 ? "" : " ") + word
                    continuation.yield(LLMToken(text: String(text), isFinished: isLast))
                    // Simulate streaming delay
                    try await Task.sleep(for: .milliseconds(30))
                }
                continuation.finish()
            }
        }
    }

    private func buildResponse(for messages: [Message], systemPrompt: String) -> String {
        guard let lastMessage = messages.last(where: { $0.role == .user }) else {
            return "I didn't catch that. Could you say something?"
        }

        let content = lastMessage.content.lowercased()

        // Simple pattern matching for demo purposes
        if content.contains("hello") || content.contains("hi") || content.contains("hey") {
            return "Hey! I'm Tursi, your local AI assistant. Everything I do runs on your device — your conversations and memories stay private. What can I help you with?"
        }

        if content.contains("remember") || content.contains("memory") {
            return "I can remember things across our conversations! Anything important you tell me gets extracted and stored locally on your device, encrypted and synced across your Apple devices. What would you like me to remember?"
        }

        if content.contains("privacy") || content.contains("secure") || content.contains("encrypt") {
            return "Your privacy is my top priority. I run entirely on your device — no cloud AI servers involved. Your memories are encrypted with AES-256-GCM before syncing, and only your devices hold the decryption key. The server never sees your data in plaintext."
        }

        return "I hear you! You said: \"\(lastMessage.content)\". I'm currently running in mock mode for development. Once connected to a real LLM engine (Apple Intelligence or an enhanced downloaded model), I'll give much more helpful responses."
    }
}
