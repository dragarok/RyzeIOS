//
//  ThoughtViewModel.swift
//  Ryze
//
//  Created on 08/04/2025.
//

import Foundation
import Combine
import SwiftUI

class ThoughtViewModel: ObservableObject {
    // Published properties for UI binding
    @Published var thoughts: [Thought] = []
    @Published var filteredThoughts: [Thought] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    // Filter state
    @Published var showResolved: Bool = true
    @Published var showUnresolved: Bool = true
    
    // Sorting state
    enum SortOption: String, CaseIterable {
        case dateCreatedNewest = "Date Created (Newest)"
        case dateCreatedOldest = "Date Created (Oldest)"
        case deadlineClosest = "Deadline (Closest)"
        case deadlineFurthest = "Deadline (Furthest)"
    }
    
    @Published var sortOption: SortOption = .dateCreatedNewest
    
    // Dependencies
    private let dataStore: DataStoreProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // Initializer with dependency injection
    init(dataStore: DataStoreProtocol) {
        self.dataStore = dataStore
        
        // Subscribe to data changes
        setupSubscriptions()
    }
    
    private func setupSubscriptions() {
        // Subscribe to data store changes
        dataStore.thoughtsPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] thoughts in
                self?.thoughts = thoughts
                self?.applyFiltersAndSort()
            }
            .store(in: &cancellables)
        
        // Subscribe to filter changes
        $showResolved
            .combineLatest($showUnresolved, $sortOption)
            .receive(on: RunLoop.main)
            .sink { [weak self] _, _, _ in
                self?.applyFiltersAndSort()
            }
            .store(in: &cancellables)
    }
    
    // Apply filters and sorting
    private func applyFiltersAndSort() {
        var filtered = thoughts
        
        // Apply resolved/unresolved filters
        if !showResolved {
            filtered = filtered.filter { !$0.isResolved }
        }
        
        if !showUnresolved {
            filtered = filtered.filter { $0.isResolved }
        }
        
        // Apply sorting
        switch sortOption {
        case .dateCreatedNewest:
            filtered.sort { $0.createdAt > $1.createdAt }
        case .dateCreatedOldest:
            filtered.sort { $0.createdAt < $1.createdAt }
        case .deadlineClosest:
            filtered.sort { $0.deadline < $1.deadline }
        case .deadlineFurthest:
            filtered.sort { $0.deadline > $1.deadline }
        }
        
        filteredThoughts = filtered
    }
    
    // MARK: - Public Methods
    
    func loadThoughts() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let loadedThoughts = try await dataStore.getAllThoughts()
            
            await MainActor.run {
                self.thoughts = loadedThoughts
                self.applyFiltersAndSort()
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to load thoughts: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    func saveThought(_ thought: Thought) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await dataStore.saveThought(thought)
            await MainActor.run {
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to save thought: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    func updateThought(_ thought: Thought) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await dataStore.updateThought(thought)
            await MainActor.run {
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to update thought: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    func deleteThought(id: UUID) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await dataStore.deleteThought(id: id)
            await MainActor.run {
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to delete thought: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    func resolveThought(_ thought: Thought, outcomeId: UUID) async {
        let updatedThought = thought.resolve(with: outcomeId)
        await updateThought(updatedThought)
    }
}