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
    
    // Create a shared view model instance
    @StateObject private var thoughtViewModel: ThoughtViewModel
    
    // Initialize dependencies
    init() {
        // Create data store
        let dataStore = DataStore()
        
        // Create view model with the data store
        let viewModel = ThoughtViewModel(dataStore: dataStore)
        _thoughtViewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(thoughtViewModel)
                .withNotifications() // Add notification handling
                .onAppear {
                    // Request notification permissions when the app launches
                    notificationManager.requestAuthorization()
                    // Assign the view model to the notification manager
                    notificationManager.thoughtViewModel = thoughtViewModel
                }
        }
    }
}