//
//  SecurityManager.swift
//  expense
//
//  Created by Siddharth Patel on 8/18/25.
//

import Foundation
import LocalAuthentication
import Combine

class SecurityManager: ObservableObject {
    @Published var isLocked = false
    @Published var isAuthenticated = false
    @Published var enableAppLock = false
    @Published var useFaceID = true
    @Published var usePIN = false
    @Published var passcode: String = ""
    @Published var isBiometricAvailable = false
    
    private let context = LAContext()
    
    init() {
        // Check Face ID availability
        isBiometricAvailable = isFaceIDAvailable()
        loadSettings()
        // Don't auto-lock on init - only lock when app goes to background
    }
    
    // MARK: - Face ID Authentication
    func authenticateWithFaceID(completion: @escaping (Bool, Error?) -> Void) {
        guard useFaceID else {
            completion(false, nil)
            return
        }
        
        context.localizedCancelTitle = "Cancel"
        
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Authenticate to unlock the app"
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
                DispatchQueue.main.async {
                    if success {
                        self.isAuthenticated = true
                        self.isLocked = false
                        completion(true, nil)
                    } else {
                        completion(false, error)
                    }
                }
            }
        } else {
            completion(false, error)
        }
    }
    
    // MARK: - PIN Authentication
    func authenticateWithPIN(_ enteredPIN: String) -> Bool {
        guard usePIN && !passcode.isEmpty else { return false }
        
        if enteredPIN == passcode {
            isAuthenticated = true
            isLocked = false
            return true
        }
        return false
    }
    
    // MARK: - Settings Management
    func saveSettings() {
        UserDefaults.standard.set(enableAppLock, forKey: "appLockEnabled")
        UserDefaults.standard.set(useFaceID, forKey: "useFaceID")
        UserDefaults.standard.set(usePIN, forKey: "usePIN")
        
        // Store passcode in Keychain for security
        if !passcode.isEmpty {
            KeychainHelper.save(passcode, forKey: "appPasscode")
        }
    }
    
    func loadSettings() {
        enableAppLock = UserDefaults.standard.bool(forKey: "appLockEnabled")
        useFaceID = UserDefaults.standard.bool(forKey: "useFaceID")
        usePIN = UserDefaults.standard.bool(forKey: "usePIN")
        passcode = KeychainHelper.load(forKey: "appPasscode") ?? ""
        
        // Default to Face ID if no settings exist
        if enableAppLock && useFaceID {
            useFaceID = true
        }
    }
    
    // MARK: - Lock/Unlock
    func lockApp() {
        if enableAppLock {
            isLocked = true
            isAuthenticated = false
        }
    }
    
    func unlockApp() {
        isLocked = false
        isAuthenticated = true
    }
    
    // MARK: - Check Face ID Availability
    func isFaceIDAvailable() -> Bool {
        let checkContext = LAContext()
        var error: NSError?
        let canEvaluate = checkContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        return canEvaluate
    }
    
    // MARK: - Reset Authentication
    func resetAuthentication() {
        isAuthenticated = false
        isLocked = false
    }
}

// MARK: - Keychain Helper
class KeychainHelper {
    static func save(_ value: String, forKey key: String) {
        if let data = value.data(using: .utf8) {
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: key,
                kSecValueData as String: data
            ]
            
            // Delete existing item
            SecItemDelete(query as CFDictionary)
            
            // Add new item
            SecItemAdd(query as CFDictionary, nil)
        }
    }
    
    static func load(forKey key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecSuccess,
           let data = result as? Data,
           let value = String(data: data, encoding: .utf8) {
            return value
        }
        
        return nil
    }
    
    static func delete(forKey key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        SecItemDelete(query as CFDictionary)
    }
}
