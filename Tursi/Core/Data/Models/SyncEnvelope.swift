import Foundation

public struct SyncEnvelope: Identifiable, Codable {
    public let id: UUID
    public let userId: String
    public let entityType: String         // "conversation", "memory", "settings"
    public let encryptedPayload: Data     // AES-256-GCM ciphertext
    public let iv: Data
    public let version: Int64
    public let updatedAt: Date
    public let isDeleted: Bool
}
