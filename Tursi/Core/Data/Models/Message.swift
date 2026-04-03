import Foundation

struct Message: Identifiable, Codable {
    let id: UUID
    let conversationId: UUID
    let role: MessageRole
    var content: String
    var toolCalls: [ToolCall]?
    var toolResults: [ToolResult]?
    let timestamp: Date

    init(
        id: UUID = UUID(),
        conversationId: UUID,
        role: MessageRole,
        content: String,
        toolCalls: [ToolCall]? = nil,
        toolResults: [ToolResult]? = nil
    ) {
        self.id = id
        self.conversationId = conversationId
        self.role = role
        self.content = content
        self.toolCalls = toolCalls
        self.toolResults = toolResults
        self.timestamp = Date()
    }
}

enum MessageRole: String, Codable {
    case user
    case assistant
    case system
    case tool
}

struct ToolCall: Identifiable, Codable {
    let id: String
    let name: String
    let arguments: String // JSON string
}

struct ToolResult: Codable {
    let toolCallId: String
    let content: String
    let isError: Bool
}
