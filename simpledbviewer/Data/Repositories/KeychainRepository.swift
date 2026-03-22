//
//  KeychainRepository.swift
//  simpledbviewer
//
//  Created by Maysam Shahsavari on 2026-03-05.
//

import Foundation
import Security

final class KeychainRepository: SecureStorageRepository {
    private let service = "ca.maysoft.awscredentials"
    private let jsonEncoder: JSONEncoder = JSONEncoder()
    
    private struct AWSCredential: Codable {
        let id: String
        let displayName: String
        let region: String
        let accessKey: String
        let secretKey: String

        init(_ entity: AWSCredentialEntity) {
            self.id = entity.id
            self.displayName = entity.displayName
            self.region = entity.region
            self.accessKey = entity.accessKey
            self.secretKey = entity.secretKey
        }

        func toEntity() -> AWSCredentialEntity {
            AWSCredentialEntity(
                id: id,
                displayName: displayName,
                region: region,
                accessKey: accessKey,
                secretKey: secretKey
            )
        }
    }

    func listStoredCredentials() throws -> [AWSCredentialNameEntity] {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecReturnAttributes as String: true,
            kSecMatchLimit as String: kSecMatchLimitAll
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        if status == errSecItemNotFound { return [] }
        guard status == errSecSuccess, let items = result as? [[String: Any]] else {
            throw keychainError(status)
        }

        return items.compactMap { attributes in
            guard let id = attributes[kSecAttrAccount as String] as? String else { return nil }
            let displayName = (attributes[kSecAttrLabel as String] as? String) ?? id
            return AWSCredentialNameEntity(id: id, displayName: displayName)
        }
    }

    func fetchCredential(for id: String) throws -> AWSCredentialEntity {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: id,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess, let data = result as? Data else {
            if status == errSecItemNotFound {
                throw AppError.notFound(what: "Credential '\(id)'")
            }
            throw keychainError(status)
        }

        do {
            return try JSONDecoder().decode(AWSCredential.self, from: data).toEntity()
        } catch {
            throw AppError.generic(message: "Failed to decode credential: \(error.localizedDescription)")
        }
    }

    func storeCredential(_ data: AWSCredentialEntity) throws {
        let credential = AWSCredential(data)
        let encoded: Data
        
        do {
            encoded = try jsonEncoder.encode(credential)
        } catch {
            throw AppError.generic(message: "Failed to encode credential: \(error.localizedDescription)")
        }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: credential.id,
            kSecAttrLabel as String: credential.displayName,
            kSecValueData as String: encoded,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
        ]

        let status = SecItemAdd(query as CFDictionary, nil)

        if status == errSecDuplicateItem {
            try updateCredential(data)
            return
        }

        guard status == errSecSuccess else {
            throw keychainError(status)
        }
    }

    func updateCredential(_ data: AWSCredentialEntity) throws {
        let credential = AWSCredential(data)
        let encoded: Data
        do {
            encoded = try jsonEncoder.encode(credential)
        } catch {
            throw AppError.generic(message: "Failed to encode credential: \(error.localizedDescription)")
        }

        let query: [String: Any] = [
            kSecClass as String:       kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: credential.id
        ]

        let attributes: [String: Any] = [
            kSecAttrLabel as String: credential.displayName,
            kSecValueData as String: encoded,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
        ]

        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)

        if status == errSecItemNotFound {
            throw AppError.notFound(what: "Credential '\(credential.id)'")
        }

        guard status == errSecSuccess else {
            throw keychainError(status)
        }
    }

    func deleteCredential(for id: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: id
        ]

        let status = SecItemDelete(query as CFDictionary)

        if status == errSecItemNotFound {
            throw AppError.notFound(what: "Credential '\(id)'")
        }

        guard status == errSecSuccess else {
            throw keychainError(status)
        }
    }

    func deleteAllCredentials() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service
        ]

        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw keychainError(status)
        }
    }

    private func keychainError(_ status: OSStatus) -> AppError {
        let message = SecCopyErrorMessageString(status, nil) as String? ?? "Unknown Keychain error"
        return .generic(message: "Keychain error (\(status)): \(message)")
    }
}
