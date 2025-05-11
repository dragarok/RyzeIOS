//
//  ExampleContentView.swift
//  Ryze
//
//  Created for Ryze app on 11/05/2025.
//

import SwiftUI

/// Presentation mode for the ExampleContentView
enum ExamplePresentationType {
    case onboarding
    case settings
}

/// A shared component that displays the example content for both onboarding and settings
struct ExampleContentView: View {
    // MARK: - Properties
    
    /// The type of presentation (onboarding or settings) which affects styling and buttons
    let presentationType: ExamplePresentationType
    
    /// Closure to call when the user completes the example
    let onComplete: () -> Void
    
    /// Optional closure to call when the user chooses to skip or hide onboarding
    let onSkip: (() -> Void)?
    
    /// Title to display in the navigation bar
    var navigationTitle: String {
        switch presentationType {
        case .onboarding:
            return "Example Thought"
        case .settings:
            return "How Ryze Works"
        }
    }
    
    /// Text to display on the complete button
    var completeButtonText: String {
        switch presentationType {
        case .onboarding:
            return "Start My Journey"
        case .settings:
            return "Got It"
        }
    }
    
    /// Text to display in the conclusion section
    var conclusionText: String {
        switch presentationType {
        case .onboarding:
            return "Now you understand how Ryze works. Start by recording your first thought and begin building your personal database of expectations vs. reality."
        case .settings:
            return "Use the 'New Thought' tab to start tracking your thoughts and compare expectations with reality."
        }
    }
    
    /// Text to display as the conclusion title
    var conclusionTitle: String {
        switch presentationType {
        case .onboarding:
            return "You're Ready!"
        case .settings:
            return "Ready to create your own?"
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Introduction text
                Text(presentationType == .onboarding ? 
                     "Let's walk through an example together" : 
                     "This example will guide you through how Ryze works:")
                    .font(.headline)
                    .padding(.horizontal)
                
                // Example scenario
                VStack(alignment: .leading, spacing: 12) {
                    Text("Example Scenario:")
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    Text("You have an important presentation at work next week, and you're worried about how it will go.")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.blue.opacity(0.1))
                )
                .padding(.horizontal)
                
                // Step 1: Record thought
                OnboardingComponentViews.exampleStep(
                    number: 1,
                    title: "Record your thought",
                    description: "Start by writing down what's on your mind.",
                    content: {
                        Text("Will my presentation go well or will I embarrass myself?")
                            .italic()
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(8)
                    }
                )
                
                // Step 2: Define outcomes
                OnboardingComponentViews.exampleStep(
                    number: 2,
                    title: "Define outcome spectrum",
                    description: "Create a range of possible outcomes from worst to best.",
                    content: {
                        VStack(alignment: .leading, spacing: 8) {
                            // Outcome rows
                            OnboardingComponentViews.outcomeRow(type: .worst, description: "I completely freeze up and get fired")
                            OnboardingComponentViews.outcomeRow(type: .worse, description: "I stumble through it and face criticism")
                            OnboardingComponentViews.outcomeRow(type: .okay, description: "I get through it but don't impress anyone")
                            OnboardingComponentViews.outcomeRow(type: .good, description: "It goes fairly well with some positive feedback")
                            OnboardingComponentViews.outcomeRow(type: .better, description: "It goes very well and I receive praise")
                            OnboardingComponentViews.outcomeRow(type: .best, description: "It's phenomenal and leads to a promotion")
                            
                            // Note about outcome flexibility
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "info.circle.fill")
                                    .foregroundColor(.blue)
                                
                                Text("You don't need to define all possible outcomes - focus on the ones most meaningful to you. You can add as few or as many as needed.")
                                    .font(.callout)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.top, 12)
                        }
                    }
                )
                
                // Step 3: Select expected outcome
                OnboardingComponentViews.exampleStep(
                    number: 3,
                    title: "Select expected outcome",
                    description: "Choose the outcome you currently think is most likely.",
                    content: {
                        OnboardingComponentViews.outcomeRow(type: .worse, description: "I stumble through it and face criticism", isSelected: true)
                    }
                )
                
                // Step 4: Set deadline
                OnboardingComponentViews.exampleStep(
                    number: 4,
                    title: "Set deadline",
                    description: "Choose when you'll know the actual outcome.",
                    content: {
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(.blue)
                            
                            Text("Next Friday, 3:00 PM")
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(8)
                        }
                    }
                )
                
                // Step 5: Compare with reality
                OnboardingComponentViews.exampleStep(
                    number: 5,
                    title: "Compare with reality",
                    description: "After the deadline, record what actually happened.",
                    content: {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("When the deadline arrives, you'll receive a notification to record the actual outcome.")
                                .font(.callout)
                                .foregroundColor(.secondary)
                            
                            OnboardingComponentViews.outcomeRow(type: .good, description: "It goes fairly well with some positive feedback", isSelected: true, isActual: true)
                        }
                    }
                )
                
                // Step 6: Learn from patterns
                OnboardingComponentViews.exampleStep(
                    number: 6,
                    title: "Learn from patterns",
                    description: "Over time, you'll build a database of predictions vs. reality.",
                    content: {
                        Text("Your dashboard will show you patterns in your thinking and help you recognize when your fears don't match reality.")
                            .font(.callout)
                            .foregroundColor(.secondary)
                    }
                )
                
                // Conclusion
                VStack(spacing: 16) {
                    Text(conclusionTitle)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(conclusionText)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity)
                
                // Complete button (only for onboarding)
                if presentationType == .onboarding {
                    // Add note about example being available in settings
                    Text("You can always revisit this example later in the Settings > About section.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .padding(.bottom, 10)
                        .frame(maxWidth: .infinity)
                    
                    Button(action: onComplete) {
                        Text(completeButtonText)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .frame(minWidth: 200, minHeight: 50)
                            .background(
                                Capsule()
                                    .fill(Color.blue)
                                    .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
                            )
                    }
                    .padding(.bottom, 30)
                    .frame(maxWidth: .infinity)
                }
                
                Spacer(minLength: 40)
            }
            .padding(.vertical)
        }
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ExampleContentView(
            presentationType: .settings,
            onComplete: {},
            onSkip: nil
        )
    }
}