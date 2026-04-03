import Foundation

struct SyncEnvelope: Identifiable, Codable {
    let id: UUID
    let userId: String
    let entityType: String         // "conversation", "memory", "settings"
    let encryptedPayload: Data     // AES-256-GCM ciphertext
    let iv: Data
    let version: Int64
    let updatedAt: Date
    let isDeleted: Bool
}
