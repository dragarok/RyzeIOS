//
//  FullScreenNotificationView.swift
//  Ryze
//
//  Created for Ryze app on 10/04/2025.
//

import SwiftUI

struct FullScreenNotificationView: View {
    // The thought that has reached its deadline
    let thought: Thought

    // Environment objects and state variables
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var viewModel: ThoughtViewModel
    @State private var showDetails = true // Changed to true - expanded view by default
    @State private var selectedOutcome: OutcomeType? = nil
    @State private var showConfirmation = false
    @State private var showRescheduleSheet = false
    @State private var rescheduleDate = Date()

    // Function to properly dismiss the notification
    private func closeNotification() {
        // Update the NotificationManager state
        NotificationManager.shared.showDeadlineNotification = false
        NotificationManager.shared.currentThought = nil
        dismiss()
    }

    var body: some View {
        ZStack {
            // White background
            Color.white.ignoresSafeArea()

            VStack(spacing: 24) {
                // Title and close button
                HStack {
                    Text("Deadline Reached")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)

                    Spacer()

                    Button {
                        closeNotification()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal)

                // Main content
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Original thought question
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Your thought:")
                                .font(.headline)
                                .foregroundColor(.secondary)

                            Text(thought.question)
                                .font(.title3)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                                .padding()
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(12)
                        }

                        // Expected outcome
                        VStack(alignment: .leading, spacing: 8) {
                            Text("You expected:")
                                .font(.headline)
                                .foregroundColor(.secondary)

                            if let expectedType = thought.expectedOutcomeType {
                                HStack {
                                    Circle()
                                        .fill(expectedType.color)
                                        .frame(width: 14, height: 14)

                                    Text(expectedType.displayName)
                                        .font(.body)
                                        .fontWeight(.semibold)
                                        .foregroundColor(expectedType.color)
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(expectedType.color.opacity(0.1))
                                .cornerRadius(12)
                            }
                        }

                        // Outcomes section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("What actually happened?")
                                .font(.headline)
                                .foregroundColor(.primary)

                            // List of outcomes to select from
                            if let outcomes = thought.outcomes {
                                ForEach(outcomes.sorted(by: { $0.type.rawValue < $1.type.rawValue }), id: \.id) { outcome in
                                    OutcomeSelectionRow(
                                        outcome: outcome,
                                        isSelected: selectedOutcome == outcome.type,
                                        isExpanded: showDetails,
                                        onSelect: {
                                            withAnimation {
                                                if selectedOutcome == outcome.type {
                                                    selectedOutcome = nil
                                                } else {
                                                    selectedOutcome = outcome.type
                                                }
                                            }
                                        }
                                    )
                                }
                            }

                            // Toggle details button
                            Button {
                                withAnimation {
                                    showDetails.toggle()
                                }
                            } label: {
                                HStack {
                                    Text(showDetails ? "Show Less" : "Show More")
                                    Image(systemName: showDetails ? "chevron.up" : "chevron.down")
                                }
                                .font(.subheadline)
                                .foregroundColor(.primary)
                                .padding(.vertical, 8)
                            }
                        }
                    }
                    .padding()
                }

                // Action buttons
                HStack(spacing: 16) {
                    // Reschedule button
                    Button {
                        showRescheduleSheet = true
                    } label: {
                        HStack {
                            Image(systemName: "calendar.badge.clock")
                            Text("Reschedule")
                        }
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                    }

                    // Confirm outcome button
                    Button {
                        if let selectedOutcome = selectedOutcome {
                            withAnimation {
                                showConfirmation = true
                                // Resolve the thought after a short delay
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    viewModel.resolveThought(thought, with: selectedOutcome)
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        closeNotification()
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Image(systemName: "checkmark.circle")
                            Text("Confirm")
                        }
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedOutcome != nil ? (selectedOutcome!.color.opacity(0.2)) : Color(.secondarySystemBackground))
                        .cornerRadius(12)
                    }
                    .disabled(selectedOutcome == nil)
                }
                .padding(.top)
            }
            .padding()

            // Confirmation overlay
            if showConfirmation {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()

                    VStack(spacing: 16) {
                        // Large checkmark
                        Image(systemName: "checkmark.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .foregroundColor(.green)
                            .padding()

                        Text("Reality Recorded!")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)

                        Text("You've successfully recorded what actually happened.")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                    }
                    .padding(40)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(20)
                    .transition(.scale.combined(with: .opacity))
                }
                .transition(.opacity)
            }
        }
        .onAppear {
            // Set the reschedule date to tomorrow by default
            rescheduleDate = Date().addingTimeInterval(86400)
        }
        .sheet(isPresented: $showRescheduleSheet) {
            // Reschedule sheet
            NavigationView {
                ZStack {
                    // Use a white background
                    Color.white
                        .ignoresSafeArea()
                    VStack {
                        DatePicker("New deadline", selection: $rescheduleDate, in: Date()...)
                            .datePickerStyle(.graphical)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(16)
                            .padding()

                        Button {
                            viewModel.updateThoughtDeadline(thought, newDeadline: rescheduleDate)
                            showRescheduleSheet = false
                            closeNotification()
                        } label: {
                            Text("Save New Deadline")
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(12)
                                .padding(.horizontal)
                        }
                    }
                }
                .navigationTitle("Reschedule")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Cancel") {
                            showRescheduleSheet = false
                        }
                        .foregroundColor(.primary)
                    }
                }
            }
        }
    }
}

// Outcome selection row with expandable details
struct OutcomeSelectionRow: View {
    let outcome: Outcome
    let isSelected: Bool
    let isExpanded: Bool
    let onSelect: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header row
            Button {
                onSelect()
            } label: {
                HStack {
                    // Selection indicator
                    Circle()
                        .stroke(outcome.type.color, lineWidth: 2)
                        .background(
                            Circle()
                                .fill(isSelected ? outcome.type.color : Color.clear)
                        )
                        .frame(width: 22, height: 22)

                    // Type label
                    Text(outcome.type.displayName)
                        .font(.headline)
                        .foregroundColor(outcome.type.color)

                    Spacer()

                    // Type indicator
                    Circle()
                        .fill(outcome.type.color)
                        .frame(width: 14, height: 14)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())

            // Expanded details
            if isExpanded {
                Text(outcome.outcomeDescription)
                    .font(.body)
                    .foregroundColor(.primary)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color.white.opacity(0.6))
                    .cornerRadius(8)
                    .padding(.leading, 30) // Indent to align with the circle
            }
        }
        .padding(12)
        .background(outcome.type.color.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? outcome.type.color : Color.clear, lineWidth: 2)
        )
        .animation(.easeInOut, value: isSelected)
        .animation(.easeInOut, value: isExpanded)
    }
}

// MARK: - Previews
struct FullScreenNotificationView_Previews: PreviewProvider {
    static var previews: some View {
        let mockThought = Thought(question: "Will I be able to complete this project on time?")
        mockThought.expectedOutcomeType = .worse
        mockThought.deadline = Date()

        let outcomes = [
            Outcome(type: .worst, description: "I'll completely fail and lose the client"),
            Outcome(type: .worse, description: "I'll deliver late and damage my reputation"),
            Outcome(type: .okay, description: "I'll finish just in time but be stressed"),
            Outcome(type: .good, description: "I'll complete it comfortably on schedule"),
            Outcome(type: .better, description: "I'll finish early and have time to enhance it"),
            Outcome(type: .best, description: "I'll create something exceptional that exceeds expectations")
        ]

        mockThought.outcomes = outcomes

        let viewModel = ThoughtViewModel(dataStore: DataStore())

        return FullScreenNotificationView(thought: mockThought)
            .environmentObject(viewModel)
    }
}
