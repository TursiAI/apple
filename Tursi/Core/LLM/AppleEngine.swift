import Foundation

/// LLM engine using Apple's on-device Foundation Models (iOS 26+).
final class AppleEngine: LLMEngine {
    var isAvailable: Bool {
        // TODO: Check for Apple Foundation Models availability
        // guard #available(iOS 26, macOS 26, *) else { return false }
        return false
    }

    var displayName: String { "Standard" }

    var capabilities: LLMCapabilities {
        LLMCapabilities(
            supportsToolCalling: true,
            maxContextTokens: 4096,
            supportsStreaming: true
        )
    }

    func generate(
        messages: [Message],
        systemPrompt: String,
        tools: [MCPToolDefinition]?,
        stream: Bool
    ) -> AsyncThrowingStream<LLMToken, Error> {
        AsyncThrowingStream { continuation in
            // TODO: Integrate with Apple Foundation Models framework
            // import FoundationModels
            // let session = LanguageModelSession()
            // for try await chunk in session.streamResponse(...) { ... }
            continuation.finish(throwing: LLMError.notAvailable)
        }
    }
}

enum LLMError: Error, LocalizedError {
    case notAvailable
    case generationFailed(String)
    case modelNotLoaded

    var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "This AI model is not available on your device."
        case .generationFailed(let reason):
            return "Generation failed: \(reason)"
        case .modelNotLoaded:
            return "The enhanced model hasn't been downloaded yet."
        }
    }
}
