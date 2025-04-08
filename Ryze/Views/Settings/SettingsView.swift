//
//  SettingsView.swift
//  Ryze
//
//  Created on 08/04/2025.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("useBiometricAuth") private var useBiometricAuth = false
    @AppStorage("reminderNotification") private var reminderNotification = true
    @State private var showAbout = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Privacy & Security")) {
                    Toggle("Use Face ID / Touch ID", isOn: $useBiometricAuth)
                }
                
                Section(header: Text("Notifications")) {
                    Toggle("Deadline Reminders", isOn: $reminderNotification)
                }
                
                Section(header: Text("About")) {
                    Button("About Ryze") {
                        showAbout = true
                    }
                    
                    Link("Privacy Policy", destination: URL(string: "https://ryzeapp.com/privacy")!)
                        .foregroundColor(.primary)
                }
                
                Section(header: Text("Data Management")) {
                    Button("Export Your Data") {
                        // Implementation will be added later
                    }
                    .foregroundColor(.primary)
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showAbout) {
                AboutView()
            }
        }
    }
}

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 72))
                        .foregroundColor(.blue)
                        .padding(.top, 40)
                    
                    Text("Ryze")
                        .font(.largeTitle)
                        .bold()
                    
                    Text("Rise beyond fear. Challenge catastrophic thinking. Discover reality.")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("About Ryze")
                            .font(.title3)
                            .bold()
                        
                        Text("Ryze helps you break free from fear-based thinking patterns by tracking your thoughts, predictions, and actual outcomes. By building a personal database of expected vs. actual outcomes, you can develop greater emotional resilience and more balanced thinking.")
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("Version 0.1")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 20)
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}