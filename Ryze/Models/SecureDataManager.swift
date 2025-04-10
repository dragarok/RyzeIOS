//
//  SecureDataManager.swift
//  Ryze
//
//  Created for Ryze app on 10/04/2025.
//

import Foundation
import Security
import CryptoKit

/// A utility class for securely storing and retrieving sensitive data
class SecureDataManager {
    static let shared = SecureDataManager()
    
    private init() {}
    
    // Encrypt data using AES-GCM encryption
    func encryptData(_ data: Data, key: SymmetricKey) -> Data? {
        do {
            let sealedBox = try AES.GCM.seal(data, using: key)
            return sealedBox.combined
        } catch {
            print("Encryption error: \(error.localizedDescription)")
            return nil
        }
    }
    
    // Decrypt data that was encrypted with AES-GCM
    func decryptData(_ sealedData: Data, key: SymmetricKey) -> Data? {
        do {
            let sealedBox = try AES.GCM.SealedBox(combined: sealedData)
            return try AES.GCM.open(sealedBox, using: key)
        } catch {
            print("Decryption error: \(error.localizedDescription)")
            return nil
        }
    }
    
    // Generate a symmetric encryption key
    func generateKey() -> SymmetricKey {
        return SymmetricKey(size: .bits256)
    }
    
    // Save a key to the keychain
    func saveKeyToKeychain(key: SymmetricKey, withIdentifier identifier: String) -> Bool {
        // Convert the key to data
        let keyData = key.withUnsafeBytes { bytes in
            return Data(bytes)
        }
        
        // Prepare the keychain query
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: identifier,
            kSecValueData as String: keyData,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        // Remove any existing key with the same identifier
        SecItemDelete(query as CFDictionary)
        
        // Add the new key to the keychain
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    // Load a key from the keychain
    func loadKeyFromKeychain(withIdentifier identifier: String) -> SymmetricKey? {
        // Prepare the keychain query
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: identifier,
            kSecReturnData as String: kCFBooleanTrue as Any,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        // Query the keychain
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        // Check if we got a key
        guard status == errSecSuccess, let keyData = item as? Data else { return nil }
        
        // Convert the data back to a symmetric key
        return SymmetricKey(data: keyData)
    }
    
    // Store a sensitive string securely
    func secureStore(string: String, forKey key: String) -> Bool {
        // Generate a device-specific encryption key if not already saved
        let encryptionKey = loadKeyFromKeychain(withIdentifier: "RyzeEncryptionKey") ?? generateAndStoreNewKey()
        
        guard let stringData = string.data(using: .utf8),
              let encryptedData = encryptData(stringData, key: encryptionKey) else {
            return false
        }
        
        // Store the encrypted data in UserDefaults
        UserDefaults.standard.set(encryptedData, forKey: "secure_\(key)")
        return true
    }
    
    // Retrieve a sensitive string that was securely stored
    func secureRetrieve(forKey key: String) -> String? {
        // Ensure we have an encryption key
        guard let encryptionKey = loadKeyFromKeychain(withIdentifier: "RyzeEncryptionKey"),
              let encryptedData = UserDefaults.standard.data(forKey: "secure_\(key)"),
              let decryptedData = decryptData(encryptedData, key: encryptionKey),
              let decryptedString = String(data: decryptedData, encoding: .utf8) else {
            return nil
        }
        
        return decryptedString
    }
    
    // Helper to generate and store a new encryption key
    private func generateAndStoreNewKey() -> SymmetricKey {
        let newKey = generateKey()
        let _ = saveKeyToKeychain(key: newKey, withIdentifier: "RyzeEncryptionKey")
        return newKey
    }
}