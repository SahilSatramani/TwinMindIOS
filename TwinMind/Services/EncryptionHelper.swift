import Foundation
import CryptoKit
import Security

struct EncryptionHelper {
    static private let keyTag = "com.twinmind.encryptionkey"

    static var key: SymmetricKey {
        if let existing = loadKey() {
            return existing
        } else {
            let newKey = SymmetricKey(size: .bits256)
            saveKey(newKey)
            return newKey
        }
    }

    static func encrypt(_ data: Data) throws -> Data {
        let sealedBox = try AES.GCM.seal(data, using: key)
        return sealedBox.combined!
    }

    static func decrypt(_ data: Data) throws -> Data {
        let sealedBox = try AES.GCM.SealedBox(combined: data)
        return try AES.GCM.open(sealedBox, using: key)
    }

    // MARK: - Keychain helpers

    private static func saveKey(_ key: SymmetricKey) {
        let tag = keyTag.data(using: .utf8)!
        let keyData = key.withUnsafeBytes { Data($0) }

        // Delete any existing item with the same tag
        let queryDelete: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: tag
        ]
        SecItemDelete(queryDelete as CFDictionary)

        // Add new key to Keychain
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: tag,
            kSecAttrKeyClass as String: kSecAttrKeyClassSymmetric,
            kSecValueData as String: keyData,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        SecItemAdd(query as CFDictionary, nil)
    }

    private static func loadKey() -> SymmetricKey? {
        let tag = keyTag.data(using: .utf8)!

        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: tag,
            kSecReturnData as String: true
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        guard status == errSecSuccess, let keyData = item as? Data else {
            return nil
        }

        return SymmetricKey(data: keyData)
    }
}
