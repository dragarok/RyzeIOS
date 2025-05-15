//
//  NotificationManager.swift
//  Ryze
//
//  Created for Ryze app on 10/04/2025.
//

import SwiftUI
import UserNotifications
import AVFoundation

class NotificationManager: NSObject, ObservableObject {
    // Singleton instance
    static let shared = NotificationManager()
    
    // Published properties to control notification UI
    @Published var showDeadlineNotification = false
    @Published var currentThought: Thought? = nil
    
    // Reference to the app's view model (set from RyzeApp)
    var thoughtViewModel: ThoughtViewModel? = nil
    
    // Audio player for notification sound
    private var audioPlayer: AVAudioPlayer?
    
    // Notification categories
    private let deadlineCategoryId = "THOUGHT_DEADLINE"
    private let followUpCategoryId = "THOUGHT_FOLLOWUP"
    
    // Maximum number of recurring notifications to schedule
    private let maxRecurringNotifications = 10
    
    // Notification interval in minutes (for development)
    // Will be changed to days in production
    private let notificationIntervalMinutes = 2
    
    // Delegate for UNUserNotificationCenter
    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
        setupNotificationCategories()
    }
    
    // Set up notification categories and actions
    private func setupNotificationCategories() {
        // Define actions for deadline notifications
        let resolveAction = UNNotificationAction(
            identifier: "RESOLVE_ACTION",
            title: "Record Outcome",
            options: .foreground
        )
        
        let rescheduleAction = UNNotificationAction(
            identifier: "RESCHEDULE_ACTION",
            title: "Reschedule",
            options: .foreground
        )
        
        // Create categories
        let deadlineCategory = UNNotificationCategory(
            identifier: deadlineCategoryId,
            actions: [resolveAction, rescheduleAction],
            intentIdentifiers: [],
            options: .customDismissAction
        )
        
        let followupCategory = UNNotificationCategory(
            identifier: followUpCategoryId,
            actions: [resolveAction, rescheduleAction],
            intentIdentifiers: [],
            options: .customDismissAction
        )
        
        // Register the categories
        UNUserNotificationCenter.current().setNotificationCategories([deadlineCategory, followupCategory])
    }
    
    // Request notification permissions
    func requestAuthorization() {
        // Adding .criticalAlert requires an entitlement that would be granted by Apple for specific use cases
        // For standard app behavior, we'll use the normal notification options
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound, .provisional]) { granted, error in
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
        
        print("[Notification] Scheduling deadline notification for thought: \(thought.id)")
        
        // Remove any existing notifications for this thought
        cancelNotification(for: thought)
        
        // Create the notification content
        let content = UNMutableNotificationContent()
        content.title = "⏰ DEADLINE REACHED"
        content.body = "It's time to check your thought: \(thought.question)"
        // Use a prominent notification sound
        content.sound = UNNotificationSound.defaultCritical
        // Make the notification stay on screen until dismissed
        content.interruptionLevel = .timeSensitive
        // Add specific category identifier for actions
        content.categoryIdentifier = deadlineCategoryId
        
        // Store the thought ID and timestamp in the notification
        content.userInfo = [
            "thoughtID": thought.id.uuidString,
            "notificationType": "deadline",
            "timestamp": Date().timeIntervalSince1970
        ]
        
        // Create a calendar trigger for the deadline
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: deadline)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        // Create the request with a unique identifier that includes timestamp to avoid conflicts
        let identifier = "thought-deadline-\(thought.id.uuidString)-\(Date().timeIntervalSince1970)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        // Schedule the notification
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                // Schedule recurring follow-up notifications starting from the deadline
                self.scheduleRecurringNotifications(for: thought, startDate: deadline)
            }
        }
    }
    
    // Schedule multiple recurring notifications for an unresolved thought
    func scheduleRecurringNotifications(for thought: Thought, startDate: Date) {
        // Only schedule recurring notifications if the thought isn't resolved yet
        guard !thought.isResolved else { return }
        
        print("[Notification] Scheduling \(maxRecurringNotifications) recurring notifications for thought: \(thought.id)")
        
        // Schedule up to maxRecurringNotifications notifications at fixed intervals
        let timestamp = Date().timeIntervalSince1970
        
        for index in 1...maxRecurringNotifications {
            // Create the notification content
            let content = UNMutableNotificationContent()
            content.title = "⏰ REMINDER \(index)/\(maxRecurringNotifications): Thought Needs Resolution"
            content.body = "You haven't recorded the outcome yet: \(thought.question)"
            content.sound = UNNotificationSound.defaultCritical
            content.interruptionLevel = .timeSensitive
            content.categoryIdentifier = followUpCategoryId
            content.badge = NSNumber(value: index)
            
            // Store the thought ID, notification type, and index
            content.userInfo = [
                "thoughtID": thought.id.uuidString,
                "notificationType": "followup",
                "notificationIndex": index,
                "timestamp": timestamp
            ]
            
            // Create a trigger for the next interval from the start date
            // Using minutes for development purposes (will be changed to days)
            let intervalMinutes = notificationIntervalMinutes * index
            let triggerDate = Calendar.current.date(byAdding: .minute, value: intervalMinutes, to: startDate) ?? Date()
            let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            
            // Create a unique identifier for this follow-up notification that includes the index
            let identifier = "thought-followup-\(thought.id.uuidString)-\(index)-\(timestamp)"
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            
            // Schedule the notification
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling recurring notification \(index): \(error.localizedDescription)")
                }
            }
        }
        
        // Update the last notification date to now
        thought.lastNotificationDate = Date()
    }
    
    // Schedule a follow-up notification for unresolved thoughts
    // Cancel all notifications for a specific thought
    func cancelNotification(for thought: Thought) {
        // Get pending notification requests
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            // Filter for notifications related to this thought
            let identifiers = requests.compactMap { request -> String? in
                if let thoughtID = request.content.userInfo["thoughtID"] as? String,
                   thoughtID == thought.id.uuidString {
                    return request.identifier
                }
                return nil
            }
            
            // Remove all matching notifications
            if !identifiers.isEmpty {
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
            }
        }
    }
    
    // Find a thought by its ID
    // Find a thought by its ID with better error handling and logging
    func findThought(withID id: UUID, dataStore: DataStore) -> Thought? {
        print("[Notification] Attempting to find thought with ID: \(id)")
        
        // Use the findThoughtByID method if available (which will be more efficient)
        // Otherwise fall back to the old approach
        if let thought = dataStore.findThoughtByID(id) {
            print("[Notification] Successfully found thought: \(thought.question)")
            return thought
        }
        
        // Fallback to the old approach if needed
        let thoughts = dataStore.fetchThoughts()
        print("[Notification] Found \(thoughts.count) thoughts in the data store")
        
        let thought = thoughts.first { $0.id == id }
        if let thought = thought {
            print("[Notification] Successfully found thought: \(thought.question)")
        } else {
            print("[Notification] WARNING: Could not find thought with ID: \(id)")
        }
        return thought
    }
    
    // Present the full-screen notification for a specific thought
    func presentFullScreenNotification(for thought: Thought) {
        // We're now more tolerant of a missing view model
        // It will be provided later when the view appears
        if self.thoughtViewModel == nil {
            print("[Notification] Warning: No view model available for notification yet, but proceeding anyway")
            // The app will set it later during initialization
        }
        
        print("[Notification] Presenting full screen notification for thought: \(thought.question)")
        
        DispatchQueue.main.async {
            self.currentThought = thought
            self.showDeadlineNotification = true
            self.playNotificationSound()
        }
    }
    
    // Play a notification sound when the full-screen notification appears
    private func playNotificationSound() {
        // Create haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
        
        // Use system sound for simplicity
        AudioServicesPlaySystemSound(1005) // This is a notification sound ID
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension NotificationManager: UNUserNotificationCenterDelegate {
    // Handle notification when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Extract the thought ID from the notification
        if let thoughtIDString = notification.request.content.userInfo["thoughtID"] as? String,
           let thoughtID = UUID(uuidString: thoughtIDString) {
            
            // Try to find the thought using the thoughtViewModel if available
            if let viewModel = self.thoughtViewModel, let thought = viewModel.thoughts.first(where: { $0.id == thoughtID }) {
                let notificationType = notification.request.content.userInfo["notificationType"] as? String ?? "unknown"
                print("[Notification] Presenting notification for thought: \(thought.id), type: \(notificationType)")
                
                // Present the full-screen notification
                presentFullScreenNotification(for: thought)
                
                // Don't show the system notification since we're displaying our custom UI
                completionHandler([])
                
                // Update the last notification date
                thought.lastNotificationDate = Date()
            } else {
                // If the view model isn't available, or we can't find the thought, create a persistent data store
                let permanentDataStore = DataStore()
                if let thought = findThought(withID: thoughtID, dataStore: permanentDataStore) {
                    // Create a persistent view model that will be used throughout the app lifecycle
                    let persistentViewModel = ThoughtViewModel(dataStore: permanentDataStore)
                    self.thoughtViewModel = persistentViewModel
                    
                    // Load thoughts in the background to ensure the view model is populated
                    Task {
                        await persistentViewModel.loadThoughts()
                        
                        // After loading the thoughts, find the thought in the permanent context
                        DispatchQueue.main.async {
                            if let permanentThought = permanentDataStore.findThoughtByID(thoughtID) {
                                // Present the notification with the permanent thought object
                                self.presentFullScreenNotification(for: permanentThought)
                            }
                        }
                    }
                    
                    // Present the notification with the temporary thought for now
                    self.presentFullScreenNotification(for: thought)
                    completionHandler([])
                } else {
                    // If we still can't find the thought, show the system notification
                    completionHandler([.banner, .sound])
                }
            }
        } else {
            // If we can't extract thought ID, show the system notification
            completionHandler([.banner, .sound])
        }
    }
    
    // Handle when a notification is tapped
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("[Notification] Notification tapped with action: \(response.actionIdentifier)")
        
        // Extract the thought ID from the notification
        if let thoughtIDString = response.notification.request.content.userInfo["thoughtID"] as? String,
           let thoughtID = UUID(uuidString: thoughtIDString) {
            
            // Try to find the thought using the thoughtViewModel if available
            if let viewModel = self.thoughtViewModel, let thought = viewModel.thoughts.first(where: { $0.id == thoughtID }) {
                // Normal flow - we have the view model and can find the thought
                presentFullScreenNotification(for: thought)
                
                // Update the last notification date
                thought.lastNotificationDate = Date()
            } else {
                // If thoughtViewModel is nil or empty, we need to create a persistent data store
                let permanentDataStore = DataStore()
                if let thought = findThought(withID: thoughtID, dataStore: permanentDataStore) {
                    // Create a persistent view model that will be used throughout the app lifecycle
                    let persistentViewModel = ThoughtViewModel(dataStore: permanentDataStore)
                    self.thoughtViewModel = persistentViewModel
                    
                    // Load thoughts in the background to ensure the view model is populated
                    Task {
                        await persistentViewModel.loadThoughts()
                        
                        // After loading the thoughts, we need to retrieve this thought from
                        // our permanent context
                        DispatchQueue.main.async {
                            // Find the thought again in our permanent context
                            if let permanentThought = permanentDataStore.findThoughtByID(thoughtID) {
                                // Present the notification with the thought from the permanent context
                                self.presentFullScreenNotification(for: permanentThought)
                            }
                        }
                    }
                    
                    // This is a temporary presentation with the original thought object
                    // Will be replaced by the permanent one after loading completes
                    presentFullScreenNotification(for: thought)
                    
                    print("[Notification] Created persistent ViewModel for launched app")
                }
            }
        }
        
        completionHandler()
    }
}
