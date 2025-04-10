//
//  AuthenticationManager.swift
//  Ryze
//
//  Created for Ryze app on 10/04/2025.
//

import SwiftUI
import LocalAuthentication

class AuthenticationManager: ObservableObject {
    static let shared = AuthenticationManager()
    
    @Published var isAuthenticated = false
    @Published var biometricType: BiometricType = .none
    @AppStorage("useBiometricAuth") private var useBiometricAuth = false
    
    enum BiometricType {
        case none
        case faceID
        case touchID
    }
    
    private init() {
        // Detect what biometric features are available
        detectBiometricType()
    }
    
    // Detect available biometric authentication type
    func detectBiometricType() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            switch context.biometryType {
            case .faceID:
                biometricType = .faceID
            case .touchID:
                biometricType = .touchID
            default:
                biometricType = .none
            }
        } else {
            biometricType = .none
            if let error = error {
                print("Biometric error: \(error.localizedDescription)")
            }
        }
    }
    
    // Authentication with biometrics or fallback to passcode
    func authenticate(reason: String = "Authenticate to access your thoughts") async -> Bool {
        // If biometric auth is not enabled, consider authenticated by default
        if !useBiometricAuth {
            isAuthenticated = true
            return true
        }
        
        // Check if device supports biometric authentication
        if biometricType == .none {
            isAuthenticated = true  // If no biometrics available, auto-authenticate
            return true
        }
        
        let context = LAContext()
        var error: NSError?
        
        // Check if biometric authentication is available
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            do {
                // Try to authenticate with biometrics
                let success = try await context.evaluatePolicy(
                    .deviceOwnerAuthenticationWithBiometrics,
                    localizedReason: reason
                )
                
                // Update authentication state
                await MainActor.run {
                    isAuthenticated = success
                }
                return success
            } catch {
                print("Authentication error: \(error.localizedDescription)")
                await MainActor.run {
                    isAuthenticated = false
                }
                return false
            }
        } else {
            // Fallback to passcode
            do {
                let success = try await context.evaluatePolicy(
                    .deviceOwnerAuthentication,
                    localizedReason: reason
                )
                
                await MainActor.run {
                    isAuthenticated = success
                }
                return success
            } catch {
                print("Authentication error: \(error.localizedDescription)")
                await MainActor.run {
                    isAuthenticated = false
                }
                return false
            }
        }
    }
    
    // Method to lock the app
    func lockApp() {
        isAuthenticated = false
    }
    
    // Check if app should be locked based on settings
    func shouldLockApp() -> Bool {
        return useBiometricAuth
    }
}