//
//  DataStore.swift
//  Ryze
//
//  Created on 08/04/2025.
//

import Foundation
import Combine

// Protocol defining data persistence operations
protocol DataStoreProtocol {
    // Thoughts
    func saveThought(_ thought: Thought) async throws
    func getThought(id: UUID) async throws -> Thought?
    func getAllThoughts() async throws -> [Thought]
    func updateThought(_ thought: Thought) async throws
    func deleteThought(id: UUID) async throws
    
    // Publishers for reactive UI updates
    var thoughtsPublisher: AnyPublisher<[Thought], Never> { get }
}

class DataStore: DataStoreProtocol, ObservableObject {
    // Using published properties for SwiftUI integration
    @Published private var thoughts: [Thought] = []
    
    // Expose thoughts as a publisher for reactive UI
    var thoughtsPublisher: AnyPublisher<[Thought], Never> {
        $thoughts.eraseToAnyPublisher()
    }
    
    // File URL for storing thoughts
    private var thoughtsFileURL: URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent("thoughts.json")
    }
    
    init() {
        // Load saved thoughts when initialized
        Task {
            do {
                try await loadThoughts()
            } catch {
                print("Failed to load thoughts: \(error)")
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func loadThoughts() async throws {
        let fileManager = FileManager.default
        
        guard fileManager.fileExists(atPath: thoughtsFileURL.path) else {
            // If file doesn't exist yet, initialize with empty array
            self.thoughts = []
            return
        }
        
        let data = try Data(contentsOf: thoughtsFileURL)
        let decoder = JSONDecoder()
        let loadedThoughts = try decoder.decode([Thought].self, from: data)
        
        // Update on main thread since it affects UI
        await MainActor.run {
            self.thoughts = loadedThoughts
        }
    }
    
    private func saveThoughtsToFile() async throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(self.thoughts)
        try data.write(to: thoughtsFileURL)
    }
    
    // MARK: - DataStoreProtocol Implementation
    
    func saveThought(_ thought: Thought) async throws {
        await MainActor.run {
            // Add the new thought to our array
            self.thoughts.append(thought)
        }
        // Persist to file
        try await saveThoughtsToFile()
    }
    
    func getThought(id: UUID) async throws -> Thought? {
        return self.thoughts.first { $0.id == id }
    }
    
    func getAllThoughts() async throws -> [Thought] {
        return self.thoughts
    }
    
    func updateThought(_ updatedThought: Thought) async throws {
        await MainActor.run {
            // Find and update the thought
            if let index = self.thoughts.firstIndex(where: { $0.id == updatedThought.id }) {
                self.thoughts[index] = updatedThought
            }
        }
        // Persist to file
        try await saveThoughtsToFile()
    }
    
    func deleteThought(id: UUID) async throws {
        await MainActor.run {
            // Remove the thought
            self.thoughts.removeAll { $0.id == id }
        }
        // Persist to file
        try await saveThoughtsToFile()
    }
}