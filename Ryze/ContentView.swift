//
//  ContentView.swift
//  Ryze
//
//  Created by Alok Regmi on 07/04/2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    // Main view model injected from the app
    @EnvironmentObject private var thoughtViewModel: ThoughtViewModel
    
    // For controlling the new thought sheet
    @State private var showingNewThought = false
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Dashboard Tab
            DashboardView(viewModel: thoughtViewModel)
                .tabItem {
                    Label("Dashboard", systemImage: "chart.bar")
                }
                .tag(0)
            
            // New Thought Tab (just shows placeholder)
            VStack {
                Text("New Thought")
                    .font(.largeTitle)
            }
            .tabItem {
                Label("New Thought", systemImage: "plus.circle.fill")
            }
            .tag(1)
            
            // History Tab
            ThoughtListView(viewModel: thoughtViewModel)
                .tabItem {
                    Label("History", systemImage: "clock")
                }
                .tag(2)
            
            // Settings Tab
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(3)
        }
        .onChange(of: selectedTab) { oldValue, newValue in
            if newValue == 1 { // New Thought tab
                showingNewThought = true
                selectedTab = oldValue // Go back to previous tab
            }
        }
        .sheet(isPresented: $showingNewThought) {
            NewThoughtView(viewModel: thoughtViewModel)
        }
        .onAppear {
            // Set the tab bar appearance
            let appearance = UITabBarAppearance()
            appearance.configureWithDefaultBackground()
            
            // Adjust tab bar size and clarity
            let itemAppearance = UITabBarItemAppearance(style: .stacked)
            
            // Make tab bar icons bigger
            itemAppearance.normal.iconColor = UIColor.systemGray
            itemAppearance.normal.titleTextAttributes = [.font: UIFont.systemFont(ofSize: 12, weight: .medium)]
            
            // Make selected items more noticeable
            itemAppearance.selected.iconColor = UIColor.systemBlue
            itemAppearance.selected.titleTextAttributes = [.font: UIFont.systemFont(ofSize: 12, weight: .semibold)]
            
            appearance.stackedLayoutAppearance = itemAppearance
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
            
            // Load data when the app appears
            Task {
                await thoughtViewModel.loadThoughts()
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(ThoughtViewModel(dataStore: DataStore()))
}