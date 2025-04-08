//
//  NewThoughtView.swift
//  Ryze
//
//  Created on 08/04/2025.
//

import SwiftUI

struct NewThoughtView: View {
    @ObservedObject var viewModel: ThoughtViewModel
    @Environment(\.dismiss) private var dismiss
    
    // Form state
    @State private var question: String = ""
    @State private var outcomes: [Outcome] = Outcome.createEmptyOutcomes()
    @State private var expectedOutcomeId: UUID? = nil
    @State private var deadline: Date = Date().addingTimeInterval(7*24*60*60) // One week default
    
    // UI state
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil
    @State private var showingConfirmation: Bool = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Your Thought")) {
                    TextField("What's on your mind?", text: $question, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section(header: Text("Deadline")) {
                    DatePicker(
                        "When will you know the outcome?",
                        selection: $deadline,
                        in: Date()...,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                }
                
                Section(header: Text("Possible Outcomes")) {
                    Text("This section will contain outcome inputs")
                    // Placeholder for outcome inputs
                }
                
                Section(header: Text("Your Prediction")) {
                    Text("This section will contain prediction selection")
                    // Placeholder for prediction selection
                }
                
                if let errorMessage = errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("New Thought")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveThought()
                    }
                    .disabled(isLoading || !isValid)
                }
            }
            .overlay {
                if isLoading {
                    ProgressView("Saving...")
                        .background(.ultraThinMaterial)
                        .cornerRadius(8)
                        .padding()
                }
            }
            .alert("Thought Saved", isPresented: $showingConfirmation) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Your thought has been saved. We'll notify you on \(deadline.formatted(date: .long, time: .shortened)) to record the actual outcome.")
            }
        }
    }
    
    // Validation
    private var isValid: Bool {
        !question.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // Save the thought
    private func saveThought() {
        isLoading = true
        errorMessage = nil
        
        // Create a new thought
        let newThought = Thought(
            question: question,
            outcomes: outcomes.filter { !$0.description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty },
            expectedOutcome: expectedOutcomeId,
            deadline: deadline
        )
        
        // Save it using the view model
        Task {
            do {
                await viewModel.saveThought(newThought)
                await MainActor.run {
                    isLoading = false
                    showingConfirmation = true
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Failed to save: \(error.localizedDescription)"
                }
            }
        }
    }
}

#Preview {
    NewThoughtView(viewModel: ThoughtViewModel(dataStore: DataStore()))
}