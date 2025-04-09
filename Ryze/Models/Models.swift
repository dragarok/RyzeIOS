//
//  Models.swift
//  Ryze
//
//  Created for Ryze app on 09/04/2025.
//

import SwiftUI
import SwiftData

// MARK: - Outcome Type Enum
enum OutcomeType: String, Codable, CaseIterable, Identifiable {
    case worst
    case worse
    case okay
    case good
    case better
    case best
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .worst: return "Worst"
        case .worse: return "Worse"
        case .okay: return "Okay"
        case .good: return "Good"
        case .better: return "Better"
        case .best: return "Best"
        }
    }
    
    var color: Color {
        switch self {
        case .worst: return .red
        case .worse: return .orange
        case .okay: return .yellow
        case .good: return .green
        case .better: return .blue
        case .best: return .purple
        }
    }
}

// MARK: - Outcome Model
@Model
final class Outcome {
    var id: UUID
    var typeRawValue: String
    var outcomeDescription: String  // Changed from 'description' to 'outcomeDescription'
    var thought: Thought?
    
    var type: OutcomeType {
        get { OutcomeType(rawValue: typeRawValue) ?? .okay }
        set { typeRawValue = newValue.rawValue }
    }
    
    init(type: OutcomeType, description: String) {
        self.id = UUID()
        self.typeRawValue = type.rawValue
        self.outcomeDescription = description
    }
}

// MARK: - Thought Model
@Model
final class Thought {
    var id: UUID
    var question: String
    var createdAt: Date
    @Relationship var outcomes: [Outcome]?
    var expectedOutcomeTypeRawValue: String?
    var deadline: Date?
    var actualOutcomeTypeRawValue: String?
    var isResolved: Bool
    
    var expectedOutcomeType: OutcomeType? {
        get { 
            guard let raw = expectedOutcomeTypeRawValue else { return nil }
            return OutcomeType(rawValue: raw)
        }
        set { expectedOutcomeTypeRawValue = newValue?.rawValue }
    }
    
    var actualOutcomeType: OutcomeType? {
        get { 
            guard let raw = actualOutcomeTypeRawValue else { return nil }
            return OutcomeType(rawValue: raw)
        }
        set { actualOutcomeTypeRawValue = newValue?.rawValue }
    }
    
    init(question: String) {
        self.id = UUID()
        self.question = question
        self.createdAt = Date()
        self.isResolved = false
        self.outcomes = []
    }
}