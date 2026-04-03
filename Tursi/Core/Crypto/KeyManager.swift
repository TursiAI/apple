import Foundation
import CryptoKit

/// Manages encryption keys for E2EE.
public final class KeyManager {
    private static let keychainService = "ai.tursi.keys"
    private static let masterKeyAccount = "master-key"

    /// Generate a new master key and store in Keychain.
    public func createMasterKey() throws -> SymmetricKey {
        let key = SymmetricKey(size: .bits256)
        try storeInKeychain(key: key, account: Self.masterKeyAccount)
        return key
    }

    /// Retrieve the master key from Keychain.
    public func getMasterKey() throws -> SymmetricKey? {
        return try loadFromKeychain(account: Self.masterKeyAccount)
    }

    /// Get or create the master key.
    public func getOrCreateMasterKey() throws -> SymmetricKey {
        if let existing = try getMasterKey() {
            return existing
        }
        return try createMasterKey()
    }

    /// Generate a recovery key the user can back up.
    public func generateRecoveryKey(from masterKey: SymmetricKey) -> String {
        // Encode the key as a base64 string the user can write down
        let keyData = masterKey.withUnsafeBytes { Data($0) }
        return keyData.base64EncodedString()
    }

    /// Restore master key from a recovery key.
    public func restoreFromRecoveryKey(_ recoveryKey: String) throws -> SymmetricKey {
        guard let data = Data(base64Encoded: recoveryKey), data.count == 32 else {
            throw KeyManagerError.invalidRecoveryKey
        }
        let key = SymmetricKey(data: data)
        try storeInKeychain(key: key, account: Self.masterKeyAccount)
        return key
    }

    /// Delete the master key (account deletion).
    public func deleteMasterKey() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: Self.keychainService,
            kSecAttrAccount as String: Self.masterKeyAccount,
        ]
        SecItemDelete(query as CFDictionary)
    }

    // MARK: - Keychain helpers

    private func storeInKeychain(key: SymmetricKey, account: String) throws {
        let keyData = key.withUnsafeBytes { Data($0) }

        // Delete existing if any
        let deleteQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: Self.keychainService,
            kSecAttrAccount as String: account,
        ]
        SecItemDelete(deleteQuery as CFDictionary)

        let addQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: Self.keychainService,
            kSecAttrAccount as String: account,
            kSecValueData as String: keyData,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
        ]

        let status = SecItemAdd(addQuery as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeyManagerError.keychainError(status)
        }
    }

    private func loadFromKeychain(account: String) throws -> SymmetricKey? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: Self.keychainService,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        if status == errSecItemNotFound { return nil }
        guard status == errSecSuccess, let data = result as? Data else {
            throw KeyManagerError.keychainError(status)
        }

        return SymmetricKey(data: data)
    }
}

public enum KeyManagerError: Error, LocalizedError {
    public case invalidRecoveryKey
    public case keychainError(OSStatus)

    public var errorDescription: String? {
        switch self {
        case .invalidRecoveryKey:
            return "Invalid recovery key."
        case .keychainError(let status):
            return "Keychain error: \(status)"
        }
    }
}
