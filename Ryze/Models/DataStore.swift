//
//  DataStore.swift
//  Ryze
//
//  Created for Ryze app on 09/04/2025.
//

import SwiftUI
import SwiftData
import Foundation
import Security

// A simple class to manage data operations
class DataStore {
    private let modelContainer: ModelContainer
    private var context: ModelContext
    
    init() {
        do {
            // Get security preference directly from UserDefaults
            let secureStorageEnabled = UserDefaults.standard.bool(forKey: "secureDataStorage")
            
            // Configure model container and schema
            let schema = Schema([Thought.self, Outcome.self])
            
            // Configure storage security based on settings
            var configuration: ModelConfiguration
            
            if secureStorageEnabled {
                // Enhanced security configuration with encryption
                let url = DataStore.getSecureStoreURL()
                configuration = ModelConfiguration(schema: schema, url: url, allowsSave: true)
            } else {
                // Standard configuration
                configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            }
            
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
        // Always use the context on the main thread to avoid threading issues
        if Thread.isMainThread {
            return fetchThoughtsInternal()
        } else {
            // If we're not on the main thread, dispatch synchronously to the main thread
            var result: [Thought] = []
            DispatchQueue.main.sync {
                result = fetchThoughtsInternal()
            }
            return result
        }
    }
    
    // Internal implementation that should only be called on the main thread
    private func fetchThoughtsInternal() -> [Thought] {
        let descriptor = FetchDescriptor<Thought>(sortBy: [SortDescriptor(\Thought.createdAt, order: .reverse)])
        do {
            return try context.fetch(descriptor)
        } catch {
            print("Failed to fetch thoughts: \(error.localizedDescription)")
            return []
        }
    }
    
    func fetchActiveThoughts() -> [Thought] {
        // Always use the context on the main thread to avoid threading issues
        if Thread.isMainThread {
            return fetchActiveThoughtsInternal()
        } else {
            // If we're not on the main thread, dispatch synchronously to the main thread
            var result: [Thought] = []
            DispatchQueue.main.sync {
                result = fetchActiveThoughtsInternal()
            }
            return result
        }
    }
    
    // Internal implementation that should only be called on the main thread
    private func fetchActiveThoughtsInternal() -> [Thought] {
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
        // Always use the context on the main thread to avoid threading issues
        if Thread.isMainThread {
            return fetchResolvedThoughtsInternal()
        } else {
            // If we're not on the main thread, dispatch synchronously to the main thread
            var result: [Thought] = []
            DispatchQueue.main.sync {
                result = fetchResolvedThoughtsInternal()
            }
            return result
        }
    }
    
    // Internal implementation that should only be called on the main thread
    private func fetchResolvedThoughtsInternal() -> [Thought] {
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
    
    func deleteOutcome(_ outcome: Outcome) {
        context.delete(outcome)
        saveContext()
    }
    
    // MARK: - Helper Methods
    func findThoughtByID(_ id: UUID) -> Thought? {
        if Thread.isMainThread {
            return findThoughtByIDInternal(id)
        } else {
            var result: Thought? = nil
            DispatchQueue.main.sync {
                result = findThoughtByIDInternal(id)
            }
            return result
        }
    }
    
    // Internal implementation, must be called on main thread
    private func findThoughtByIDInternal(_ id: UUID) -> Thought? {
        let predicate = #Predicate<Thought> { thought in
            thought.id == id
        }
        let descriptor = FetchDescriptor<Thought>(predicate: predicate)
        
        do {
            let thoughts = try context.fetch(descriptor)
            return thoughts.first
        } catch {
            print("Failed to find thought by ID: \(error.localizedDescription)")
            return nil
        }
    }
    
    private func saveContext() {
        // Ensure we're on the main thread for all SwiftData operations
        if Thread.isMainThread {
            saveContextInternal()
        } else {
            // If we're not on the main thread, dispatch synchronously to the main thread
            DispatchQueue.main.sync {
                saveContextInternal()
            }
        }
    }
    
    private func saveContextInternal() {
        do {
            try context.save()
        } catch {
            print("Failed to save context: \(error.localizedDescription)")
        }
    }
    
    // Get a secure URL for data storage with additional protection
    private static func getSecureStoreURL() -> URL {
        let fileManager = FileManager.default
        
        // Get the app's document directory
        let appSupportDirectory = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        
        // Create a specific directory for our secure data
        let secureDataDirectory = appSupportDirectory.appendingPathComponent("SecureRyzeData", isDirectory: true)
        
        // Create the directory if it doesn't exist
        if !fileManager.fileExists(atPath: secureDataDirectory.path) {
            do {
                try fileManager.createDirectory(at: secureDataDirectory, withIntermediateDirectories: true, attributes: [
                    // Set file protection - requires device to be unlocked to access data
                    FileAttributeKey.protectionKey: FileProtectionType.complete
                ])
            } catch {
                print("Error creating secure directory: \(error.localizedDescription)")
                // Fallback to app support directory if we can't create the secure directory
                return appSupportDirectory
            }
        }
        
        // Return the URL to our secure database location
        return secureDataDirectory.appendingPathComponent("RyzeSecure.sqlite")
    }
}