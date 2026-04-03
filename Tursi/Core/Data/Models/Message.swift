import Foundation
import GRDB

public struct Message: Identifiable, Codable, Sendable {
    public let id: UUID
    public let conversationId: UUID
    public let role: MessageRole
    public var content: String
    public var toolCalls: [ToolCall]?
    public var toolResults: [ToolResult]?
    public let timestamp: Date

    public init(
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

public enum MessageRole: String, Codable, Sendable {
    public case user
    public case assistant
    public case system
    public case tool
}

public struct ToolCall: Identifiable, Codable, Sendable {
    public let id: String
    public let name: String
    public let arguments: String
}

public struct ToolResult: Codable, Sendable {
    public let toolCallId: String
    public let content: String
    public let isError: Bool
}

// MARK: - GRDB

/// Database record that maps Message to/from SQLite columns.
public struct MessageRecord: Codable, FetchableRecord, PersistableRecord {
    public static let databaseTableName = "message"

    public let id: UUID
    public let conversationId: UUID
    public let role: String
    public let content: String
    public let toolCallsJSON: String?
    public let toolResultsJSON: String?
    public let timestamp: Date

    public init(from message: Message) {
        self.id = message.id
        self.conversationId = message.conversationId
        self.role = message.role.rawValue
        self.content = message.content
        self.toolCallsJSON = message.toolCalls.flatMap { try? String(data: JSONEncoder().encode($0), encoding: .utf8) }
        self.toolResultsJSON = message.toolResults.flatMap { try? String(data: JSONEncoder().encode($0), encoding: .utf8) }
        self.timestamp = message.timestamp
    }

    public func toMessage() -> Message {
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
