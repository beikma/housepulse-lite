import Foundation
import Security

class KeychainService {
    static let shared = KeychainService()

    private let service = "com.housepulse.lite"

    private init() {}

    // Save API key to Keychain
    func saveMCPApiKey(_ apiKey: String, for homeId: String) -> Bool {
        let account = "mcp_api_key_\(homeId)"

        // Delete existing key if present
        delete(account: account)

        guard let data = apiKey.data(using: .utf8) else {
            return false
        }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]

        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }

    // Retrieve API key from Keychain
    func getMCPApiKey(for homeId: String) -> String? {
        let account = "mcp_api_key_\(homeId)"

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let apiKey = String(data: data, encoding: .utf8) else {
            return nil
        }

        return apiKey
    }

    // Delete API key from Keychain
    func deleteMCPApiKey(for homeId: String) -> Bool {
        let account = "mcp_api_key_\(homeId)"
        return delete(account: account)
    }

    private func delete(account: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]

        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
}
