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
    @State private var navigateBack = false
    @State private var showingCancelConfirmation = false
    @FocusState private var isTextFieldFocused: Bool
    
    // View state
    @State private var currentStep = 0
    @State private var showingReview = false
    
    // Computed properties for the wizard
    private var totalSteps: Int { 2 + OutcomeType.allCases.count } // Thought + outcomes + deadline
    private var progress: CGFloat { CGFloat(currentStep) / CGFloat(totalSteps) }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .topLeading) {
                // Background color based on current step
                Rectangle()
                    .fill(currentStep <= OutcomeType.allCases.count && currentStep > 0 ? 
                          OutcomeType.allCases[currentStep - 1].color.opacity(0.05) : 
                          Color.blue.opacity(0.03))
                    .ignoresSafeArea()
                
                // Cancel button
                Button {
                    // If there's content, show confirmation dialog
                    if !viewModel.newThoughtText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                       !viewModel.outcomeDescriptions.isEmpty {
                        isTextFieldFocused = false // Dismiss keyboard
                        showingCancelConfirmation = true
                    } else {
                        // If no content, just reset and return to previous tab
                        isTextFieldFocused = false // Dismiss keyboard
                        viewModel.resetForm()
                        dismiss() // Always dismiss the sheet
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                        Text("Cancel")
                    }
                    .foregroundColor(.blue)
                    .padding(12)
                    .background(Color(.systemBackground).opacity(0.8))
                    .cornerRadius(20)
                }
                .padding(.top, 16)
                .padding(.leading, 16)
                
                VStack(spacing: 0) {
                    // Title
                    Text(showingReview ? "Review" : (viewModel.isEditing ? "Edit Thought" : "New Thought"))
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.top, 16)
                        .padding(.bottom, 12)
                    
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
                .padding(.top, 24) // Additional padding to account for the cancel button
            }
            .navigationBarHidden(true)
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .onTapGesture { isTextFieldFocused = false } // Dismiss keyboard when tapping outside text field
            .confirmationDialog(
                "Discard changes?",
                isPresented: $showingCancelConfirmation,
                titleVisibility: .visible
            ) {
                Button("Discard changes", role: .destructive) {
                    isTextFieldFocused = false // Dismiss keyboard
                    viewModel.resetForm()
                    dismiss() // Always dismiss the sheet
                }
                Button("Continue editing", role: .cancel) {}
            } message: {
                Text("You have unsaved changes. Are you sure you want to cancel?")
            }
        }
        .animation(.easeInOut, value: currentStep)
        .animation(.easeInOut, value: showingReview)
    }
    
    // MARK: - Step Content
    
    @ViewBuilder
    private var stepContent: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Progress indicator
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.systemGray5))
                    .frame(height: 12)
                
                RoundedRectangle(cornerRadius: 10)
                    .fill(currentStep <= OutcomeType.allCases.count && currentStep > 0 
                          ? OutcomeType.allCases[currentStep - 1].color 
                          : .blue)
                    .frame(width: UIScreen.main.bounds.width * 0.85 * progress, height: 12)
            }
            .padding(.bottom, 16)
            
            if currentStep == 0 {
                // Step 1: Thought input
                thoughtInputStep
                    .transition(.opacity.combined(with: .slide))
            } else if currentStep <= OutcomeType.allCases.count {
                // Steps 2-7: Outcome inputs
                outcomeInputStep(for: OutcomeType.allCases[currentStep - 1])
                    .transition(.opacity.combined(with: .slide))
            } else {
                // Step 8: Deadline selection
                deadlineSelectionStep
                    .transition(.opacity.combined(with: .slide))
            }
        }
    }
    
    // Step 1: Thought input view
    private var thoughtInputStep: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("What's on your mind?")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 8)
            
            Text("Enter the thought or concern that's causing you to feel overwhelmed or anxious.")
                .font(.body)
                .foregroundColor(.secondary)
                .padding(.bottom, 8)
            
            TextField("Example: Will my project be successful?", text: $viewModel.newThoughtText, axis: .vertical)
                .font(.body)
                .padding(16)
                .focused($isTextFieldFocused)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.secondarySystemBackground))
                        .shadow(color: Color.blue.opacity(0.2), radius: 4, x: 0, y: 2)
                )
                .frame(height: 150, alignment: .top)
                .multilineTextAlignment(.leading)
                .animation(.easeInOut, value: viewModel.newThoughtText)
        }
    }
    
    // Steps 2-7: Outcome input views
    private func outcomeInputStep(for outcomeType: OutcomeType) -> some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("\(outcomeType.displayName) Outcome")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(outcomeType.color)
            
            Text("Describe what a \(outcomeType.displayName.lowercased()) outcome would look like for this thought.")
                .font(.body)
                .foregroundColor(.secondary)
                .padding(.bottom, 8)
            
            // Ensure the dictionary has a value for this key
            let binding = Binding(
                get: { viewModel.outcomeDescriptions[outcomeType] ?? "" },
                set: { viewModel.outcomeDescriptions[outcomeType] = $0 }
            )
            
            TextField("I would..." , text: binding, axis: .vertical)
                .font(.body)
                .padding(16)
                .focused($isTextFieldFocused)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(outcomeType.color.opacity(0.15))
                        .shadow(color: outcomeType.color.opacity(0.2), radius: 4, x: 0, y: 2)
                )
                .frame(height: 150, alignment: .top)
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
        VStack(alignment: .leading, spacing: 24) {
            Text("When will you know?")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 8)
            
            Text("Set a deadline for when you expect to know the actual outcome.")
                .font(.body)
                .foregroundColor(.secondary)
                .padding(.bottom, 8)
            
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
                    .shadow(color: Color.blue.opacity(0.2), radius: 4, x: 0, y: 2)
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
        HStack(spacing: 20) {
            Spacer()
            
            // Back button
            if currentStep > 0 {
                Button(action: {
                    currentStep -= 1
                }) {
                    HStack {
                        Image(systemName: "arrow.left")
                        Text("Back")
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 24)
                    .foregroundColor(currentStep <= OutcomeType.allCases.count && currentStep > 0 ? 
                                    OutcomeType.allCases[currentStep - 1].color : .blue)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(currentStep <= OutcomeType.allCases.count && currentStep > 0 ? 
                                   OutcomeType.allCases[currentStep - 1].color : .blue, lineWidth: 1.5)
                    )
                }
            }
            
            // Next/Continue button
            Button(action: {
                if currentStep < totalSteps - 1 {
                    currentStep += 1
                } else {
                    showingReview = true
                }
            }) {
                HStack {
                    if currentStep == totalSteps - 1 {
                        Text("Review")
                            .fontWeight(.medium)
                    } else if currentStep > 0 && currentStep <= OutcomeType.allCases.count {
                        // We're on an outcome page (steps 1-6)
                        let outcomeType = OutcomeType.allCases[currentStep - 1]
                        let outcomeText = viewModel.outcomeDescriptions[outcomeType] ?? ""
                        
                        // Show "Skip" if the text field is empty
                        Text(outcomeText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Skip" : "Next")
                            .fontWeight(.medium)
                    } else {
                        Text("Next")
                            .fontWeight(.medium)
                    }
                    Image(systemName: "arrow.right")
                }
            }
            .disabled(currentStep == 0 && viewModel.newThoughtText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .padding(.vertical, 16)
            .padding(.horizontal, 24)
            .foregroundColor(.white)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(currentStep == 0 && viewModel.newThoughtText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?
                         Color.gray : 
                         (currentStep <= OutcomeType.allCases.count && currentStep > 0 ? 
                          OutcomeType.allCases[currentStep - 1].color : .blue))
            )
            
            Spacer()
        }
    }
    
    private var reviewButtons: some View {
        VStack(spacing: 16) {
            Button(action: {
                showingReview = false
                currentStep = totalSteps - 1
            }) {
                Text("Edit")
                    .fontWeight(.medium)
                    .padding(.vertical, 16)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.blue)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.blue, lineWidth: 1.5)
                    )
            }
            
            Button(action: {
                isTextFieldFocused = false // Dismiss keyboard
                viewModel.createNewThought()
                // Dismiss the sheet after saving in all cases
                dismiss()
            }) {
                Text(viewModel.isEditing ? "Update" : "Save")
                    .fontWeight(.medium)
                    .padding(.vertical, 16)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(viewModel.selectedExpectedOutcome != nil ? Color.blue : Color.gray)
                            .shadow(color: Color.blue.opacity(0.2), radius: 4, x: 0, y: 2)
                    )
            }
            .disabled(viewModel.selectedExpectedOutcome == nil)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
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