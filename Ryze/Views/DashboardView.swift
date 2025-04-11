//
//  DashboardView.swift
//  Ryze
//
//  Created for Ryze app on 09/04/2025.
//

import SwiftUI

struct DashboardView: View {
    @ObservedObject var viewModel: ThoughtViewModel
    @State private var isAnimating = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 30) {
                    Text("Your Thought Analytics")
                        .font(.title2)
                        .fontWeight(.medium)
                        .padding(.horizontal)
                    
                    HStack(spacing: 16) {
                        // Active thoughts counter with subtle animation
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 8) {
                                Image(systemName: "circle.dotted")
                                    .foregroundColor(.blue)
                                    .symbolEffect(.pulse, options: .repeating, value: isAnimating)
                                Text("Active")
                                    .font(.subheadline)
                            }
                            Text("\(viewModel.activeThoughts.count)")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(.blue)
                                .contentTransition(.numericText())
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.blue.opacity(0.1))
                                .shadow(color: Color.black.opacity(0.03), radius: 3, x: 0, y: 1)
                        )
                        
                        // Resolved thoughts counter with subtle animation
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle")
                                    .foregroundColor(.green)
                                    .symbolEffect(.bounce, options: .repeating, value: isAnimating)
                                Text("Resolved")
                                    .font(.subheadline)
                            }
                            Text("\(viewModel.resolvedThoughts.count)")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(.green)
                                .contentTransition(.numericText())
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.green.opacity(0.1))
                                .shadow(color: Color.black.opacity(0.03), radius: 3, x: 0, y: 1)
                        )
                    }
                    .padding(.horizontal)
                    
                    // Placeholder for future insights with zen-like styling
                    VStack(alignment: .center, spacing: 20) {
                        Spacer()
                        
                        Image(systemName: "leaf")
                            .font(.system(size: 36))
                            .foregroundColor(.secondary.opacity(0.6))
                            .symbolEffect(
                                .bounce.up.byLayer,
                                options: .repeating,
                                value: isAnimating
                            )
                        
                        Text("Insights dashboard coming soon")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            
                        Text("Your journey of growth awaits")
                            .font(.subheadline)
                            .foregroundColor(.secondary.opacity(0.7))
                            .padding(.top, 4)
                            
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, minHeight: 240)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.secondarySystemBackground).opacity(0.8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .strokeBorder(Color.secondary.opacity(0.2), lineWidth: 1)
                            )
                            .shadow(color: Color.black.opacity(0.02), radius: 2, x: 0, y: 1)
                    )
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding(.vertical)
            }
            .navigationTitle("Dashboard")
            .background(Color(.systemBackground))
            .onAppear {
                // Trigger the animations when the view appears
                isAnimating = true
            }
        }
    }
}

#Preview {
    DashboardView(viewModel: ThoughtViewModel(dataStore: DataStore()))
}