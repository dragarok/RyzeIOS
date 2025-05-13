//
//  ChartDetailView.swift
//  Ryze
//
//  Created for Ryze app on 13/05/2025.
//

import SwiftUI
import Charts

struct ChartDetailView: View {
    let chartType: InsightsChartView.ChartType
    let viewModel: ThoughtViewModel
    @State private var animateChart = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header with chart title and description
                VStack(alignment: .leading, spacing: 8) {
                    Text(chartType.rawValue)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(ChartMessages.getChartDescription(for: chartType.messageType))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal)
                
                // Chart card
                VStack(spacing: 16) {
                    switch chartType {
                    case .expectationsVsReality:
                        ExpectationVsRealityChart(thoughts: viewModel.resolvedThoughts)
                            .padding(.horizontal)
                        
                        // Data table for comparison
                        expectationVsRealityDataTable
                        
                    case .fearAccuracyTrend:
                        FearAccuracyTrendChart(thoughts: viewModel.resolvedThoughts, animate: animateChart)
                            .padding(.horizontal)
                        
                        // Monthly accuracy data
                        fearAccuracyDataTable
                        
                    case .outcomeDistribution:
                        OutcomeDistributionChart(thoughts: viewModel.resolvedThoughts, animate: animateChart)
                            .padding(.horizontal)
                        
                        // Distribution percentages
                        outcomeDistributionDataTable
                        
                    case .positivityScore:
                        PositivityScoreChart(thoughts: viewModel.resolvedThoughts, animate: animateChart)
                            .padding(.horizontal)
                        
                        // Score explanation
                        positivityScoreExplanation
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.secondarySystemBackground))
                        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
                )
                .padding(.horizontal)
                
                // Positive message
                VStack(alignment: .leading, spacing: 12) {
                    Label("Reflection", systemImage: "lightbulb.fill")
                        .font(.headline)
                        .foregroundColor(.orange)
                    
                    Text(ChartMessages.getReflectionMessage(for: chartType.messageType))
                        .font(.body)
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.orange.opacity(0.1))
                )
                .padding(.horizontal)
                
                // Related insights based on chart type
                let relatedInsights = getRelatedInsights()
                if !relatedInsights.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Related Insights")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(relatedInsights) { insight in
                            insightCard(insight: insight)
                                .padding(.horizontal)
                        }
                    }
                }
                
                Spacer()
            }
            .padding(.vertical)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                }
            }
        }
        .onAppear {
            // Animate chart after a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation {
                    animateChart = true
                }
            }
        }
    }
    
    // MARK: - Data Tables and Explanations
    
    private var expectationVsRealityDataTable: some View {
        let outcomesData = ChartDataProvider.generateOutcomeComparisonData(thoughts: viewModel.resolvedThoughts)
        
        return VStack(alignment: .leading, spacing: 8) {
            Text("Outcome Comparison")
                .font(.headline)
                .padding(.top, 8)
            
            Divider()
            
            // Table header
            HStack {
                Text("Outcome Type")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("Expected")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(width: 80)
                
                Text("Actual")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(width: 80)
                
                Text("Difference")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(width: 80)
            }
            .padding(.vertical, 4)
            
            // Table rows
            ForEach(outcomesData) { data in
                HStack {
                    HStack {
                        Circle()
                            .fill(data.outcomeType.color)
                            .frame(width: 12, height: 12)
                        
                        Text(data.outcomeType.displayName)
                            .font(.callout)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("\(data.expectedCount)")
                        .frame(width: 80)
                    
                    Text("\(data.actualCount)")
                        .frame(width: 80)
                    
                    let difference = data.actualCount - data.expectedCount
                    Text("\(difference > 0 ? "+" : "")\(difference)")
                        .foregroundColor(difference > 0 ? .green : (difference < 0 ? .red : .primary))
                        .frame(width: 80)
                }
                .padding(.vertical, 4)
                
                Divider()
            }
            
            // Summary
            Text("This comparison shows how your expectations matched reality. A positive difference means reality exceeded your expectations.")
                .font(.callout)
                .foregroundColor(.secondary)
                .padding(.top, 8)
        }
        .padding(.horizontal)
    }
    
    private var fearAccuracyDataTable: some View {
        let trendData = ChartDataProvider.generateFearAccuracyData(thoughts: viewModel.resolvedThoughts)
        
        return VStack(alignment: .leading, spacing: 8) {
            Text("Monthly Accuracy")
                .font(.headline)
                .padding(.top, 8)
            
            Divider()
            
            if trendData.isEmpty {
                Text("Not enough resolved thoughts across multiple months to show trends.")
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 8)
            } else {
                // Table header
                HStack {
                    Text("Month")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("Accuracy %")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .frame(width: 100)
                    
                    Text("Rating")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .frame(width: 100)
                }
                .padding(.vertical, 4)
                
                // Table rows
                ForEach(trendData) { data in
                    HStack {
                        Text(data.month)
                            .font(.callout)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text("\(Int(data.accuracyPercentage))%")
                            .frame(width: 100)
                        
                        Text(ChartMessages.getAccuracyRating(percentage: data.accuracyPercentage))
                            .foregroundColor(ChartMessages.getAccuracyColor(percentage: data.accuracyPercentage))
                            .frame(width: 100)
                    }
                    .padding(.vertical, 4)
                    
                    Divider()
                }
                
                // Summary
                Text("A higher percentage means reality was as good as or better than you expected more often.")
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .padding(.top, 8)
            }
        }
        .padding(.horizontal)
    }
    
    private var outcomeDistributionDataTable: some View {
        let chartData = ChartDataProvider.generatePieChartData(thoughts: viewModel.resolvedThoughts)
        
        return VStack(alignment: .leading, spacing: 8) {
            Text("Outcome Distribution")
                .font(.headline)
                .padding(.top, 8)
            
            Divider()
            
            if chartData.isEmpty {
                Text("No resolved thoughts yet to show distribution.")
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 8)
            } else {
                // Table header
                HStack {
                    Text("Outcome Type")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("Expected %")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .frame(width: 100)
                    
                    Text("Actual %")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .frame(width: 100)
                }
                .padding(.vertical, 4)
                
                // Table rows
                ForEach(chartData) { data in
                    HStack {
                        HStack {
                            Circle()
                                .fill(data.type.color)
                                .frame(width: 12, height: 12)
                            
                            Text(data.type.displayName)
                                .font(.callout)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text("\(Int(data.expectedPercentage))%")
                            .frame(width: 100)
                        
                        Text("\(Int(data.actualPercentage))%")
                            .frame(width: 100)
                    }
                    .padding(.vertical, 4)
                    
                    Divider()
                }
                
                // Summary
                Text("This distribution compares where you expected outcomes to land versus where they actually did.")
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .padding(.top, 8)
            }
        }
        .padding(.horizontal)
    }
    
    private var positivityScoreExplanation: some View {
        let score = ChartDataProvider.calculatePositivityScore(thoughts: viewModel.resolvedThoughts)
        
        return VStack(alignment: .leading, spacing: 12) {
            Text("Understanding Your Score")
                .font(.headline)
                .padding(.top, 8)
            
            Divider()
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Your positivity score is calculated based on:")
                    .font(.subheadline)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("• How often reality was better than you expected")
                    Text("• The degree to which outcomes exceeded your expectations")
                    Text("• The consistency of positive surprises across different thoughts")
                }
                .padding(.leading, 8)
                .font(.callout)
                .foregroundColor(.secondary)
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Score Interpretation:")
                    .font(.subheadline)
                
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        scoreRangeRow(range: "0-30", description: "Worse than expected", color: .red)
                        scoreRangeRow(range: "30-50", description: "Slightly worse than expected", color: .orange)
                        scoreRangeRow(range: "50-70", description: "Matches expectations", color: .yellow)
                        scoreRangeRow(range: "70-90", description: "Better than expected", color: .green)
                        scoreRangeRow(range: "90-100", description: "Much better than expected", color: .blue)
                    }
                }
            }
            
            Text(ChartMessages.getScoreExplanation(score: score))
                .font(.callout)
                .foregroundColor(.secondary)
                .padding(.top, 8)
        }
        .padding(.horizontal)
    }
    
    private func scoreRangeRow(range: String, description: String, color: Color) -> some View {
        HStack(spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
            
            Text(range)
                .font(.callout)
                .frame(width: 60, alignment: .leading)
            
            Text(description)
                .font(.callout)
                .foregroundColor(.secondary)
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
            
            Spacer()
        }
        .padding(16)
        .frame(height: 140)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
        )
    }
    
    // MARK: - Helper Methods
    
    private func getRelatedInsights() -> [InsightCard] {
        // Get all insights and filter to show only those related to the current chart type
        let allInsights = AnalyticsManager.generateInsights(thoughts: viewModel.resolvedThoughts)
        
        switch chartType {
        case .expectationsVsReality, .outcomeDistribution:
            // Return insights about outcome patterns
            return allInsights.filter { insight in
                insight.title.contains("Pattern") ||
                insight.title.contains("Reality") ||
                insight.title.contains("Perspective")
            }
            
        case .fearAccuracyTrend:
            // Return insights about growth or improvement
            return allInsights.filter { insight in
                insight.title.contains("Growth") ||
                insight.title.contains("Mindset")
            }
            
        case .positivityScore:
            // Return encouraging insights
            return allInsights
        }
    }
}

#Preview {
    NavigationStack {
        ChartDetailView(
            chartType: .expectationsVsReality,
            viewModel: ThoughtViewModel(dataStore: DataStore())
        )
    }
}
