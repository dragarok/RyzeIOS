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
    
    // Chart type enum
    enum ChartType: String, CaseIterable, Identifiable {
        case outcomeDistribution = "Outcome Distribution"
        case expectationsVsReality = "Expectations vs. Reality"
        case fearAccuracyTrend = "Fear Accuracy Trend"
        case positivityScore = "Positivity Score"
        
        var id: Self { self }
        
        var systemImage: String {
            switch self {
            case .expectationsVsReality: return "chart.bar.fill"
            case .fearAccuracyTrend: return "chart.line.uptrend.xyaxis"
            case .outcomeDistribution: return "chart.pie.fill"
            case .positivityScore: return "gauge.medium"
            }
        }
        
        // Convert to ChartMessages.ChartType
        var messageType: ChartMessages.ChartType {
            switch self {
            case .expectationsVsReality: return .expectationsVsReality
            case .fearAccuracyTrend: return .fearAccuracyTrend
            case .outcomeDistribution: return .outcomeDistribution
            case .positivityScore: return .positivityScore
            }
        }
    }
    
    // Computed properties for insights
    private var insights: [InsightCard] {
        AnalyticsManager.generateInsights(thoughts: viewModel.resolvedThoughts)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Chart type picker
            Picker("Chart Type", selection: $selectedChartType) {
                ForEach(ChartType.allCases) { type in
                    Label(type.rawValue, systemImage: type.systemImage)
                        .tag(type)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            // Chart container
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.secondarySystemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                
                VStack(alignment: .leading, spacing: 12) {
                    // Display the selected chart type
                    switch selectedChartType {
                    case .expectationsVsReality:
                        ExpectationVsRealityChart(thoughts: viewModel.resolvedThoughts, animate: animateCharts)
                            .padding(.horizontal)
                        
                    case .fearAccuracyTrend:
                        FearAccuracyTrendChart(thoughts: viewModel.resolvedThoughts, animate: animateCharts)
                            .padding(.horizontal)
                        
                    case .outcomeDistribution:
                        OutcomeDistributionChart(thoughts: viewModel.resolvedThoughts, animate: animateCharts)
                            .padding(.horizontal)
                        
                    case .positivityScore:
                        PositivityScoreChart(thoughts: viewModel.resolvedThoughts, animate: animateCharts)
                            .padding(.horizontal)
                    }
                    
                    // Insight message for the selected chart
                    Text(ChartMessages.getReflectionMessage(for: selectedChartType.messageType))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal)
                        .padding(.bottom)
                }
                .padding(12)
            }
            .padding(.horizontal)
            
            // Insights cards
            VStack(alignment: .leading, spacing: 16) {
                Text("Insights")
                    .font(.headline)
                    .padding(.horizontal)
                
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
    
    // MARK: - Insight Card
    
    private func insightCard(insight: InsightCard) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: insight.icon)
                    .font(.title2)
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
        .frame(width: 300, height: 150)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
        )
    }
}

#Preview {
    InsightsChartView(viewModel: ThoughtViewModel(dataStore: DataStore()))
}