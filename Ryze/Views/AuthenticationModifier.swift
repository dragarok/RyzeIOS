//
//  AuthenticationModifier.swift
//  Ryze
//
//  Created for Ryze app on 10/04/2025.
//

import SwiftUI

// ViewModifier for handling app locking and biometric authentication
struct AuthenticationModifier: ViewModifier {
    @ObservedObject private var authManager = AuthenticationManager.shared
    @AppStorage("useBiometricAuth") private var useBiometricAuth = false
    @Environment(\.scenePhase) private var scenePhase
    
    @State private var isShowingAuth = false
    @State private var isAuthenticating = false
    
    func body(content: Content) -> some View {
        ZStack {
            // Main content
            content
                .blur(radius: !authManager.isAuthenticated && useBiometricAuth ? 10 : 0)
                .allowsHitTesting(authManager.isAuthenticated || !useBiometricAuth)
            
            // Authentication overlay
            if !authManager.isAuthenticated && useBiometricAuth {
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .ignoresSafeArea()
                    .overlay {
                        VStack(spacing: 20) {
                            Image(systemName: "lock.shield")
                                .font(.system(size: 60))
                                .foregroundColor(.blue)
                            
                            Text("Ryze is locked")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Button(action: {
                                authenticate()
                            }) {
                                HStack {
                                    Image(systemName: biometricSystemImage)
                                    Text(biometricPrompt)
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                        }
                    }
                    .transition(.opacity.animation(.easeInOut))
            }
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .active && useBiometricAuth && !authManager.isAuthenticated {
                // Show authentication when returning to the app
                authenticate()
            } else if newPhase == .background && useBiometricAuth {
                // Lock the app when it goes to background
                authManager.lockApp()
            }
        }
    }
    
    // Start the authentication process
    private func authenticate() {
        // Prevent multiple authentication attempts
        guard !isAuthenticating else { return }
        
        isAuthenticating = true
        Task {
            _ = await authManager.authenticate()
            
            await MainActor.run {
                isAuthenticating = false
            }
        }
    }
    
    // Get the appropriate system image based on biometric type
    private var biometricSystemImage: String {
        switch authManager.biometricType {
        case .faceID:
            return "faceid"
        case .touchID:
            return "touchid"
        case .none:
            return "lock.open.fill"
        }
    }
    
    // Get the appropriate prompt based on biometric type
    private var biometricPrompt: String {
        switch authManager.biometricType {
        case .faceID:
            return "Unlock with Face ID"
        case .touchID:
            return "Unlock with Touch ID"
        case .none:
            return "Unlock"
        }
    }
}

// Extension for applying the authentication modifier
extension View {
    func withAuthentication() -> some View {
        return self.modifier(AuthenticationModifier())
    }
}