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
    
    var body: some View {
        NavigationStack {
            VStack {
                // Filter toggle
                Picker("Filter", selection: $showActiveOnly) {
                    Text("Active").tag(true)
                    Text("Resolved").tag(false)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                if showActiveOnly && viewModel.activeThoughts.isEmpty {
                    emptyStateView("No active thoughts", "Start by adding a new thought using the + tab below.")
                } else if !showActiveOnly && viewModel.resolvedThoughts.isEmpty {
                    emptyStateView("No resolved thoughts", "Your resolved thoughts will appear here after you've marked them complete.")
                } else {
                    List {
                        ForEach(showActiveOnly ? viewModel.activeThoughts : viewModel.resolvedThoughts) { thought in
                            ThoughtRowView(thought: thought)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedThought = thought
                                }
                        }
                        .onDelete { indexSet in
                            let thoughtsToDelete = showActiveOnly ? viewModel.activeThoughts : viewModel.resolvedThoughts
                            for index in indexSet {
                                viewModel.deleteThought(thoughtsToDelete[index])
                            }
                        }
                    }
                    .listStyle(.plain)
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
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text(title)
                .font(.headline)
            Text(message)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 32)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Thought Row View
struct ThoughtRowView: View {
    let thought: Thought
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(thought.question)
                .font(.headline)
                .lineLimit(2)
            
            HStack(spacing: 12) {
                // Expected outcome indicator
                if let expectedType = thought.expectedOutcomeType {
                    HStack(spacing: 4) {
                        Text("Expected:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(expectedType.displayName)
                            .font(.caption)
                            .foregroundColor(expectedType.color)
                            .fontWeight(.medium)
                    }
                }
                
                Spacer()
                
                // Date indicator
                HStack {
                    Image(systemName: thought.isResolved ? "checkmark.circle" : "clock")
                        .foregroundColor(thought.isResolved ? .green : .blue)
                    Text(thought.isResolved ? "Resolved" : dateFormatter.string(from: thought.deadline ?? Date()))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }
}

#Preview {
    ThoughtListView(viewModel: ThoughtViewModel(dataStore: DataStore()))
}