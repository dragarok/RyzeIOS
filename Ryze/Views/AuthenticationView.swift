//
//  AuthenticationView.swift
//  Ryze
//
//  Created for Ryze app on 10/04/2025.
//

import SwiftUI

struct AuthenticationView: View {
    @StateObject private var authManager = AuthenticationManager.shared
    @EnvironmentObject var thoughtViewModel: ThoughtViewModel
    @State private var isAuthenticating = false
    
    var body: some View {
        ZStack {
            // Main content (visible when authenticated)
            if authManager.isAuthenticated {
                ContentView()
                    .environmentObject(thoughtViewModel)
            } else {
                // Authentication screen
                VStack(spacing: 20) {
                    Spacer()
                    
                    // App logo or icon
                    Image(systemName: "arrow.up.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .foregroundColor(.blue)
                    
                    Text("Ryze")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Rise beyond fear")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    // Authentication button
                    Button(action: {
                        authenticate()
                    }) {
                        HStack {
                            Image(systemName: biometricIcon)
                                .font(.headline)
                            Text(biometricPrompt)
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .disabled(isAuthenticating)
                    .padding(.horizontal, 50)
                    
                    Spacer()
                }
                .padding()
                .onAppear {
                    // Try to authenticate when the view appears
                    if !isAuthenticating {
                        authenticate()
                    }
                }
            }
        }
    }
    
    // Biometric icon based on device capability
    private var biometricIcon: String {
        switch authManager.biometricType {
        case .faceID:
            return "faceid"
        case .touchID:
            return "touchid"
        case .none:
            return "lock.shield"
        }
    }
    
    // Biometric prompt text based on device capability
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
    
    // Authenticate the user
    private func authenticate() {
        isAuthenticating = true
        
        Task {
            // Call authentication manager to authenticate
            _ = await authManager.authenticate()
            
            // Update UI state
            await MainActor.run {
                isAuthenticating = false
            }
        }
    }
}

#Preview {
    AuthenticationView()
        .environmentObject(ThoughtViewModel(dataStore: DataStore()))
}