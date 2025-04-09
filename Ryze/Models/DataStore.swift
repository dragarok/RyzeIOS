//
//  DataStore.swift
//  Ryze
//
//  Created for Ryze app on 09/04/2025.
//

import SwiftUI
import SwiftData

// A simple class to manage data operations
class DataStore {
    private let modelContainer: ModelContainer
    private var context: ModelContext
    
    init() {
        do {
            // Configure model container and schema
            let schema = Schema([Thought.self, Outcome.self])
            let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            self.modelContainer = try ModelContainer(for: schema, configurations: [configuration])
            self.context = ModelContext(modelContainer)
        } catch {
            fatalError("Failed to create ModelContainer: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Thought Operations
    
    func saveThought(_ thought: Thought) {
        context.insert(thought)
        saveContext()
    }
    
    func fetchThoughts() -> [Thought] {
        let descriptor = FetchDescriptor<Thought>(sortBy: [SortDescriptor(\Thought.createdAt, order: .reverse)])
        do {
            return try context.fetch(descriptor)
        } catch {
            print("Failed to fetch thoughts: \(error.localizedDescription)")
            return []
        }
    }
    
    func fetchActiveThoughts() -> [Thought] {
        let predicate = #Predicate<Thought> { thought in
            thought.isResolved == false
        }
        var descriptor = FetchDescriptor<Thought>(predicate: predicate)
        descriptor.sortBy = [SortDescriptor(\Thought.deadline, order: .forward)]
        
        do {
            return try context.fetch(descriptor)
        } catch {
            print("Failed to fetch active thoughts: \(error.localizedDescription)")
            return []
        }
    }
    
    func fetchResolvedThoughts() -> [Thought] {
        let predicate = #Predicate<Thought> { thought in
            thought.isResolved == true
        }
        var descriptor = FetchDescriptor<Thought>(predicate: predicate)
        descriptor.sortBy = [SortDescriptor(\Thought.deadline, order: .reverse)]
        
        do {
            return try context.fetch(descriptor)
        } catch {
            print("Failed to fetch resolved thoughts: \(error.localizedDescription)")
            return []
        }
    }
    
    func updateThought(_ thought: Thought) {
        saveContext()
    }
    
    func deleteThought(_ thought: Thought) {
        context.delete(thought)
        saveContext()
    }
    
    // MARK: - Outcome Operations
    
    func saveOutcome(_ outcome: Outcome, for thought: Thought) {
        thought.outcomes?.append(outcome)
        outcome.thought = thought
        saveContext()
    }
    
    // MARK: - Helper Methods
    
    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("Failed to save context: \(error.localizedDescription)")
        }
    }
}