//
//  InsightsChartView.swift
//  Ryze
//
//  Created for Ryze app on 13/05/2025.
//

import SwiftUI
import Charts

struct InsightsChartView: View {
    let viewModel: ThoughtViewModel
    @State private var selectedChartType: ChartType = .outcomeDistribution
    @State private var selectedChart: String? = nil
    @State private var animateCharts: Bool = false
    @Environment(\.colorScheme) private var colorScheme
    
    // Chart type enum
    enum ChartType: String, CaseIterable, Identifiable {
        case outcomeDistribution = "Outcome Distribution"
        case expectationsVsReality = "Expectations vs. Reality"
        case fearAccuracyTrend = "Fear Accuracy Trend"
        case positivityScore = "Positivity Score"
        
        var id: Self { self }
        
        var systemImage: String {
            switch self {
            case .outcomeDistribution: return "chart.pie.fill"
            case .expectationsVsReality: return "chart.bar.fill"
            case .fearAccuracyTrend: return "chart.line.uptrend.xyaxis"
            case .positivityScore: return "gauge.medium"
            }
        }
        
        // Convert to ChartMessages.ChartType
        var messageType: ChartMessages.ChartType {
            switch self {
            case .outcomeDistribution: return .outcomeDistribution
            case .expectationsVsReality: return .expectationsVsReality
            case .fearAccuracyTrend: return .fearAccuracyTrend
            case .positivityScore: return .positivityScore
            }
        }
    }
    
    // Computed properties for insights
    private var insights: [InsightCard] {
        AnalyticsManager.generateInsights(thoughts: viewModel.resolvedThoughts)
    }
    
    var body: some View {
        VStack(spacing: 24) {
            // Combined chart section (tab bar and chart)
            VStack(spacing: 8) { // Added subtle 8-point spacing
                // Refined custom tab bar
                customTabBar
                
                // Chart container
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(UIColor.secondarySystemBackground))
                        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        // Display the selected chart type
                        switch selectedChartType {
                        case .outcomeDistribution:
                            OutcomeDistributionChart(thoughts: viewModel.resolvedThoughts, animate: animateCharts)
                                .padding(.horizontal, 8)
                            
                        case .expectationsVsReality:
                            ExpectationVsRealityChart(thoughts: viewModel.resolvedThoughts)
                                .padding(.horizontal, 8)
                            
                        case .fearAccuracyTrend:
                            FearAccuracyTrendChart(thoughts: viewModel.resolvedThoughts, animate: animateCharts)
                                .padding(.horizontal, 8)
                            
                        case .positivityScore:
                            PositivityScoreChart(thoughts: viewModel.resolvedThoughts, animate: animateCharts)
                                .padding(.horizontal, 8)
                        }
                    }
                    .padding(16)
                }
            }
            .padding(.horizontal)
            
            // Insights cards
            VStack(alignment: .leading, spacing: 16) {
                Text("Insights")
                    .font(.title3)
                    .fontWeight(.medium)
                    .padding(.leading)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(insights) { insight in
                            insightCard(insight: insight)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            
            Spacer()
        }
        .onAppear {
            // Animate charts after a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation {
                    animateCharts = true
                }
            }
        }
    }
    
    // MARK: - Custom Tab Bar
    
    private var customTabBar: some View {
        HStack(spacing: 0) {
            ForEach(ChartType.allCases) { chartType in
                tabButton(for: chartType)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8) // Increased vertical padding for larger tab bar
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.secondarySystemBackground))
        )
    }
    
    private func tabButton(for chartType: ChartType) -> some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.3)) {
                selectedChartType = chartType
            }
        }) {
            VStack(spacing: 4) { // Increased spacing
                Text(chartType.rawValue)
                    .font(selectedChartType == chartType ? .subheadline : .callout)
                    .fontWeight(selectedChartType == chartType ? .semibold : .regular)
                    .foregroundColor(selectedChartType == chartType ? .primary : .secondary)
                    .lineLimit(1)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                
                // Bottom indicator line
                Rectangle()
                    .frame(height: 3)
                    .foregroundColor(selectedChartType == chartType ? .blue : .clear)
                    .padding(.horizontal, 2)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Insight Card
    
    private func insightCard(insight: InsightCard) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: insight.icon)
                    .font(.title3)
                    .foregroundColor(insight.color)
                
                Text(insight.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            Text(insight.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(4)
            
            Spacer()
        }
        .padding(16)
        .frame(width: 280, height: 140)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.secondarySystemBackground))
                .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
        )
    }
}

#Preview {
    InsightsChartView(viewModel: ThoughtViewModel(dataStore: DataStore()))
}
