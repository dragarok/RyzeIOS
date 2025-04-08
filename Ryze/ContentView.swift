//
//  ContentView.swift
//  Ryze
//
//  Created by Alok Regmi on 07/04/2025.
//

import SwiftUI

struct ContentView: View {
    // Main view model shared across the app
    @StateObject private var thoughtViewModel = ThoughtViewModel(dataStore: DataStore())
    
    // For controlling the new thought sheet
    @State private var showingNewThought = false
    
    var body: some View {
        TabView {
            // Dashboard Tab
            DashboardView(viewModel: thoughtViewModel)
                .tabItem {
                    Label("Dashboard", systemImage: "chart.bar")
                }
            
            // New Thought Tab (Button only)
            VStack {} // Empty view as the tab itself is just a button
                .tabItem {
                    Label("New Thought", systemImage: "plus.circle.fill")
                }
                .onTapGesture {
                    showingNewThought = true
                }
            
            // History Tab
            ThoughtListView(viewModel: thoughtViewModel)
                .tabItem {
                    Label("History", systemImage: "clock")
                }
            
            // Settings Tab
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .sheet(isPresented: $showingNewThought) {
            NewThoughtView(viewModel: thoughtViewModel)
        }
        .onAppear {
            // Load data when the app appears
            Task {
                await thoughtViewModel.loadThoughts()
            }
        }
    }
}

#Preview {
    ContentView()
}
