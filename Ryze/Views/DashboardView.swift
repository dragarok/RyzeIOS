//
//  DashboardView.swift
//  Ryze
//
//  Created for Ryze app on 09/04/2025.
//

import SwiftUI

struct DashboardView: View {
    @ObservedObject var viewModel: ThoughtViewModel
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("Your Thought Analytics")
                        .font(.title2)
                        .fontWeight(.medium)
                        .padding(.horizontal)
                    
                    HStack(spacing: 12) {
                        // Active thoughts counter
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Image(systemName: "circle.dotted")
                                    .foregroundColor(.blue)
                                Text("Active")
                                    .font(.subheadline)
                            }
                            Text("\(viewModel.activeThoughts.count)")
                                .font(.system(size: 42, weight: .bold))
                                .foregroundColor(.blue)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.blue.opacity(0.1))
                        )
                        
                        // Resolved thoughts counter
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Image(systemName: "checkmark.circle")
                                    .foregroundColor(.green)
                                Text("Resolved")
                                    .font(.subheadline)
                            }
                            Text("\(viewModel.resolvedThoughts.count)")
                                .font(.system(size: 42, weight: .bold))
                                .foregroundColor(.green)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.green.opacity(0.1))
                        )
                    }
                    .padding(.horizontal)
                    
                    // Placeholder for future insights/charts
                    VStack(alignment: .center, spacing: 12) {
                        Spacer()
                        Text("Insights dashboard coming soon!")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, minHeight: 200)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                    )
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding(.vertical)
            }
            .navigationTitle("Dashboard")
            .background(Color(.systemBackground))
        }
    }
}

#Preview {
    DashboardView(viewModel: ThoughtViewModel(dataStore: DataStore()))
}