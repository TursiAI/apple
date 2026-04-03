import Foundation
import CryptoKit

/// Encrypt and decrypt data using AES-256-GCM.
enum E2EE {
    /// Encrypt data with the given key.
    static func encrypt(_ data: Data, using key: SymmetricKey) throws -> (ciphertext: Data, iv: Data) {
        let nonce = AES.GCM.Nonce()
        let sealedBox = try AES.GCM.seal(data, using: key, nonce: nonce)
        guard let combined = sealedBox.combined else {
            throw E2EEError.encryptionFailed
        }
        let ivData = Data(nonce)
        return (ciphertext: combined, iv: ivData)
    }

    /// Decrypt data with the given key.
    static func decrypt(ciphertext: Data, using key: SymmetricKey) throws -> Data {
        let sealedBox = try AES.GCM.SealedBox(combined: ciphertext)
        return try AES.GCM.open(sealedBox, using: key)
    }

    /// Convenience: encrypt a Codable object.
    static func encryptObject<T: Encodable>(_ object: T, using key: SymmetricKey) throws -> (ciphertext: Data, iv: Data) {
        let data = try JSONEncoder().encode(object)
        return try encrypt(data, using: key)
    }

    /// Convenience: decrypt to a Codable object.
    static func decryptObject<T: Decodable>(_ type: T.Type, ciphertext: Data, using key: SymmetricKey) throws -> T {
        let data = try decrypt(ciphertext: ciphertext, using: key)
        return try JSONDecoder().decode(type, from: data)
    }
}

enum E2EEError: Error, LocalizedError {
    case encryptionFailed
    case decryptionFailed

    var errorDescription: String? {
        switch self {
        case .encryptionFailed: return "Failed to encrypt data."
        case .decryptionFailed: return "Failed to decrypt data."
        }
    }
}
