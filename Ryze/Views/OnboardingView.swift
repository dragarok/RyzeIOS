//
//  OnboardingView.swift
//  Ryze
//
//  Created for Ryze app on 13/04/2025.
//

import SwiftUI

struct OnboardingView: View {
    @ObservedObject var viewModel: ThoughtViewModel
    @State private var currentPage = 0
    @State private var showExampleThought = false
    @Binding var showOnboarding: Bool

    // Animation states
    @State private var animateIcon = false
    @State private var animateText = false

    // Page view instances
    private var mainPageViews: OnboardingMainPageViews {
        OnboardingMainPageViews(animateIcon: $animateIcon, animateText: $animateText)
    }

    private var examplePageView: OnboardingExamplePageView {
        OnboardingExamplePageView(animateIcon: $animateIcon, animateText: $animateText)
    }

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            LinearGradient(
                gradient: Gradient(colors: [
                    Color.white,
                    Color.blue.opacity(0.1),
                    Color.purple.opacity(0.1)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    mainPageViews.welcomePage
                        .tag(0)

                    mainPageViews.philosophyPage
                        .tag(1)

                    mainPageViews.processPage
                        .tag(2)

                    examplePageView.examplePage
                        .tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .padding(.bottom, 30) // Increased from 100 to push dots lower

                Spacer(minLength: 20) // Reduced from 40 to balance spacing

                Button(action: {
                    withAnimation {
                        if currentPage < 3 {
                            currentPage += 1
                        } else {
                            if showExampleThought {
                                showOnboarding = false
                            } else {
                                showExampleThought = true
                            }
                        }
                    }
                }) {
                    HStack(spacing: 12) {
                        Text(currentPage < 3 ? "Continue" : (showExampleThought ? "Get Started" : "See an Example"))
                            .fontWeight(.semibold)

                        Image(systemName: "arrow.right")
                            .font(.system(size: 16))
                    }
                    .foregroundColor(.white)
                    .frame(minWidth: 230, minHeight: 56)
                    .background(
                        Capsule()
                            .fill(Color.blue)
                            .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                    )
                }
                .padding(.top, 8)
                .padding(.bottom, 12) // Reduced from 50 to balance with new TabView padding
                .offset(y: animateText ? 0 : 20)
                .opacity(animateText ? 1 : 0)
            }

            .sheet(isPresented: $showExampleThought) {
                examplePageView.exampleThoughtView(showExampleThought: $showExampleThought, showOnboarding: $showOnboarding)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8).delay(0.3)) {
                animateIcon = true
            }

            withAnimation(.easeOut(duration: 0.6).delay(0.6)) {
                animateText = true
            }
        }
    }
}

#Preview {
    OnboardingView(
        viewModel: ThoughtViewModel(dataStore: DataStore()),
        showOnboarding: .constant(true)
    )
}