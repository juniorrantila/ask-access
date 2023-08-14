import Security
import Foundation

public struct Keychain {
    var service: String

    public func set(_ field: String, to: String) {
        guard let data = to.data(using: .utf8) else {
            return
        }
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: field,
            kSecValueData: data
        ]

        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }

    public func get(_ field: String) -> String? {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: field,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne
        ]

        var buffer: AnyObject?
        if SecItemCopyMatching(query as CFDictionary, &buffer) == errSecSuccess {
            if let data = buffer as? Data {
                return String(data: data, encoding: .utf8)
            }
        }

        return nil
    }

    public func remove(_ field: String) {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: field 
        ]

        SecItemDelete(query as CFDictionary)
    }

    public subscript(_ field: String) -> String? {
        get {
            return get(field)
        }
        set {
            guard let newValue = newValue else {
                remove(field)
                return
            }
            set(field, to: newValue)
        }
    }
}

