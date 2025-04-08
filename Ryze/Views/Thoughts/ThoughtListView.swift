//
//  ThoughtListView.swift
//  Ryze
//
//  Created on 08/04/2025.
//

import SwiftUI

struct ThoughtListView: View {
    @ObservedObject var viewModel: ThoughtViewModel
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading {
                    ProgressView("Loading thoughts...")
                } else if viewModel.filteredThoughts.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "lightbulb")
                            .font(.system(size: 48))
                            .foregroundColor(.yellow)
                        Text("No thoughts yet")
                            .font(.headline)
                        Text("When you add thoughts, they'll appear here.")
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                } else {
                    List {
                        // Will be replaced with actual list items
                        ForEach(viewModel.filteredThoughts) { thought in
                            Text(thought.question)
                        }
                    }
                }
            }
            .navigationTitle("History")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Picker("Sort", selection: $viewModel.sortOption) {
                            ForEach(ThoughtViewModel.SortOption.allCases, id: \.self) { option in
                                Text(option.rawValue).tag(option)
                            }
                        }
                        
                        Divider()
                        
                        Toggle("Show Resolved", isOn: $viewModel.showResolved)
                        Toggle("Show Active", isOn: $viewModel.showUnresolved)
                    } label: {
                        Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                    }
                }
            }
            .task {
                // Load thoughts when view appears
                await viewModel.loadThoughts()
            }
        }
    }
}

#Preview {
    ThoughtListView(viewModel: ThoughtViewModel(dataStore: DataStore()))
}