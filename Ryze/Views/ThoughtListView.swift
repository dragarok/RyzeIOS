//
//  ThoughtListView.swift
//  Ryze
//
//  Created for Ryze app on 09/04/2025.
//

import SwiftUI

struct ThoughtListView: View {
    @ObservedObject var viewModel: ThoughtViewModel
    @State private var showActiveOnly = true
    @State private var selectedThought: Thought?
    @Namespace private var animation
    @State private var refreshID = UUID() // For refreshing animations
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // Filter toggle with more elegant styling
                Picker("Filter", selection: $showActiveOnly) {
                    Text("Active").tag(true)
                    Text("Resolved").tag(false)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .onChange(of: showActiveOnly) { _, _ in
                    // Reset refresh ID to trigger animations when switching tabs
                    refreshID = UUID()
                }
                
                if showActiveOnly && viewModel.activeThoughts.isEmpty {
                    emptyStateView("No active thoughts", "Start by adding a new thought using the + tab below.")
                } else if !showActiveOnly && viewModel.resolvedThoughts.isEmpty {
                    emptyStateView("No resolved thoughts", "Your resolved thoughts will appear here after you've marked them complete.")
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(showActiveOnly ? viewModel.activeThoughts : viewModel.resolvedThoughts) { thought in
                                ThoughtRowView(thought: thought, refreshID: refreshID)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                            selectedThought = thought
                                        }
                                    }
                                    .transition(.asymmetric(
                                        insertion: .scale(scale: 0.95).combined(with: .opacity),
                                        removal: .scale(scale: 0.95).combined(with: .opacity)
                                    ))
                                    .id(thought.id) // Ensure proper animation tracking
                                    .contextMenu {
                                        Button(role: .destructive, action: {
                                            viewModel.deleteThought(thought)
                                        }) {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                    .padding(.horizontal)
                            }
                            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: refreshID)
                        }
                        .padding(.vertical, 8)
                    }
                    .scrollIndicators(.hidden) // Hide scroll indicators for cleaner look
                }
            }
            .navigationTitle("History")
            .background(Color(.systemBackground))
            .sheet(item: $selectedThought) { thought in
                ThoughtDetailView(thought: thought, viewModel: viewModel)
            }
        }
    }
    
    private func emptyStateView(_ title: String, _ message: String) -> some View {
        VStack(spacing: 16) {
            Spacer()
            // More zen-like empty state with softer appearance
            ZStack {
                Circle()
                    .fill(Color.secondary.opacity(0.1))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "leaf")
                    .font(.system(size: 40))
                    .foregroundColor(.secondary.opacity(0.7))
            }
            .padding(.bottom, 8)
            
            Text(title)
                .font(.headline)
                .fontWeight(.medium)
            
            Text(message)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 32)
                .padding(.bottom, 8)
                .lineSpacing(4) // Add some breathing room between lines
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Thought Row View
struct ThoughtRowView: View {
    let thought: Thought
    let refreshID: UUID // To trigger animations on refresh
    @State private var isAppearing = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(thought.question)
                .font(.headline)
                .lineLimit(2)
                .padding(.top, 4)
            
            HStack(spacing: 16) {
                // Expected outcome indicator with refined styling
                if let expectedType = thought.expectedOutcomeType {
                    HStack(spacing: 6) {
                        Text("Expected:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(expectedType.displayName)
                            .font(.caption)
                            .foregroundColor(expectedType.color)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(expectedType.color.opacity(0.15))
                            )
                    }
                }
                
                Spacer()
                
                // Date indicator with more visual polish
                HStack(spacing: 4) {
                    if thought.isResolved {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .symbolEffect(.pulse, options: .repeating, value: refreshID)
                    } else {
                        Image(systemName: "clock.badge")
                            .foregroundColor(.blue.opacity(0.8))
                            .symbolEffect(.variableColor, options: .repeating, value: refreshID)
                    }
                    
                    Text(thought.isResolved ? "Resolved" : dateString(from: thought.deadline))
                        .font(.caption)
                        .foregroundColor(thought.isResolved ? .green : .secondary)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(
                    Capsule()
                        .fill(thought.isResolved ? 
                              Color.green.opacity(0.15) : 
                              Color.blue.opacity(0.1))
                )
            }
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(thought.isResolved ? 
                      softBackgroundFor(thought.actualOutcomeType) : 
                      Color(.secondarySystemBackground))
                .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
        )
        .scaleEffect(isAppearing ? 1 : 0.96)
        .opacity(isAppearing ? 1 : 0.7)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                isAppearing = true
            }
        }
    }
    
    // Generate a soft background color based on outcome type
    private func softBackgroundFor(_ outcomeType: OutcomeType?) -> Color {
        guard let type = outcomeType else { return Color(.secondarySystemBackground) }
        
        // Generate a very subtle background based on the outcome color
        return type.color.opacity(0.08)
    }
    
    // Format the date string with a more zen-like approach
    private func dateString(from date: Date?) -> String {
        guard let deadline = date else { return "No deadline" }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        
        // Calculate days remaining for a more mindful representation
        let days = Calendar.current.dateComponents([.day], from: Date(), to: deadline).day ?? 0
        
        if days == 0 {
            return "Today"
        } else if days == 1 {
            return "Tomorrow"
        } else if days > 1 && days < 7 {
            return "\(days) days"
        } else {
            return formatter.string(from: deadline)
        }
    }
}

#Preview {
    ThoughtListView(viewModel: ThoughtViewModel(dataStore: DataStore()))
}