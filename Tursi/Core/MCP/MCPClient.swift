import Foundation

/// MCP client that routes tool calls to enabled integrations.
final class MCPClient: @unchecked Sendable {
    private let lock = NSLock()
    private var _integrations: [String: Integration] = [:]
    private var _connections: [String: MCPConnection] = [:]

    func register(_ integration: Integration) {
        lock.withLock { _integrations[integration.id] = integration }
    }

    func availableTools() async -> [MCPToolDefinition] {
        // TODO: Query each enabled integration's MCP server for its tools
        return []
    }

    func execute(toolCall: ToolCall) async throws -> ToolResult {
        // TODO: Find the integration that owns this tool
        // Check permission level (ask user if needed)
        // Forward to MCP server
        // Return result
        return ToolResult(
            toolCallId: toolCall.id,
            content: "Tool execution not yet implemented",
            isError: true
        )
    }
}

struct MCPConnection: Sendable {
    let integrationId: String
    let endpoint: MCPEndpoint
}
