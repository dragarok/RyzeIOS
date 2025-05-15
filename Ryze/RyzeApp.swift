//
//  RyzeApp.swift
//  Ryze
//
//  Created by Alok Regmi on 07/04/2025.
//

import SwiftUI
import SwiftData

@main
struct RyzeApp: App {
    // Initialize the notification manager
    @StateObject private var notificationManager = NotificationManager.shared
    
    // Initialize the authentication manager
    @StateObject private var authManager = AuthenticationManager.shared
    
    // Create a shared view model instance
    @StateObject private var thoughtViewModel: ThoughtViewModel
    
    // Onboarding state
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @State private var showOnboarding: Bool = false
    
    // Initialize dependencies
    init() {
        // Create data store
        let dataStore = DataStore()
        
        // Create view model with the data store
        let viewModel = ThoughtViewModel(dataStore: dataStore)
        _thoughtViewModel = StateObject(wrappedValue: viewModel)
        
        // Detect available biometric authentication types
        authManager.detectBiometricType()
        
        // Set the view model in the notification manager as early as possible
        notificationManager.thoughtViewModel = viewModel
        
        // Load thoughts from data store immediately
        Task {
            await viewModel.loadThoughts()
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                    .environmentObject(thoughtViewModel)
                    .withNotifications() // Add notification handling
                    .withAuthentication() // Add authentication handling
                    .onAppear {
                        // Request notification permissions when the app launches
                        notificationManager.requestAuthorization()
                        
                        // Double-check the view model is assigned to notification manager
                        // This ensures it's set even if the app was launched from a notification
                        notificationManager.thoughtViewModel = thoughtViewModel
                        
                        // Make sure thoughts are loaded
                        Task {
                            await thoughtViewModel.loadThoughts()
                            
                            // If we have a pending notification from app launch, this will update with the loaded data
                            if notificationManager.showDeadlineNotification, let thought = notificationManager.currentThought {
                                DispatchQueue.main.async {
                                    // Refresh the notification with loaded data
                                    notificationManager.showDeadlineNotification = true
                                }
                            }
                        }
                        
                        // Show onboarding only if it hasn't been completed yet
                        if !hasCompletedOnboarding {
                            showOnboarding = true
                        }
                    }
                
                // Show onboarding overlay if needed
                if showOnboarding {
                    OnboardingView(viewModel: thoughtViewModel, showOnboarding: $showOnboarding)
                        .transition(.opacity)
                        .zIndex(1)
                        .onChange(of: showOnboarding) { oldValue, newValue in
                            if !newValue {
                                // Mark onboarding as completed when dismissed
                                hasCompletedOnboarding = true
                            }
                        }
                }
            }
        }
    }
}