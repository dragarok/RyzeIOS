//
//  NewThoughtView.swift
//  Ryze
//
//  Created for Ryze app on 09/04/2025.
//

import SwiftUI
import Combine
import UIKit

// A UIViewRepresentable wrapper for UIDatePicker to ensure interactivity
struct UIKitDatePicker: UIViewRepresentable {
    @Binding var selection: Date
    var minimumDate: Date
    
    func makeUIView(context: Context) -> UIDatePicker {
        let picker = UIDatePicker()
        picker.datePickerMode = .dateAndTime
        picker.preferredDatePickerStyle = .inline
        picker.minimumDate = minimumDate
        picker.addTarget(context.coordinator, action: #selector(Coordinator.dateChanged(_:)), for: .valueChanged)
        return picker
    }
    
    func updateUIView(_ uiView: UIDatePicker, context: Context) {
        uiView.date = selection
        uiView.minimumDate = minimumDate
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject {
        let parent: UIKitDatePicker
        
        init(_ parent: UIKitDatePicker) {
            self.parent = parent
        }
        
        @objc func dateChanged(_ sender: UIDatePicker) {
            parent.selection = sender.date
        }
    }
}

struct NewThoughtView: View {
    @ObservedObject var viewModel: ThoughtViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingCancelConfirmation = false
    @FocusState private var focusedField: FocusField?
    
    enum FocusField {
        case thoughtText
        case outcomeText
    }

    // View state
    @State private var currentStep = 0
    @State private var showingReview = false
    
    // Computed properties for the wizard
    private var totalSteps: Int { 2 + OutcomeType.allCases.count } // Thought + outcomes + deadline
    private var progress: CGFloat { CGFloat(currentStep) / CGFloat(totalSteps) }
    
    var body: some View {
        ZStack {
            // Full background color that extends to all edges
            Color(currentStep <= OutcomeType.allCases.count && currentStep > 0 ? 
                  OutcomeType.allCases[currentStep - 1].color.opacity(0.05) : 
                  Color.blue.opacity(0.03))
                .ignoresSafeArea()
            
            // Main view content
            NavigationView {
                VStack(spacing: 0) {
                    // Main content area
                    contentArea
                    
                    // Bottom buttons area with solid background
                    buttonArea
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text(showingReview ? "Review" : (viewModel.isEditing ? "Edit Thought" : "New Thought"))
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            if !viewModel.newThoughtText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                               !viewModel.outcomeDescriptions.isEmpty {
                                showingCancelConfirmation = true
                            } else {
                                viewModel.resetForm()
                                dismiss()
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 14, weight: .bold))
                                Text("Cancel")
                            }
                            .foregroundColor(.blue)
                        }
                    }
                }
                .confirmationDialog(
                    "Discard changes?",
                    isPresented: $showingCancelConfirmation,
                    titleVisibility: .visible
                ) {
                    Button("Discard changes", role: .destructive) {
                        viewModel.resetForm()
                        dismiss()
                    }
                    Button("Continue editing", role: .cancel) {}
                } message: {
                    Text("You have unsaved changes. Are you sure you want to cancel?")
                }
                .onAppear {
                    // Set initial focus for first text field
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        if currentStep == 0 {
                            self.focusedField = .thoughtText
                        } else if currentStep <= OutcomeType.allCases.count {
                            self.focusedField = .outcomeText
                        }
                    }
                }
                .onChange(of: currentStep) { _ in
                    // Set focus for the text field in the current step
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        if currentStep == 0 {
                            self.focusedField = .thoughtText
                        } else if currentStep <= OutcomeType.allCases.count {
                            self.focusedField = .outcomeText
                        } else {
                            // For deadline step, dismiss keyboard
                            self.focusedField = nil
                        }
                    }
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: currentStep)
        .animation(.easeInOut(duration: 0.3), value: showingReview)
    }
    
    // MARK: - Main View Components
    
    // Content area with scrollable content
    private var contentArea: some View {
        ScrollView {
            // Disable tap gesture for the ScrollView to allow date picker interaction
            VStack(spacing: 0) {
                // Content based on current step
                if !showingReview {
                    stepContent
                        .transition(.opacity.combined(with: .move(edge: .trailing)))
                } else {
                    reviewContent
                        .transition(.opacity.combined(with: .move(edge: .trailing)))
                }
            }
            .padding(.horizontal)
            .padding(.top, 12)
        }
        .simultaneousGesture(DragGesture().onChanged { _ in })  // Allow scrolling but don't capture taps
    }
    
    // Button area with fixed positioning
    private var buttonArea: some View {
        VStack(spacing: 0) {
            Divider()
            if !showingReview {
                navigationButtons
            } else {
                reviewButtons
            }
            // Add bottom padding to ensure it's visible above the home indicator
            // Color fill that extends below the safe area
            Rectangle()
                .fill(Color(.systemBackground))
                .frame(height: 0)  // Zero height, but with color that extends
                .edgesIgnoringSafeArea(.bottom)
        }
        .background(Color(.systemBackground))
    }
    
    // MARK: - Step Content
    
    @ViewBuilder
    private var stepContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Progress indicator
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.systemGray5))
                    .frame(height: 8)
                
                RoundedRectangle(cornerRadius: 10)
                    .fill(currentStep <= OutcomeType.allCases.count && currentStep > 0 
                          ? OutcomeType.allCases[currentStep - 1].color 
                          : .blue)
                    .frame(width: UIScreen.main.bounds.width * 0.85 * progress, height: 8)
            }
            .padding(.bottom, 12)
            
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
            
            // Add padding at the bottom for better scrolling
            Spacer(minLength: 100)
        }
    }
    
    // Step 1: Thought input view
    private var thoughtInputStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("What's on your mind?")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Enter the thought or concern that's causing you to feel overwhelmed or anxious.")
                .font(.body)
                .foregroundColor(.secondary)
                .padding(.bottom, 4)
            
            TextField("Example: Will my project be successful?", text: $viewModel.newThoughtText, axis: .vertical)
                .font(.body)
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.secondarySystemBackground))
                )
                .frame(minHeight: 100)
                .focused($focusedField, equals: .thoughtText)
                .multilineTextAlignment(.leading)
                .submitLabel(.next)
        }
    }
    
    // Steps 2-7: Outcome input views
    private func outcomeInputStep(for outcomeType: OutcomeType) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("\(outcomeType.displayName) Outcome")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(outcomeType.color)
            
            Text("Describe what a \(outcomeType.displayName.lowercased()) outcome would look like for this thought.")
                .font(.body)
                .foregroundColor(.secondary)
                .padding(.bottom, 4)
            
            // Ensure the dictionary has a value for this key
            let binding = Binding(
                get: { viewModel.outcomeDescriptions[outcomeType] ?? "" },
                set: { viewModel.outcomeDescriptions[outcomeType] = $0 }
            )
            
            TextField("I would..." , text: binding, axis: .vertical)
                .font(.body)
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(outcomeType.color.opacity(0.15))
                )
                .frame(minHeight: 100)
                .focused($focusedField, equals: .outcomeText)
                .multilineTextAlignment(.leading)
                .submitLabel(.next)
            
            HStack {
                Text("You can skip this outcome if it doesn't apply")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding(.top, 4)
        }
    }
    
    // Step 8: Deadline selection
    private var deadlineSelectionStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("When will you know?")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Set a deadline for when you expect to know the actual outcome.")
                .font(.body)
                .foregroundColor(.secondary)
                .padding(.bottom, 4)
            
            // Use the UIKit-based date picker instead of SwiftUI's DatePicker
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.secondarySystemBackground))
                
                UIKitDatePicker(selection: $viewModel.selectedDeadline, minimumDate: Date())
                    .padding()
            }
            .frame(height: 400)  // Fixed height to ensure it's properly sized
        }
    }
    
    // MARK: - Review Step
    
    private var reviewContent: some View {
        VStack(alignment: .leading, spacing: 20) {
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
            
            // Add space at bottom to ensure buttons don't overlap content
            Spacer(minLength: 100)
        }
    }
    
    // MARK: - Navigation Controls
    
    private var navigationButtons: some View {
        HStack(spacing: 20) {
            // Back button
            if currentStep > 0 {
                Button(action: {
                    currentStep -= 1
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.left")
                        Text("Back")
                    }
                    .padding(.vertical, 14)
                    .padding(.horizontal, 24)
                    .foregroundColor(currentStep <= OutcomeType.allCases.count && currentStep > 0 ? 
                                    OutcomeType.allCases[currentStep - 1].color : .blue)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(currentStep <= OutcomeType.allCases.count && currentStep > 0 ? 
                                   OutcomeType.allCases[currentStep - 1].color : .blue, lineWidth: 1.5)
                    )
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
                HStack(spacing: 8) {
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
            .padding(.vertical, 14)
            .padding(.horizontal, 24)
            .foregroundColor(.white)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(currentStep == 0 && viewModel.newThoughtText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?
                         Color.gray : 
                         (currentStep <= OutcomeType.allCases.count && currentStep > 0 ? 
                          OutcomeType.allCases[currentStep - 1].color : .blue))
            )
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    private var reviewButtons: some View {
        VStack(spacing: 16) {
            Button(action: {
                showingReview = false
                currentStep = totalSteps - 1
            }) {
                Text("Edit")
                    .fontWeight(.medium)
                    .padding(.vertical, 14)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.blue)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.blue, lineWidth: 1.5)
                    )
            }
            
            Button(action: {
                viewModel.createNewThought()
                // Dismiss the sheet after saving in all cases
                dismiss()
            }) {
                Text(viewModel.isEditing ? "Update" : "Save")
                    .fontWeight(.medium)
                    .padding(.vertical, 14)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(viewModel.selectedExpectedOutcome != nil ? Color.blue : Color.gray))
            }
            .disabled(viewModel.selectedExpectedOutcome == nil)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
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