//
//  ThoughtDetailView.swift
//  Ryze
//
//  Created for Ryze app on 09/04/2025.
//

import SwiftUI

struct ThoughtDetailView: View {
    let thought: Thought
    @ObservedObject var viewModel: ThoughtViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedOutcomeType: OutcomeType?
    @State private var showingResolveSheet = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Thought question
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your Thought")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text(thought.question)
                            .font(.title3)
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.secondarySystemBackground))
                    )
                    
                    // Expected outcome
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your Expectation")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        if let expectedType = thought.expectedOutcomeType {
                            Text(expectedType.displayName)
                                .font(.headline)
                                .foregroundColor(expectedType.color)
                        } else {
                            Text("No expectation specified")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.secondarySystemBackground))
                    )
                    
                    // Deadline
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Deadline")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        if let deadline = thought.deadline {
                            HStack {
                                Image(systemName: "calendar")
                                Text(fullDateFormatter.string(from: deadline))
                                    .font(.headline)
                            }
                        } else {
                            Text("No deadline specified")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.secondarySystemBackground))
                    )
                    
                    // Outcome spectrum section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Outcome Spectrum")
                            .font(.headline)
                        
                        ForEach(sortedOutcomes) { outcome in
                            outcomeRow(outcome)
                        }
                    }
                    
                    // Actual outcome (if resolved)
                    if thought.isResolved, let actualType = thought.actualOutcomeType {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Actual Outcome")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text(actualType.displayName)
                                .font(.title2)
                                .foregroundColor(actualType.color)
                                .fontWeight(.bold)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.secondarySystemBackground))
                        )
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Thought Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if !thought.isResolved {
                        Button("Resolve") {
                            showingResolveSheet = true
                        }
                        .foregroundColor(.blue)
                    }
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingResolveSheet) {
                resolveView
            }
        }
    }
    
    private var resolveView: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("What actually happened?")
                    .font(.headline)
                    .padding(.top)
                
                ForEach(OutcomeType.allCases) { type in
                    Button(action: {
                        selectedOutcomeType = type
                    }) {
                        HStack {
                            Text(type.displayName)
                                .font(.headline)
                                .foregroundColor(type.color)
                            
                            Spacer()
                            
                            if selectedOutcomeType == type {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(type.color)
                            } else {
                                Circle()
                                    .strokeBorder(Color.secondary.opacity(0.5), lineWidth: 1)
                                    .frame(width: 24, height: 24)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.secondarySystemBackground))
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                Spacer()
                
                Button(action: {
                    if let selectedType = selectedOutcomeType {
                        viewModel.resolveThought(thought, with: selectedType)
                        dismiss()
                    }
                }) {
                    Text("Save")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedOutcomeType != nil ? Color.blue : Color.gray)
                        )
                }
                .disabled(selectedOutcomeType == nil)
                .padding(.bottom)
            }
            .padding()
            .navigationTitle("Resolve Thought")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        showingResolveSheet = false
                    }
                }
            }
        }
    }
    
    private func outcomeRow(_ outcome: Outcome) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(outcome.type.displayName)
                    .font(.headline)
                    .foregroundColor(outcome.type.color)
                
                if thought.expectedOutcomeType == outcome.type {
                    Text("(Expected)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if thought.actualOutcomeType == outcome.type && thought.isResolved {
                    Text("(Actual)")
                        .font(.caption)
                        .foregroundColor(.primary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(outcome.type.color.opacity(0.2))
                        )
                }
            }
            
            Text(outcome.outcomeDescription)
                .font(.body)
                .padding(.vertical, 4)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(outcome.type.color.opacity(0.1))
        )
    }
    
    private var sortedOutcomes: [Outcome] {
        let outcomes = thought.outcomes ?? []
        return outcomes.sorted { lhs, rhs in
            let lhsIndex = OutcomeType.allCases.firstIndex(where: { $0.rawValue == lhs.typeRawValue }) ?? 0
            let rhsIndex = OutcomeType.allCases.firstIndex(where: { $0.rawValue == rhs.typeRawValue }) ?? 0
            return lhsIndex < rhsIndex
        }
    }
    
    private var fullDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
}

#Preview {
    let dataStore = DataStore()
    let thought = Thought(question: "Will my presentation go well?")
    thought.expectedOutcomeType = .worse
    thought.deadline = Date().addingTimeInterval(86400)
    
    let worst = Outcome(type: .worst, description: "I'll freeze up and get fired")
    let worse = Outcome(type: .worse, description: "I'll stumble through it and look incompetent")
    let okay = Outcome(type: .okay, description: "I'll get through it but won't impress anyone")
    let good = Outcome(type: .good, description: "I'll do well and receive positive feedback")
    
    thought.outcomes = [worst, worse, okay, good]
    
    return ThoughtDetailView(
        thought: thought,
        viewModel: ThoughtViewModel(dataStore: dataStore)
    )
}