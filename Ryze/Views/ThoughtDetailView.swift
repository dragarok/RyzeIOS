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
    @State private var showingDeleteConfirmation = false
    @State private var showOutcomeAnimation = false
    @State private var showingEditSheet = false // New state for edit sheet
    @Namespace private var animation
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Thought question with subtle animation
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your Thought")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 2)
                        
                        Text(thought.question)
                            .font(.title3)
                            .fontWeight(.medium)
                            .padding(.top, 2)
                            .lineSpacing(4) // More breathing room between lines
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.secondarySystemBackground))
                            .shadow(color: Color.black.opacity(0.03), radius: 3, x: 0, y: 1)
                    )
                    
                    // Expected outcome with warm styling
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your Expectation")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 2)
                        
                        if let expectedType = thought.expectedOutcomeType {
                            HStack(spacing: 12) {
                                Circle()
                                    .fill(expectedType.color)
                                    .frame(width: 8, height: 8)
                                
                                Text(expectedType.displayName)
                                    .font(.headline)
                                    .foregroundColor(expectedType.color)
                            }
                            .padding(.vertical, 4)
                        } else {
                            Text("No expectation specified")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(thought.expectedOutcomeType?.color.opacity(0.1) ?? Color(.secondarySystemBackground))
                            .shadow(color: Color.black.opacity(0.03), radius: 3, x: 0, y: 1)
                    )
                    
                    // Deadline with calming visual
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Deadline")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 2)
                        
                        if let deadline = thought.deadline {
                            HStack(spacing: 10) {
                                Image(systemName: "hourglass")
                                    .symbolEffect(.variableColor.iterative.reversing, isActive: !thought.isResolved)
                                
                                Text(fullDateFormatter.string(from: deadline))
                                    .font(.headline)
                                    .padding(.leading, 2)
                            }
                            .padding(.vertical, 4)
                            
                            // Add time remaining indicator if not resolved
                            if !thought.isResolved {
                                timeRemainingText(deadline: deadline)
                                    .padding(.top, 4)
                            }
                        } else {
                            Text("No deadline specified")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.secondarySystemBackground))
                            .shadow(color: Color.black.opacity(0.03), radius: 3, x: 0, y: 1)
                    )
                    
                    // Outcome spectrum section with visual polish
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Outcome Spectrum")
                            .font(.headline)
                            .padding(.bottom, 4)
                        
                        ForEach(sortedOutcomes) { outcome in
                            outcomeRow(outcome)
                                .transition(.scale(scale: 0.95).combined(with: .opacity))
                        }
                    }
                    
                    // Actual outcome (if resolved) with celebratory styling
                    if thought.isResolved, let actualType = thought.actualOutcomeType {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Actual Outcome")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 2)
                            
                            HStack(spacing: 12) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(actualType.color)
                                    .font(.title3)
                                    .symbolEffect(.bounce, options: .repeating, value: showOutcomeAnimation)
                                
                                Text(actualType.displayName)
                                    .font(.title2)
                                    .foregroundColor(actualType.color)
                                    .fontWeight(.bold)
                            }
                            .onAppear {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    showOutcomeAnimation = true
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(actualType.color.opacity(0.1))
                                .shadow(color: Color.black.opacity(0.03), radius: 3, x: 0, y: 1)
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
                        HStack(spacing: 16) {
                            // Edit button - now using a regular Button instead of NavigationLink
                            Button {
                                // Show the edit sheet
                                showingEditSheet = true
                            } label: {
                                Image(systemName: "pencil")
                                    .foregroundColor(.blue)
                            }
                            
                            // Delete button
                            Button {
                                showingDeleteConfirmation = true
                            } label: {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                            
                            // Resolve button
                            Button {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    showingResolveSheet = true
                                }
                            } label: {
                                Label("Resolve", systemImage: "checkmark.circle")
                                    .foregroundColor(thought.expectedOutcomeType?.color ?? .blue)
                                    .font(.body.weight(.medium))
                            }
                        }
                    }
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            // Add sheet for editing thought
            .sheet(isPresented: $showingEditSheet) {
                NewThoughtView(viewModel: viewModel)
                    .onAppear {
                        // Prepare the form for editing when the view appears
                        viewModel.prepareForEditing(thought)
                    }
                    .onDisappear {
                        // Reset form when navigating away
                        viewModel.resetForm()
                    }
            }
            .sheet(isPresented: $showingResolveSheet) {
                resolveView
            }
            .confirmationDialog("Delete this thought?", isPresented: $showingDeleteConfirmation, titleVisibility: .visible) {
                Button("Delete", role: .destructive) {
                    viewModel.deleteThought(thought)
                    dismiss()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This action cannot be undone.")
            }
        }
    }
    
    private var resolveView: some View {
        NavigationStack {
            VStack(spacing: 30) {
                VStack(spacing: 8) {
                    Text("What actually happened?")
                        .font(.headline)
                        .padding(.top, 4)
                    
                    Text("Reflect on the outcome of your thought")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top)
                .padding(.horizontal)
                
                ForEach(OutcomeType.allCases) { type in
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedOutcomeType = type
                        }
                    }) {
                        HStack(spacing: 12) {
                            // Color indicator
                            Circle()
                                .fill(type.color)
                                .frame(width: 12, height: 12)
                                
                            Text(type.displayName)
                                .font(.headline)
                                .foregroundColor(type.color)
                            
                            Spacer()
                            
                            if selectedOutcomeType == type {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(type.color)
                                    .symbolEffect(.bounce, options: .speed(1.5), value: selectedOutcomeType)
                            } else {
                                Circle()
                                    .strokeBorder(Color.secondary.opacity(0.3), lineWidth: 1.5)
                                    .frame(width: 24, height: 24)
                            }
                        }
                        .padding(.vertical, 14)
                        .padding(.horizontal, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(selectedOutcomeType == type ? 
                                      type.color.opacity(0.1) : 
                                      Color(.secondarySystemBackground))
                                .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                Spacer()
                
                Button(action: {
                    if let selectedType = selectedOutcomeType {
                        // Add haptic feedback for resolution
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.success)
                        
                        withAnimation(Animation.spring(response: 0.4, dampingFraction: 0.7)) {
                            viewModel.resolveThought(thought, with: selectedType)
                            showOutcomeAnimation = true
                        }
                        
                        // Slight delay before dismissing to let animation play
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            dismiss()
                        }
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle")
                        Text("Save Resolution")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(selectedOutcomeType != nil ? 
                                 (selectedOutcomeType?.color ?? .blue) : 
                                 Color.gray)
                            .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
                    )
                }
                .disabled(selectedOutcomeType == nil)
                .padding(.bottom)
                .opacity(selectedOutcomeType == nil ? 0.6 : 1.0)
                .animation(.easeInOut(duration: 0.2), value: selectedOutcomeType)
            }
            .padding()
            .navigationTitle("Resolve Thought")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showingResolveSheet = false
                        }
                    } label: {
                        Text("Cancel")
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
    
    private func outcomeRow(_ outcome: Outcome) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                // Indicator dot
                Circle()
                    .fill(outcome.type.color)
                    .frame(width: 10, height: 10)
                
                Text(outcome.type.displayName)
                    .font(.headline)
                    .foregroundColor(outcome.type.color)
                
                if thought.expectedOutcomeType == outcome.type {
                    Text("(Expected)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(Color.secondary.opacity(0.1))
                        )
                }
                
                if thought.actualOutcomeType == outcome.type && thought.isResolved {
                    Text("(Actual)")
                        .font(.caption)
                        .foregroundColor(.primary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(outcome.type.color.opacity(0.2))
                        )
                        .overlay(
                            Capsule()
                                .strokeBorder(outcome.type.color.opacity(0.3), lineWidth: 1)
                        )
                }
            }
            
            Text(outcome.outcomeDescription)
                .font(.body)
                .lineSpacing(4)
                .padding(.vertical, 4)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(outcome.type.color.opacity(0.1))
                .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
        )
        // Subtle shine effect at the top
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.07),
                            Color.white.opacity(0.0)
                        ]),
                        startPoint: .top,
                        endPoint: .center
                    )
                )
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
    
    // Helper to show time remaining in a zen-like way
    private func timeRemainingText(deadline: Date) -> some View {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day, .hour], from: Date(), to: deadline)
        let days = components.day ?? 0
        let hours = components.hour ?? 0
        
        let timeText: String
        let color: Color
        
        if days < 0 || (days == 0 && hours < 0) {
            timeText = "Past deadline"
            color = OutcomeType.worst.color.opacity(0.8)
        } else if days == 0 && hours == 0 {
            timeText = "Due now"
            color = OutcomeType.worse.color.opacity(0.8)
        } else if days == 0 {
            timeText = "\(hours) hour\(hours == 1 ? "" : "s") remaining"
            color = OutcomeType.okay.color.opacity(0.8)
        } else if days < 3 {
            timeText = "\(days) day\(days == 1 ? "" : "s") remaining"
            color = OutcomeType.good.color.opacity(0.8)
        } else {
            timeText = "\(days) day\(days == 1 ? "" : "s") remaining"
            color = OutcomeType.better.color.opacity(0.8)
        }
        
        return Text(timeText)
            .font(.caption)
            .foregroundColor(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(color.opacity(0.1))
            )
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