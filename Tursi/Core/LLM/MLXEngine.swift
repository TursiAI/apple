import Foundation

/// LLM engine using MLX Swift for downloaded open models.
public final class MLXEngine: LLMEngine, @unchecked Sendable {
    public init() {}
    private let lock = NSLock()
    private var _isModelLoaded = false

    private var isModelLoaded: Bool {
        get { lock.withLock { _isModelLoaded } }
        set { lock.withLock { _isModelLoaded = newValue } }
    }

    public var isAvailable: Bool {
        #if arch(arm64)
        return true
        #else
        return false
        #endif
    }

    public var displayName: String { "Enhanced" }

    public var capabilities: LLMCapabilities {
        LLMCapabilities(
            supportsToolCalling: true,
            maxContextTokens: 8192,
            supportsStreaming: true
        )
    }

    public var isModelDownloaded: Bool {
        // TODO: Check local storage for downloaded model files
        return false
    }

    public func downloadModel(progress: @escaping @Sendable (Double) -> Void) async throws {
        // TODO: Download model weights from CDN / Hugging Face
    }

    public func deleteModel() throws {
        // TODO: Remove model files from local storage
        isModelLoaded = false
    }

    public var modelSizeBytes: Int64 {
        // TODO: Calculate actual size on disk
        return 0
    }

    public func generate(
        messages: [Message],
        systemPrompt: String,
        tools: [MCPToolDefinition]?,
        stream: Bool
    ) -> AsyncThrowingStream<LLMToken, Error> {
        AsyncThrowingStream { continuation in
            // TODO: Integrate with MLX Swift
            continuation.finish(throwing: LLMError.modelNotLoaded)
        }
    }
}
