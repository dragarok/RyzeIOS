//
//  DashboardView.swift
//  Ryze
//
//  Created on 08/04/2025.
//

import SwiftUI

struct DashboardView: View {
    @ObservedObject var viewModel: ThoughtViewModel
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                // Dashboard metrics will go here
                Text("Your Thought Analytics")
                    .font(.largeTitle)
                    .bold()
                    .padding(.horizontal)
                
                // Placeholder stats
                HStack(spacing: 16) {
                    StatCard(
                        title: "Active",
                        value: "\(viewModel.thoughts.filter { !$0.isResolved }.count)",
                        icon: "clock",
                        color: .blue
                    )
                    
                    StatCard(
                        title: "Resolved",
                        value: "\(viewModel.thoughts.filter { $0.isResolved }.count)",
                        icon: "checkmark.circle",
                        color: .green
                    )
                }
                .padding(.horizontal)
                
                Spacer()
                
                Text("Insights dashboard coming soon!")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            }
            .padding(.top)
            .navigationTitle("Dashboard")
        }
    }
}

// Quick stat card component
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .foregroundColor(.secondary)
            }
            
            Text(value)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview {
    DashboardView(viewModel: ThoughtViewModel(dataStore: DataStore()))
}