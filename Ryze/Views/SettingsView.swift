//
//  SettingsView.swift
//  Ryze
//
//  Created for Ryze app on 09/04/2025.
//

import SwiftUI

struct SettingsView: View {
    // Settings state
    @AppStorage("useBiometricAuth") private var useBiometricAuth = false
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("reminderTime") private var reminderTime = 3600.0 // Default 1 hour before deadline
    
    // App info
    private let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    private let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    
    var body: some View {
        NavigationStack {
            List {
                // Security section
                Section("Security") {
                    Toggle("Use Face ID / Touch ID", isOn: $useBiometricAuth)
                        .tint(.blue)
                }
                
                // Notifications section
                Section("Notifications") {
                    Toggle("Enable Notifications", isOn: $notificationsEnabled)
                        .tint(.blue)
                    
                    if notificationsEnabled {
                        VStack(alignment: .leading) {
                            Text("Reminder Time Before Deadline")
                            Slider(value: $reminderTime, in: 0...86400) {
                                Text("Reminder Time")
                            } minimumValueLabel: {
                                Text("0h")
                            } maximumValueLabel: {
                                Text("24h")
                            }
                            .tint(.blue)
                            
                            Text(reminderTimeFormatted)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
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
                    
                    NavigationLink(destination: privacyView) {
                        Text("Privacy")
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
    
    // MARK: - Computed Properties
    
    private var reminderTimeFormatted: String {
        let hours = Int(reminderTime) / 3600
        let minutes = (Int(reminderTime) % 3600) / 60
        
        if hours > 0 {
            return "\(hours) hour\(hours > 1 ? "s" : "") \(minutes > 0 ? "\(minutes) minute\(minutes > 1 ? "s" : "")" : "") before deadline"
        } else {
            return "\(minutes) minute\(minutes > 1 ? "s" : "") before deadline"
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
                Text("Privacy")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom)
                
                Text("We believe your thoughts are deeply personal.")
                    .font(.headline)
                    .padding(.bottom)
                
                Text("By default, all your data stays on your device. Ryze is designed with privacy as a core principle.")
                
                Text("Your thoughts, outcomes, and personal insights are stored locally on your device and are not transmitted to any servers.")
                    .padding(.top, 8)
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Privacy")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    SettingsView()
}