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
    
    var body: some View {
        ZStack {
            // Background color with gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.white.opacity(0.9),
                    Color.blue.opacity(0.1),
                    Color.purple.opacity(0.1)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Content
            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    
                    Button("Skip") {
                        // Dismiss onboarding with animation
                        withAnimation {
                            showOnboarding = false
                        }
                    }
                    .padding()
                    .foregroundColor(.secondary)
                }
                
                // Page content
                TabView(selection: $currentPage) {
                    // Welcome page
                    welcomePage
                        .tag(0)
                    
                    // Philosophy page
                    philosophyPage
                        .tag(1)
                    
                    // The process page
                    processPage
                        .tag(2)
                    
                    // Example page
                    examplePage
                        .tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                
                // Continue button
                Button(action: {
                    withAnimation {
                        if currentPage < 3 {
                            currentPage += 1
                        } else {
                            // Last page - show example or finish
                            if showExampleThought {
                                // Finish onboarding
                                showOnboarding = false
                            } else {
                                // Show example thought creation
                                showExampleThought = true
                            }
                        }
                    }
                }) {
                    HStack {
                        Text(currentPage < 3 ? "Continue" : (showExampleThought ? "Get Started" : "See an Example"))
                            .fontWeight(.medium)
                        
                        Image(systemName: "arrow.right")
                    }
                    .foregroundColor(.white)
                    .frame(minWidth: 200, minHeight: 50)
                    .background(
                        Capsule()
                            .fill(Color.blue)
                            .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
                    )
                }
                .padding(.vertical, 30)
                .offset(y: animateText ? 0 : 20)
                .opacity(animateText ? 1 : 0)
            }
            
            // Example thought sheet
            .sheet(isPresented: $showExampleThought) {
                exampleThoughtView
            }
        }
        .onAppear {
            // Animate elements when view appears
            withAnimation(.easeOut(duration: 0.8).delay(0.3)) {
                animateIcon = true
            }
            
            withAnimation(.easeOut(duration: 0.6).delay(0.6)) {
                animateText = true
            }
        }
    }
    
    // MARK: - Onboarding Pages
    
    // Welcome Page
    private var welcomePage: some View {
        VStack(spacing: 32) {
            // Animated icon
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
            
            // Welcome text
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
            
            // Description
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
    private var philosophyPage: some View {
        VStack(spacing: 32) {
            // Animated icon
            ZStack {
                Circle()
                    .fill(Color.purple.opacity(0.1))
                    .frame(width: 160, height: 160)
                
                Image(systemName: "cloud.sun")
                    .font(.system(size: 60))
                    .foregroundColor(.purple)
                    .symbolEffect(.pulse.byLayer, options: .repeating, value: animateIcon)
            }
            
            // Title
            VStack(spacing: 16) {
                Text("The Philosophy")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("Our minds evolved to prepare for danger, but this often leads to unnecessary anxiety")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 24)
            }
            
            // Description points
            VStack(alignment: .leading, spacing: 16) {
                thoughtPoint(icon: "exclamationmark.triangle", title: "Catastrophic Thinking", description: "Our brains naturally gravitate toward worst-case scenarios.")
                
                thoughtPoint(icon: "arrow.left.arrow.right", title: "Reality Gap", description: "What we fear rarely matches what actually happens.")
                
                thoughtPoint(icon: "chart.bar.xaxis", title: "Evidence Collection", description: "Systematically tracking this gap changes how your brain works.")
            }
            .padding(.horizontal, 32)
        }
        .padding()
    }
    
    // Process Page
    private var processPage: some View {
        VStack(spacing: 24) {
            // Title
            VStack(spacing: 16) {
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
            
            // Process steps
            VStack(alignment: .leading, spacing: 16) {
                processStep(number: 1, title: "Record", description: "Capture your worrying thought")
                
                processStep(number: 2, title: "Identify", description: "Define the spectrum of possible outcomes")
                
                processStep(number: 3, title: "Predict", description: "Select which outcome you currently expect")
                
                processStep(number: 4, title: "Set", description: "Choose a deadline for when you'll know the result")
                
                processStep(number: 5, title: "Compare", description: "Record what actually happened")
                
                processStep(number: 6, title: "Learn", description: "Observe patterns in your predictions over time")
            }
            .padding(.horizontal, 32)
        }
        .padding()
    }
    
    // Example Page
    private var examplePage: some View {
        VStack(spacing: 32) {
            // Animated icon
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.1))
                    .frame(width: 160, height: 160)
                
                Image(systemName: "lightbulb")
                    .font(.system(size: 60))
                    .foregroundColor(.green)
                    .symbolEffect(.variableColor.iterative, options: .repeating, value: animateIcon)
            }
            
            // Title
            VStack(spacing: 16) {
                Text("Let's Try It")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("Ready to see how it works?")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 24)
            }
            
            // Description
            Text("Tap the button below to explore an example that will walk you through the process of creating your first thought.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 32)
            
            // Benefits list
            VStack(alignment: .leading, spacing: 12) {
                Text("Benefits of practicing with Ryze:")
                    .font(.headline)
                    .padding(.leading, 8)
                
                benefitPoint("Reduced anxiety around uncertainty")
                benefitPoint("Evidence-based recalibration of fears")
                benefitPoint("Greater emotional resilience")
                benefitPoint("Improved decision making")
            }
            .padding(.horizontal, 24)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
    }
    
    // Example thought view
    private var exampleThoughtView: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Introduction
                    Text("Let's walk through an example together")
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
                    
                    // Step 1: Record your thought
                    exampleStep(
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
                    
                    // Step 2: Define outcome spectrum
                    exampleStep(
                        number: 2,
                        title: "Define outcome spectrum",
                        description: "Create a range of possible outcomes from worst to best.",
                        content: {
                            VStack(alignment: .leading, spacing: 8) {
                                outcomeRow(type: .worst, description: "I completely freeze up and get fired")
                                outcomeRow(type: .worse, description: "I stumble through it and face criticism")
                                outcomeRow(type: .okay, description: "I get through it but don't impress anyone")
                                outcomeRow(type: .good, description: "It goes fairly well with some positive feedback")
                                outcomeRow(type: .better, description: "It goes very well and I receive praise")
                                outcomeRow(type: .best, description: "It's phenomenal and leads to a promotion")
                            }
                        }
                    )
                    
                    // Step 3: Select expected outcome
                    exampleStep(
                        number: 3,
                        title: "Select expected outcome",
                        description: "Choose the outcome you currently think is most likely.",
                        content: {
                            outcomeRow(type: .worse, description: "I stumble through it and face criticism", isSelected: true)
                        }
                    )
                    
                    // Step 4: Set deadline
                    exampleStep(
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
                    exampleStep(
                        number: 5,
                        title: "Compare with reality",
                        description: "After the deadline, record what actually happened.",
                        content: {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("When the deadline arrives, you'll receive a notification to record the actual outcome.")
                                    .font(.callout)
                                    .foregroundColor(.secondary)
                                
                                outcomeRow(type: .good, description: "It goes fairly well with some positive feedback", isSelected: true, isActual: true)
                            }
                        }
                    )
                    
                    // Step 6: Learn from patterns
                    exampleStep(
                        number: 6,
                        title: "Learn from patterns",
                        description: "Over time, you'll build a database of predictions vs. reality.",
                        content: {
                            Text("Your dashboard will show you patterns in your thinking and help you recognize when your fears don't match reality.")
                                .font(.callout)
                                .foregroundColor(.secondary)
                        }
                    )
                    
                    // Final message
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
                    
                    // Get started button
                    Button(action: {
                        // Dismiss the sheet and the onboarding
                        showExampleThought = false
                        showOnboarding = false
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
                        showExampleThought = false
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Views
    
    // Philosophy page thought point
    private func thoughtPoint(icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(.purple)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
    
    // Process page step
    private func processStep(number: Int, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Text("\(number)")
                    .font(.headline)
                    .foregroundColor(.blue)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    // Benefits point
    private func benefitPoint(_ text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
            
            Text(text)
                .font(.subheadline)
        }
    }
    
    // Example step
    private func exampleStep<Content: View>(number: Int, title: String, description: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Step header
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: 36, height: 36)
                    
                    Text("\(number)")
                        .font(.headline)
                        .foregroundColor(.blue)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                    
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            // Step content
            content()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground).opacity(0.6))
        )
        .padding(.horizontal)
    }
    
    // Outcome row
    private func outcomeRow(type: OutcomeType, description: String, isSelected: Bool = false, isActual: Bool = false) -> some View {
        HStack {
            Circle()
                .fill(type.color)
                .frame(width: 12, height: 12)
            
            Text(type.displayName)
                .font(.subheadline)
                .foregroundColor(type.color)
                .frame(width: 60, alignment: .leading)
            
            Text(description)
                .font(.callout)
            
            Spacer()
            
            if isSelected {
                Image(systemName: isActual ? "checkmark.circle.fill" : "circle.fill")
                    .foregroundColor(isActual ? .green : .blue)
                    .font(.system(size: isActual ? 22 : 18))
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(isSelected ? .secondarySystemBackground : .systemBackground))
                .opacity(isSelected ? 1 : 0.5)
        )
    }
}

#Preview {
    OnboardingView(
        viewModel: ThoughtViewModel(dataStore: DataStore()),
        showOnboarding: .constant(true)
    )
}