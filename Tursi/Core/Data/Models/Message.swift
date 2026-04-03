import Foundation
import GRDB

struct Message: Identifiable, Codable, Sendable {
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

enum MessageRole: String, Codable, Sendable {
    case user
    case assistant
    case system
    case tool
}

struct ToolCall: Identifiable, Codable, Sendable {
    let id: String
    let name: String
    let arguments: String
}

struct ToolResult: Codable, Sendable {
    let toolCallId: String
    let content: String
    let isError: Bool
}

// MARK: - GRDB

/// Database record that maps Message to/from SQLite columns.
struct MessageRecord: Codable, FetchableRecord, PersistableRecord {
    static let databaseTableName = "message"

    let id: UUID
    let conversationId: UUID
    let role: String
    let content: String
    let toolCallsJSON: String?
    let toolResultsJSON: String?
    let timestamp: Date

    init(from message: Message) {
        self.id = message.id
        self.conversationId = message.conversationId
        self.role = message.role.rawValue
        self.content = message.content
        self.toolCallsJSON = message.toolCalls.flatMap { try? String(data: JSONEncoder().encode($0), encoding: .utf8) }
        self.toolResultsJSON = message.toolResults.flatMap { try? String(data: JSONEncoder().encode($0), encoding: .utf8) }
        self.timestamp = message.timestamp
    }

    func toMessage() -> Message {
        let decoder = JSONDecoder()
        let toolCalls = toolCallsJSON
            .flatMap { $0.data(using: .utf8) }
            .flatMap { try? decoder.decode([ToolCall].self, from: $0) }
        let toolResults = toolResultsJSON
            .flatMap { $0.data(using: .utf8) }
            .flatMap { try? decoder.decode([ToolResult].self, from: $0) }

        return Message(
            id: id,
            conversationId: conversationId,
            role: MessageRole(rawValue: role) ?? .user,
            content: content,
            toolCalls: toolCalls,
            toolResults: toolResults
        )
    }
}
