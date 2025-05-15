//
//  NotificationView.swift
//  Ryze
//
//  Created for Ryze app on 10/04/2025.
//

import SwiftUI

/// A view that handles showing notifications in the app
struct NotificationView: View {
    @StateObject private var notificationManager = NotificationManager.shared
    @EnvironmentObject private var viewModel: ThoughtViewModel
    
    // Default initializer
    init() {}
    
    private func createNotificationViewModel() -> ThoughtViewModel {
        // Create a permanent DataStore that will persist data
        let permanentDataStore = DataStore()
        let newViewModel = ThoughtViewModel(dataStore: permanentDataStore)
        
        // Register with the notification manager for future use
        if notificationManager.thoughtViewModel == nil {
            notificationManager.thoughtViewModel = newViewModel
        }
        
        return notificationManager.thoughtViewModel ?? newViewModel
    }
    
    var body: some View {
        // This is a container view that only shows content when notifications trigger
        ZStack {
            // Empty view that's essentially invisible when not showing a notification
            Color.clear
                .frame(width: 0, height: 0)
            
            // Show full-screen notification when triggered
            if notificationManager.showDeadlineNotification,
               let thought = notificationManager.currentThought {
                FullScreenNotificationView(thought: thought, viewModel: createNotificationViewModel())
                    .transition(.opacity)
                    .zIndex(100) // Ensure it appears on top of everything
            }
        }
        .animation(.easeInOut, value: notificationManager.showDeadlineNotification)
    }
}

// MARK: - Integration Helpers

// Extension to make it easy to integrate the notification system throughout the app
extension View {
    /// Adds notification handling to any view in the app
    func withNotifications() -> some View {
        ZStack {
            self
            NotificationView()
        }
    }
}

// MARK: - Preview
struct NotificationView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .withNotifications()
            .environmentObject(ThoughtViewModel(dataStore: DataStore()))
    }
}