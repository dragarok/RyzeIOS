//
//  NotificationManager.swift
//  Ryze
//
//  Created on 08/04/2025.
//

import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    func requestAuthorization() async throws -> Bool {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        return try await UNUserNotificationCenter.current().requestAuthorization(options: options)
    }
    
    func scheduleDeadlineReminder(for thought: Thought) async throws {
        // Check if notifications are enabled
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        guard settings.authorizationStatus == .authorized else { return }
        
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "Time to check your prediction"
        content.body = thought.question
        content.sound = .default
        content.userInfo = ["thoughtId": thought.id.uuidString]
        
        // Create trigger based on deadline
        let triggerDate = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: thought.deadline
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        // Create request
        let identifier = "thought-deadline-\(thought.id.uuidString)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        // Schedule notification
        try await UNUserNotificationCenter.current().add(request)
    }
    
    func cancelDeadlineReminder(for thought: Thought) {
        let identifier = "thought-deadline-\(thought.id.uuidString)"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
}