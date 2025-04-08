//
//  Outcome.swift
//  Ryze
//
//  Created on 08/04/2025.
//

import Foundation

// Define the outcome spectrum types
enum OutcomeType: String, Codable, CaseIterable, Identifiable {
    case worst
    case worse
    case okay
    case good
    case better
    case best
    
    var id: String { rawValue }
    
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
    
    var sortOrder: Int {
        switch self {
        case .worst: return 0
        case .worse: return 1
        case .okay: return 2
        case .good: return 3
        case .better: return 4
        case .best: return 5
        }
    }
}

struct Outcome: Identifiable, Codable, Equatable {
    var id: UUID
    var type: OutcomeType
    var description: String
    
    init(id: UUID = UUID(), type: OutcomeType, description: String) {
        self.id = id
        self.type = type
        self.description = description
    }
    
    // For Equatable
    static func == (lhs: Outcome, rhs: Outcome) -> Bool {
        lhs.id == rhs.id
    }
    
    // Creates a copy with updated properties
    func copyWith(
        id: UUID? = nil,
        type: OutcomeType? = nil,
        description: String? = nil
    ) -> Outcome {
        Outcome(
            id: id ?? self.id,
            type: type ?? self.type,
            description: description ?? self.description
        )
    }
}

// Extensions for helping with UI and business logic
extension Outcome {
    // Helper to create empty outcomes for all types
    static func createEmptyOutcomes() -> [Outcome] {
        OutcomeType.allCases.map { type in
            Outcome(type: type, description: "")
        }
    }
    
    // Helper to create default outcome descriptions
    static func createDefaultOutcomes() -> [Outcome] {
        [
            Outcome(type: .worst, description: "The absolute worst that could happen"),
            Outcome(type: .worse, description: "A bad outcome, but not the worst"),
            Outcome(type: .okay, description: "A neutral outcome"),
            Outcome(type: .good, description: "A good outcome"),
            Outcome(type: .better, description: "A very good outcome"),
            Outcome(type: .best, description: "The best possible outcome")
        ]
    }
}