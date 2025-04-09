//
//  ThoughtViewModel.swift
//  Ryze
//
//  Created for Ryze app on 09/04/2025.
//

import SwiftUI
import SwiftData

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
        }
    }
    
    // MARK: - Thought Management
    
    func createNewThought() {
        // Validate input
        guard !newThoughtText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        guard selectedExpectedOutcome != nil else { return }
        
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
        
        // Reset the form
        resetForm()
        
        // Reload data
        Task {
            await loadThoughts()
        }
    }
    
    func resolveThought(_ thought: Thought, with actualOutcomeType: OutcomeType) {
        thought.actualOutcomeType = actualOutcomeType
        thought.isResolved = true
        dataStore.updateThought(thought)
        
        Task {
            await loadThoughts()
        }
    }
    
    func deleteThought(_ thought: Thought) {
        dataStore.deleteThought(thought)
        
        Task {
            await loadThoughts()
        }
    }
    
    // MARK: - Helper Methods
    
    func resetForm() {
        newThoughtText = ""
        outcomeDescriptions = [:]
        selectedExpectedOutcome = nil
        selectedDeadline = Date().addingTimeInterval(86400)
        currentThought = nil
        isEditing = false
    }
}