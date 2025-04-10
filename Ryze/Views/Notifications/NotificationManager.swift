//
//  NotificationManager.swift
//  Ryze
//
//  Created for Ryze app on 10/04/2025.
//

import SwiftUI
import UserNotifications

class NotificationManager: NSObject, ObservableObject {
    // Singleton instance
    static let shared = NotificationManager()
    
    // Published properties to control notification UI
    @Published var showDeadlineNotification = false
    @Published var currentThought: Thought? = nil
    
    // Reference to the app's view model (set from RyzeApp)
    var thoughtViewModel: ThoughtViewModel? = nil
    
    // Delegate for UNUserNotificationCenter
    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    // Request notification permissions
    func requestAuthorization() {
        // Adding .criticalAlert requires an entitlement that would be granted by Apple for specific use cases
        // For standard app behavior, we'll use the normal notification options
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification authorization granted")
            } else if let error = error {
                print("Notification authorization denied: \(error.localizedDescription)")
            }
        }
    }
    
    // Schedule a notification for a thought's deadline
    func scheduleDeadlineNotification(for thought: Thought) {
        // Make sure we have a deadline to notify for
        guard let deadline = thought.deadline else { return }
        
        // Remove any existing notifications for this thought
        cancelNotification(for: thought)
        
        // Create the notification content
        let content = UNMutableNotificationContent()
        content.title = "⏰ DEADLINE REACHED ⏰"
        content.body = "It's time to check your thought: \(thought.question)"
        // Use a prominent notification sound
        content.sound = UNNotificationSound.defaultCritical
        // Make the notification stay on screen until dismissed
        content.interruptionLevel = .timeSensitive
        
        // Store the thought ID in the notification
        content.userInfo = ["thoughtID": thought.id.uuidString]
        
        // Create a calendar trigger for the deadline
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: deadline)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        // Create the request
        let request = UNNotificationRequest(identifier: "thought-\(thought.id.uuidString)", content: content, trigger: trigger)
        
        // Schedule the notification
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
    
    // Cancel a notification for a specific thought
    func cancelNotification(for thought: Thought) {
        let identifier = "thought-\(thought.id.uuidString)"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    // Find a thought by its ID
    func findThought(withID id: UUID, dataStore: DataStore) -> Thought? {
        return dataStore.fetchThoughts().first { $0.id == id }
    }
    
    // Present the full-screen notification for a specific thought
    func presentFullScreenNotification(for thought: Thought) {
        // Make sure we have a view model - either use the one provided by the app or create a new one
        if self.thoughtViewModel == nil {
            self.thoughtViewModel = ThoughtViewModel(dataStore: DataStore())
        }
        
        DispatchQueue.main.async {
            self.currentThought = thought
            self.showDeadlineNotification = true
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension NotificationManager: UNUserNotificationCenterDelegate {
    // Handle notification when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Extract the thought ID from the notification
        if let thoughtIDString = notification.request.content.userInfo["thoughtID"] as? String,
           let thoughtID = UUID(uuidString: thoughtIDString),
           let dataStore = try? DataStore(),
           let thought = findThought(withID: thoughtID, dataStore: dataStore) {
            // Present the full-screen notification
            presentFullScreenNotification(for: thought)
            
            // Don't show the system notification since we're displaying our custom UI
            completionHandler([])
        } else {
            // If we can't find the thought, show the system notification
            completionHandler([.banner, .sound])
        }
    }
    
    // Handle when a notification is tapped
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Extract the thought ID from the notification
        if let thoughtIDString = response.notification.request.content.userInfo["thoughtID"] as? String,
           let thoughtID = UUID(uuidString: thoughtIDString),
           let dataStore = try? DataStore(),
           let thought = findThought(withID: thoughtID, dataStore: dataStore) {
            // Present the full-screen notification
            presentFullScreenNotification(for: thought)
        }
        
        completionHandler()
    }
}