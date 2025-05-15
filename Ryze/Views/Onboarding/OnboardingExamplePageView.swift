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
            ExampleContentView(
                presentationType: .onboarding,
                onComplete: {
                    // Directly set the hasCompletedOnboarding flag
                    UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                    
                    // Use withAnimation to ensure state changes are properly detected
                    withAnimation {
                        showExampleThought.wrappedValue = false
                        showOnboarding.wrappedValue = false
                    }
                }
            )
        }
    }
}
