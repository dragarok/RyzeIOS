//
//  NewThoughtView.swift
//  Ryze
//
//  Created for Ryze app on 09/04/2025.
//

import SwiftUI

struct NewThoughtView: View {
    @ObservedObject var viewModel: ThoughtViewModel
    @Environment(\.dismiss) private var dismiss
    
    // View state
    @State private var currentStep = 0
    @State private var showingReview = false
    
    // Computed properties for the wizard
    private var totalSteps: Int { 2 + OutcomeType.allCases.count } // Thought + outcomes + deadline
    private var progress: CGFloat { CGFloat(currentStep) / CGFloat(totalSteps) }
    
    var body: some View {
        NavigationStack {
            VStack {
                // Content based on current step
                if !showingReview {
                    stepContent
                        .transition(.opacity.combined(with: .move(edge: .trailing)))
                } else {
                    reviewContent
                        .transition(.opacity.combined(with: .move(edge: .trailing)))
                }
                
                Spacer()
                
                // Navigation buttons
                if !showingReview {
                    navigationButtons
                } else {
                    reviewButtons
                }
            }
            .padding()
            .navigationTitle(showingReview ? "Review" : "New Thought")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .animation(.easeInOut, value: currentStep)
            .animation(.easeInOut, value: showingReview)
        }
    }
    
    // MARK: - Step Content
    
    @ViewBuilder
    private var stepContent: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Progress indicator
            ProgressView(value: progress)
                .tint(.blue)
                .padding(.bottom)
            
            if currentStep == 0 {
                // Step 1: Thought input
                thoughtInputStep
            } else if currentStep <= OutcomeType.allCases.count {
                // Steps 2-7: Outcome inputs
                outcomeInputStep(for: OutcomeType.allCases[currentStep - 1])
            } else {
                // Step 8: Deadline selection
                deadlineSelectionStep
            }
        }
    }
    
    // Step 1: Thought input view
    private var thoughtInputStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("What's on your mind?")
                .font(.title2)
                .fontWeight(.medium)
            
            Text("Enter the thought or concern that's causing you to feel overwhelmed or anxious.")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            TextField("Example: Will my project be successful?", text: $viewModel.newThoughtText, axis: .vertical)
                .font(.body)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.secondarySystemBackground))
                )
                .frame(height: 120, alignment: .top)
                .multilineTextAlignment(.leading)
        }
    }
    
    // Steps 2-7: Outcome input views
    private func outcomeInputStep(for outcomeType: OutcomeType) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("\(outcomeType.displayName) Outcome")
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(outcomeType.color)
            
            Text("Describe what a \(outcomeType.displayName.lowercased()) outcome would look like for this thought.")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // Ensure the dictionary has a value for this key
            let binding = Binding(
                get: { viewModel.outcomeDescriptions[outcomeType] ?? "" },
                set: { viewModel.outcomeDescriptions[outcomeType] = $0 }
            )
            
            TextField("I would..." , text: binding, axis: .vertical)
                .font(.body)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(outcomeType.color.opacity(0.1))
                )
                .frame(height: 120, alignment: .top)
                .multilineTextAlignment(.leading)
            
            HStack {
                Text("You can skip this outcome if it doesn't apply")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
        }
    }
    
    // Step 8: Deadline selection
    private var deadlineSelectionStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("When will you know?")
                .font(.title2)
                .fontWeight(.medium)
            
            Text("Set a deadline for when you expect to know the actual outcome.")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            DatePicker(
                "Deadline",
                selection: $viewModel.selectedDeadline,
                in: Date()...,
                displayedComponents: [.date, .hourAndMinute]
            )
            .datePickerStyle(.graphical)
            .tint(.blue)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.secondarySystemBackground))
            )
        }
    }
    
    // MARK: - Review Step
    
    private var reviewContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Thought review
                VStack(alignment: .leading, spacing: 8) {
                    Text("Your Thought")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text(viewModel.newThoughtText)
                        .font(.body)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.secondarySystemBackground))
                )
                
                // Outcomes review
                VStack(alignment: .leading, spacing: 16) {
                    Text("Possible Outcomes")
                        .font(.headline)
                    
                    ForEach(OutcomeType.allCases) { type in
                        if let description = viewModel.outcomeDescriptions[type], !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(type.displayName)
                                    .font(.subheadline)
                                    .foregroundColor(type.color)
                                
                                Text(description)
                                    .font(.body)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(type.color.opacity(0.1))
                            )
                        }
                    }
                }
                
                // Expected outcome selection
                VStack(alignment: .leading, spacing: 12) {
                    Text("Your Expectation")
                        .font(.headline)
                    
                    Text("Which outcome do you think is most likely?")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    ForEach(OutcomeType.allCases) { type in
                        if let description = viewModel.outcomeDescriptions[type], !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            Button(action: {
                                viewModel.selectedExpectedOutcome = type
                            }) {
                                HStack {
                                    Text(type.displayName)
                                        .font(.headline)
                                        .foregroundColor(type.color)
                                    
                                    Spacer()
                                    
                                    if viewModel.selectedExpectedOutcome == type {
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
                                        .fill(viewModel.selectedExpectedOutcome == type ? 
                                             type.color.opacity(0.2) : Color(.secondarySystemBackground))
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                
                // Deadline review
                VStack(alignment: .leading, spacing: 8) {
                    Text("Deadline")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Image(systemName: "calendar")
                        Text(dateFormatter.string(from: viewModel.selectedDeadline))
                            .font(.body)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.secondarySystemBackground))
                )
            }
        }
    }
    
    // MARK: - Navigation Controls
    
    private var navigationButtons: some View {
        HStack {
            // Back button
            if currentStep > 0 {
                Button(action: {
                    currentStep -= 1
                }) {
                    HStack {
                        Image(systemName: "arrow.left")
                        Text("Back")
                    }
                    .padding()
                    .foregroundColor(.blue)
                }
            } else {
                Spacer()
            }
            
            Spacer()
            
            // Next/Continue button
            Button(action: {
                if currentStep < totalSteps - 1 {
                    currentStep += 1
                } else {
                    showingReview = true
                }
            }) {
                if currentStep == totalSteps - 1 {
                    Text("Review")
                } else {
                    Text("Next")
                }
            }
            .disabled(currentStep == 0 && viewModel.newThoughtText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .padding()
            .foregroundColor(.white)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(currentStep == 0 && viewModel.newThoughtText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray : Color.blue)
            )
        }
    }
    
    private var reviewButtons: some View {
        VStack {
            Button(action: {
                showingReview = false
                currentStep = totalSteps - 1
            }) {
                Text("Edit")
                    .padding()
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.blue, lineWidth: 1)
                    )
            }
            
            Button(action: {
                viewModel.createNewThought()
                dismiss()
            }) {
                Text("Save")
                    .padding()
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(viewModel.selectedExpectedOutcome != nil ? Color.blue : Color.gray)
                    )
            }
            .disabled(viewModel.selectedExpectedOutcome == nil)
        }
    }
    
    // MARK: - Helpers
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
}

#Preview {
    NewThoughtView(viewModel: ThoughtViewModel(dataStore: DataStore()))
}