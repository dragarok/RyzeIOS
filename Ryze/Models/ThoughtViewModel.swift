//
//  ThoughtViewModel.swift
//  Ryze
//
//  Created for Ryze app on 09/04/2025.
//

import SwiftUI
import SwiftData
import UIKit

// Make Thought conform to Sendable to fix warnings
extension Array: @unchecked Sendable where Element: AnyObject {}

// Main ViewModel to manage thought data
class ThoughtViewModel: ObservableObject {
    private let dataStore: DataStore
    
    // Published properties to reflect UI state
    @Published var thoughts: [Thought] = []
    @Published var activeThoughts: [Thought] = []
    @Published var resolvedThoughts: [Thought] = []
    
    // New thought creation properties
    @Published var newThoughtText: String = ""
    @Published var outcomeDescriptions: [OutcomeType: String] = [:]
    @Published var selectedExpectedOutcome: OutcomeType? = nil
    @Published var selectedDeadline: Date = Date().addingTimeInterval(86400) // Default to tomorrow
    
    // Current edit state
    @Published var currentThought: Thought? = nil
    @Published var isEditing: Bool = false
    
    init(dataStore: DataStore) {
        self.dataStore = dataStore
    }
    
    // MARK: - Data Loading
    
    func loadThoughts() async {
        // Load all thoughts from the data store
        let allThoughts = dataStore.fetchThoughts()
        let active = dataStore.fetchActiveThoughts()
        let resolved = dataStore.fetchResolvedThoughts()
        
        // Update on the main thread
        await MainActor.run {
            self.thoughts = allThoughts
            self.activeThoughts = active
            self.resolvedThoughts = resolved
            
            // Check for any passed deadlines that need follow-up notifications
            self.checkForPassedDeadlines()
        }
    }
    
    // MARK: - Thought Management
    
    func createNewThought() {
        // Validate input
        guard !newThoughtText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        guard selectedExpectedOutcome != nil else { return }
        
        if isEditing, let existingThought = currentThought {
            // Update existing thought
            let contextThought = dataStore.findThoughtByID(existingThought.id) ?? existingThought
            
            // Apply updates
            contextThought.question = newThoughtText
            contextThought.deadline = selectedDeadline
            contextThought.expectedOutcomeType = selectedExpectedOutcome
            
            // Remove old outcomes and create new ones
            if let outcomes = contextThought.outcomes {
                for outcome in outcomes {
                    dataStore.deleteOutcome(outcome)
                }
            }
            
            // Add new outcomes
            for (type, description) in outcomeDescriptions where !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                let outcome = Outcome(type: type, description: description)
                dataStore.saveOutcome(outcome, for: contextThought)
            }
            
            // Save the updated thought
            dataStore.updateThought(contextThought)
            
            // Update notifications if deadline changed
            NotificationManager.shared.cancelNotification(for: contextThought)
            if contextThought.deadline != nil {
                NotificationManager.shared.scheduleDeadlineNotification(for: contextThought)
            }
        } else {
            // Create the new thought
            let thought = Thought(question: newThoughtText)
            thought.deadline = selectedDeadline
            thought.expectedOutcomeType = selectedExpectedOutcome
            
            // Create outcomes for each filled out description
            for (type, description) in outcomeDescriptions where !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                let outcome = Outcome(type: type, description: description)
                dataStore.saveOutcome(outcome, for: thought)
            }
            
            // Save the thought
            dataStore.saveThought(thought)
            
            // Schedule a notification for the thought's deadline
            if thought.deadline != nil {
                NotificationManager.shared.scheduleDeadlineNotification(for: thought)
            }
        }
        
        // Reset the form
        resetForm()
        
        // Reload data
        Task {
            await loadThoughts()
        }
    }
    
    func resolveThought(_ thought: Thought, with actualOutcomeType: OutcomeType) {
        // First, ensure we're working with a thought that belongs to our context
        let contextThought = dataStore.findThoughtByID(thought.id) ?? thought
        
        // Apply the updates
        contextThought.actualOutcomeType = actualOutcomeType
        contextThought.isResolved = true
        contextThought.resolutionDate = Date()
        
        // Save the changes
        dataStore.updateThought(contextThought)
        
        // Now that the thought is resolved, cancel all notifications for it
        NotificationManager.shared.cancelNotification(for: contextThought)
        
        Task {
            await loadThoughts()
        }
    }
    
    func updateThoughtDeadline(_ thought: Thought, newDeadline: Date) {
        // First, ensure we're working with a thought that belongs to our context
        let contextThought = dataStore.findThoughtByID(thought.id) ?? thought
        
        // Apply the updates
        contextThought.deadline = newDeadline
        
        // Save the changes
        dataStore.updateThought(contextThought)
        
        // Cancel any existing notifications for this thought
        NotificationManager.shared.cancelNotification(for: contextThought)
        
        // Reschedule the notifications with the new deadline after a brief delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            NotificationManager.shared.scheduleDeadlineNotification(for: contextThought)
        }
        
        Task {
            await loadThoughts()
        }
    }
    
    func deleteThought(_ thought: Thought) {
        // First, ensure we're working with a thought that belongs to our context
        let contextThought = dataStore.findThoughtByID(thought.id) ?? thought
        
        // Cancel all notifications before deleting the thought
        NotificationManager.shared.cancelNotification(for: contextThought)
        
        dataStore.deleteThought(contextThought)
        
        Task {
            await loadThoughts()
        }
    }
    
    // MARK: - Notification Management
    
    private func checkForPassedDeadlines() {
        let now = Date()
        
        // Check each active thought for passed deadlines
        for thought in activeThoughts {
            if let deadline = thought.deadline, deadline < now, !thought.isResolved {
                // This thought's deadline has passed and it's not resolved
                // If it doesn't have any notifications or last notification was a while ago, reschedule
                
                if thought.lastNotificationDate == nil || 
                   (thought.lastNotificationDate != nil && 
                    Calendar.current.dateComponents([.minute], from: thought.lastNotificationDate!, to: now).minute ?? 0 > 10) {
                    
                    print("[ViewModel] Detected passed deadline for thought: \(thought.id) - scheduling recurring notifications")
                    
                    // Cancel any existing notifications first
                    NotificationManager.shared.cancelNotification(for: thought)
                    
                    // Schedule new set of recurring notifications starting from now
                    NotificationManager.shared.scheduleRecurringNotifications(for: thought, startDate: now)
                }
            }
        }
        
        // Update the app icon badge with the number of thoughts past deadline
        let pastDeadlineCount = getPastDeadlineCount()
        DispatchQueue.main.async {
            UIApplication.shared.applicationIconBadgeNumber = pastDeadlineCount
        }
    }
    
    // MARK: - Helper Methods
    // Get the count of unresolved thoughts past their deadline
    func getPastDeadlineCount() -> Int {
        let now = Date()
        let pastDeadlineCount = activeThoughts.filter { thought in
            guard let deadline = thought.deadline else { return false }
            return deadline < now && !thought.isResolved
        }.count
        
        return pastDeadlineCount
    }
    
    // Prepare the form for editing an existing thought
    func prepareForEditing(_ thought: Thought) {
        // Ensure we're working with a thought that belongs to our context
        let contextThought = dataStore.findThoughtByID(thought.id) ?? thought
        
        // Load the thought data into the form
        newThoughtText = contextThought.question
        selectedExpectedOutcome = contextThought.expectedOutcomeType
        selectedDeadline = contextThought.deadline ?? Date().addingTimeInterval(86400)
        
        // Load outcomes
        outcomeDescriptions = [:]
        if let outcomes = contextThought.outcomes {
            for outcome in outcomes {
                outcomeDescriptions[outcome.type] = outcome.outcomeDescription
            }
        }
        
        // Set editing state
        currentThought = contextThought
        isEditing = true
    }
    
    func resetForm() {
        newThoughtText = ""
        outcomeDescriptions = [:]
        selectedExpectedOutcome = nil
        selectedDeadline = Date().addingTimeInterval(86400)
        currentThought = nil
        isEditing = false
    }
}