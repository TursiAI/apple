import Foundation

/// Token emitted during streaming generation.
struct LLMToken {
    let text: String
    let isFinished: Bool
}

/// Capabilities reported by an LLM engine.
struct LLMCapabilities {
    let supportsToolCalling: Bool
    let maxContextTokens: Int
    let supportsStreaming: Bool
}

/// Common interface for all LLM backends.
protocol LLMEngine: Sendable {
    var isAvailable: Bool { get }
    var displayName: String { get }
    var capabilities: LLMCapabilities { get }

    /// Generate a streaming response.
    func generate(
        messages: [Message],
        systemPrompt: String,
        tools: [MCPToolDefinition]?,
        stream: Bool
    ) -> AsyncThrowingStream<LLMToken, Error>
}

/// Describes an MCP tool the LLM can call.
struct MCPToolDefinition {
    let name: String
    let description: String
    let inputSchema: String // JSON Schema
}
