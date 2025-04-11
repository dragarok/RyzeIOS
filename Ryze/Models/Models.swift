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
        case .worst: return Color(red: 0.85, green: 0.22, blue: 0.22)    // Soft red
        case .worse: return Color(red: 0.90, green: 0.45, blue: 0.27)    // Warm orange
        case .okay: return Color(red: 0.85, green: 0.68, blue: 0.20)     // Muted gold
        case .good: return Color(red: 0.45, green: 0.70, blue: 0.45)     // Sage green
        case .better: return Color(red: 0.35, green: 0.60, blue: 0.75)   // Ocean blue
        case .best: return Color(red: 0.55, green: 0.40, blue: 0.70)     // Lavender purple
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