//
//  Thought.swift
//  Ryze
//
//  Created on 08/04/2025.
//

import Foundation

struct Thought: Identifiable, Codable, Equatable {
    var id: UUID
    var question: String
    var createdAt: Date
    var outcomes: [Outcome]
    var expectedOutcome: UUID? // References an Outcome.id
    var deadline: Date
    var actualOutcome: UUID? // References an Outcome.id
    var isResolved: Bool
    
    init(id: UUID = UUID(), 
         question: String, 
         createdAt: Date = Date(), 
         outcomes: [Outcome] = [], 
         expectedOutcome: UUID? = nil, 
         deadline: Date, 
         actualOutcome: UUID? = nil, 
         isResolved: Bool = false) {
        self.id = id
        self.question = question
        self.createdAt = createdAt
        self.outcomes = outcomes
        self.expectedOutcome = expectedOutcome
        self.deadline = deadline
        self.actualOutcome = actualOutcome
        self.isResolved = isResolved
    }
    
    // Helper methods
    func getExpectedOutcome() -> Outcome? {
        guard let expectedId = expectedOutcome else { return nil }
        return outcomes.first { $0.id == expectedId }
    }
    
    func getActualOutcome() -> Outcome? {
        guard let actualId = actualOutcome else { return nil }
        return outcomes.first { $0.id == actualId }
    }
    
    // Creates a copy with updated properties
    func copyWith(
        id: UUID? = nil,
        question: String? = nil,
        createdAt: Date? = nil,
        outcomes: [Outcome]? = nil,
        expectedOutcome: UUID?? = nil,
        deadline: Date? = nil,
        actualOutcome: UUID?? = nil,
        isResolved: Bool? = nil
    ) -> Thought {
        Thought(
            id: id ?? self.id,
            question: question ?? self.question,
            createdAt: createdAt ?? self.createdAt,
            outcomes: outcomes ?? self.outcomes,
            expectedOutcome: expectedOutcome ?? self.expectedOutcome,
            deadline: deadline ?? self.deadline,
            actualOutcome: actualOutcome ?? self.actualOutcome,
            isResolved: isResolved ?? self.isResolved
        )
    }
    
    // For Equatable
    static func == (lhs: Thought, rhs: Thought) -> Bool {
        lhs.id == rhs.id
    }
}

// Extensions for business logic
extension Thought {
    var isOverdue: Bool {
        !isResolved && Date() > deadline
    }
    
    var daysUntilDeadline: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: deadline)
        return components.day ?? 0
    }
    
    // Mark thought as resolved with the actual outcome
    func resolve(with outcomeId: UUID) -> Thought {
        var updatedThought = self
        updatedThought.actualOutcome = outcomeId
        updatedThought.isResolved = true
        return updatedThought
    }
}