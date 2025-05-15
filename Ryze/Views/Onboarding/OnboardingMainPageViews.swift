//
//  OnboardingMainPageViews.swift
//  Ryze
//
//  Created for Ryze app on 13/04/2025.
//

import SwiftUI

struct OnboardingMainPageViews {
    // Animation states
    @Binding var animateIcon: Bool
    @Binding var animateText: Bool

    // MARK: - Onboarding Pages

    // Welcome Page
    var welcomePage: some View {
        VStack(spacing: 32) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 160, height: 160)

                Image(systemName: "brain.head.profile")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                    .symbolEffect(.bounce, options: .repeating, value: animateIcon)
            }
            .scaleEffect(animateIcon ? 1 : 0.5)
            .opacity(animateIcon ? 1 : 0)

            VStack(spacing: 16) {
                Text("Welcome to Ryze")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text("A personal journey to transform how you think about uncertainty and fear")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 24)
            }
            .offset(y: animateText ? 0 : 20)
            .opacity(animateText ? 1 : 0)

            Text("Ryze helps you break free from fear-based thinking by tracking the gap between what you fear and what actually happens.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 32)
                .offset(y: animateText ? 0 : 20)
                .opacity(animateText ? 1 : 0)
        }
        .padding()
    }

    // Philosophy Page
    var philosophyPage: some View {
        ScrollView {
            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(Color.purple.opacity(0.1))
                        .frame(width: 160, height: 160)

                    Image(systemName: "cloud.sun")
                        .font(.system(size: 60))
                        .foregroundColor(.purple)
                        .symbolEffect(.pulse.byLayer, options: .repeating, value: animateIcon)
                }
                .padding(.top)

                VStack(spacing: 12) {
                    Text("The Philosophy")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)

                    Text("Our minds evolved to prepare for danger, but this often leads to unnecessary anxiety")
                        .font(.headline)
                        
                    Text("Read our full Manifesto in Settings to learn more about overcoming fear-based thinking")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 2)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 24)
                }

                VStack(alignment: .leading, spacing: 16) {
                    OnboardingComponentViews.thoughtPoint(icon: "exclamationmark.triangle", title: "Catastrophic Thinking", description: "Our brains naturally gravitate toward worst-case scenarios.")

                    OnboardingComponentViews.thoughtPoint(icon: "arrow.left.arrow.right", title: "Reality Gap", description: "What we fear rarely matches what actually happens.")

                    OnboardingComponentViews.thoughtPoint(icon: "chart.bar.xaxis", title: "Evidence Collection", description: "Systematically tracking this gap changes how your brain works.")
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 16) // Reduced from 30 to prevent overlap
            }
        }
    }

    // Process Page
    var processPage: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 12) {
                    Text("The Process")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)

                    Text("A simple framework to transform your relationship with uncertainty")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 24)
                }
                .padding(.top)

                VStack(alignment: .leading, spacing: 16) {
                    OnboardingComponentViews.processStep(number: 1, title: "Record", description: "Capture your worrying thought")

                    OnboardingComponentViews.processStep(number: 2, title: "Identify", description: "Define the spectrum of possible outcomes")

                    OnboardingComponentViews.processStep(number: 3, title: "Predict", description: "Select which outcome you currently expect")

                    OnboardingComponentViews.processStep(number: 4, title: "Set", description: "Choose a deadline for when you'll know the result")

                    OnboardingComponentViews.processStep(number: 5, title: "Compare", description: "Record what actually happened")

                    OnboardingComponentViews.processStep(number: 6, title: "Learn", description: "Observe patterns in your predictions over time")
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 16) // Reduced from 30 for consistency
            }
            .padding()
        }
    }
}