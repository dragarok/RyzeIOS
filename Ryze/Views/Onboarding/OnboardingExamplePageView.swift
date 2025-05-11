//
//  OnboardingExamplePageView.swift
//  Ryze
//
//  Created for Ryze app on 13/04/2025.
//

import SwiftUI

struct OnboardingExamplePageView {
    // Animation states
    @Binding var animateIcon: Bool
    @Binding var animateText: Bool

    // MARK: - Onboarding Pages

    // Example Page
    var examplePage: some View {
        ScrollView {
            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.1))
                        .frame(width: 160, height: 160)

                    Image(systemName: "lightbulb")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                        .symbolEffect(.variableColor.iterative, options: .repeating, value: animateIcon)
                }
                .padding(.top)

                VStack(spacing: 16) {
                    Text("Let's Try It")
                        .font(.system(size: 34, weight: .bold))
                        .multilineTextAlignment(.center)

                    Text("Ready to see how it works?")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 24)
                }

                Text("Tap the button below to explore an example that will walk you through the process of creating your first thought.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 32)

//                VStack(spacing: 12) {
//                    Text("Benefits of practicing with Ryze:")
//                        .font(.headline)
//                        .padding(.bottom, 8)
//                        .frame(maxWidth: .infinity, alignment: .center)
//
//                    VStack(spacing: 14) {
//                        OnboardingComponentViews.benefitPoint("Reduced anxiety around uncertainty")
//                        OnboardingComponentViews.benefitPoint("Evidence-based recalibration of fears")
//                        OnboardingComponentViews.benefitPoint("Greater emotional resilience")
//                        OnboardingComponentViews.benefitPoint("Improved decision making")
//                    }
//                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .padding(.bottom, 30)
            }
            .padding()
        }
    }

    // Example thought view
    func exampleThoughtView(showExampleThought: Binding<Bool>, showOnboarding: Binding<Bool>) -> some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("Let's walk through an example together")
                        .font(.headline)
                        .padding(.horizontal)

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

                    OnboardingComponentViews.exampleStep(
                        number: 2,
                        title: "Define outcome spectrum",
                        description: "Create a range of possible outcomes from worst to best.",
                        content: {
                            VStack(alignment: .leading, spacing: 8) {
                                OnboardingComponentViews.outcomeRow(type: .worst, description: "I completely freeze up and get fired")
                                OnboardingComponentViews.outcomeRow(type: .worse, description: "I stumble through it and face criticism")
                                OnboardingComponentViews.outcomeRow(type: .okay, description: "I get through it but don't impress anyone")
                                OnboardingComponentViews.outcomeRow(type: .good, description: "It goes fairly well with some positive feedback")
                                OnboardingComponentViews.outcomeRow(type: .better, description: "It goes very well and I receive praise")
                                OnboardingComponentViews.outcomeRow(type: .best, description: "It's phenomenal and leads to a promotion")
                            }
                        }
                    )

                    OnboardingComponentViews.exampleStep(
                        number: 3,
                        title: "Select expected outcome",
                        description: "Choose the outcome you currently think is most likely.",
                        content: {
                            OnboardingComponentViews.outcomeRow(type: .worse, description: "I stumble through it and face criticism", isSelected: true)
                        }
                    )

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

                    VStack(spacing: 16) {
                        Text("You're Ready!")
                            .font(.title2)
                            .fontWeight(.bold)

                        Text("Now you understand how Ryze works. Start by recording your first thought and begin building your personal database of expectations vs. reality.")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)

                    Button(action: {
                        showExampleThought.wrappedValue = false
                        showOnboarding.wrappedValue = false
                    }) {
                        Text("Start My Journey")
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
                .padding(.vertical)
            }
            .navigationTitle("Example Thought")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        showExampleThought.wrappedValue = false
                    }
                }

                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Don't show again") {
                        UserDefaults.standard.set(true, forKey: "permanentlyHideOnboarding")
                        showExampleThought.wrappedValue = false
                        showOnboarding.wrappedValue = false
                    }
                    .foregroundColor(.secondary)
                }
            }
        }
    }
}
