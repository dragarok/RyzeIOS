//
//  SettingsView.swift
//  Ryze
//
//  Created for Ryze app on 09/04/2025.
//

import SwiftUI
import LocalAuthentication

struct SettingsView: View {
    // Environment objects
    @EnvironmentObject private var thoughtViewModel: ThoughtViewModel
    @StateObject private var authManager = AuthenticationManager.shared
    
    // Settings state
    @AppStorage("useBiometricAuth") private var useBiometricAuth = false
    @AppStorage("secureDataStorage") private var secureDataStorage = true
    
    // State for test notification
    @State private var showTestNotificationSheet = false
    @State private var selectedTestThought: Thought? = nil
    
    // App info
    private let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    private let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    
    var body: some View {
        NavigationStack {
            List {
                // Security section
                Section("Security") {
                    // Biometric authentication toggle
                    if authManager.biometricType != .none {
                        Toggle(biometricToggleLabel, isOn: $useBiometricAuth)
                            .tint(.blue)
                            .onChange(of: useBiometricAuth) { oldValue, newValue in
                                if newValue {
                                    // Test authentication to make sure it works
                                    Task {
                                        let success = await authManager.authenticate(reason: "Confirm you can use biometric authentication")
                                        if !success {
                                            // If authentication fails, revert the toggle
                                            useBiometricAuth = false
                                        }
                                    }
                                }
                            }
                    } else {
                        Text("Biometric authentication is not available on this device")
                            .foregroundColor(.secondary)
                    }
                    
                    // Secure data storage toggle
                    Toggle("Enable Secure Data Storage", isOn: $secureDataStorage)
                        .tint(.blue)
                }
                
                // Notifications section
                // Developer section (visible only in debug builds)
                #if DEBUG
                Section("Developer") {
                    Button(action: {
                        showTestNotificationSheet = true
                    }) {
                        Label("Test Full-Screen Notification", systemImage: "bell.fill")
                    }
                }
                #endif
                
                // About section
                Section("About") {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Ryze")
                            .font(.headline)
                        Text("Version \(appVersion) (\(buildNumber))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                    
                    NavigationLink(destination: aboutView) {
                        Text("About Ryze")
                    }

                    NavigationLink(destination: ExampleView()) {
                        HStack {
                            Text("See an example")
                        }
                    }
                    
                    NavigationLink(destination: privacyView) {
                        Text("Privacy")
                    }
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showTestNotificationSheet) {
                selectThoughtForTestView
            }
        }
    }
    
    // MARK: - Test Notification View
    
    private var selectThoughtForTestView: some View {
        NavigationView {
            List {
                ForEach(thoughtViewModel.activeThoughts) { thought in
                    Button(action: {
                        selectedTestThought = thought
                        showTestNotificationSheet = false
                        // Show the test notification after a short delay
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            NotificationManager.shared.presentFullScreenNotification(for: thought)
                        }
                    }) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(thought.question)
                                .font(.headline)
                                .lineLimit(1)
                            
                            if let deadline = thought.deadline {
                                Text("Deadline: \(deadline.formatted(date: .abbreviated, time: .shortened))")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                if thoughtViewModel.activeThoughts.isEmpty {
                    Text("No active thoughts available to test")
                        .foregroundColor(.secondary)
                        .padding()
                }
            }
            .navigationTitle("Select a Thought")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        showTestNotificationSheet = false
                    }
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var biometricToggleLabel: String {
        switch authManager.biometricType {
        case .faceID:
            return "Use Face ID"
        case .touchID:
            return "Use Touch ID"
        case .none:
            return "Use Biometric Authentication"
        }
    }
    
    // MARK: - Subviews
    
    private var aboutView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("About Ryze")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom)
                
                Text("Rise beyond fear. Challenge catastrophic thinking. Discover reality.")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .padding(.bottom)
                
                Text("Ryze is designed to help you break free from fear-based thinking patterns that have been evolutionarily hardwired into our brains. While these instincts once served our survival, they now often limit our potential in the modern world.")
                
                Text("By building a personal database of expected vs. actual outcomes, you can develop greater emotional resilience and more balanced thinking.")
                    .padding(.top, 8)
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var privacyView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Privacy & Security")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom)
                
                Text("We believe your thoughts are deeply personal.")
                    .font(.headline)
                    .padding(.bottom)
                
                Group {
                    Text("By default, all your data stays on your device. Ryze is designed with privacy as a core principle.")
                    
                    Text("Your thoughts, outcomes, and personal insights are stored locally on your device and are not transmitted to any servers.")
                        .padding(.top, 8)
                }
                
                Group {
                    Text("Security Features")
                        .font(.headline)
                        .padding(.top, 16)
                        .padding(.bottom, 4)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(alignment: .top) {
                            Image(systemName: "lock.shield")
                                .foregroundColor(.blue)
                                .frame(width: 24)
                            VStack(alignment: .leading) {
                                Text("Biometric Authentication")
                                    .fontWeight(.semibold)
                                Text("When enabled, \(authManager.biometricType == .faceID ? "Face ID" : "Touch ID") is required to access the app, providing an extra layer of privacy.")
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        HStack(alignment: .top) {
                            Image(systemName: "key")
                                .foregroundColor(.blue)
                                .frame(width: 24)
                            VStack(alignment: .leading) {
                                Text("Secure Data Storage")
                                    .fontWeight(.semibold)
                                Text("Your data is stored securely on your device with additional encryption to protect your privacy.")
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        HStack(alignment: .top) {
                            Image(systemName: "icloud.slash")
                                .foregroundColor(.blue)
                                .frame(width: 24)
                            VStack(alignment: .leading) {
                                Text("No Cloud Storage")
                                    .fontWeight(.semibold)
                                Text("Your data is stored only on your device and not in the cloud, keeping your thoughts private.")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Privacy & Security")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    SettingsView()
        .environmentObject(ThoughtViewModel(dataStore: DataStore()))
}