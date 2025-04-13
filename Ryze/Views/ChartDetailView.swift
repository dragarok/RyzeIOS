//
//  ChartDetailView.swift
//  Ryze
//
//  Created for Ryze app on 13/04/2025.
//

import SwiftUI
import Charts

struct ChartDetailView: View {
    let chartType: InsightsChartView.ChartType
    let viewModel: ThoughtViewModel
    @State private var animateChart = false
    @Environment(\.dismiss) private var dismiss
    
    // Computed properties for chart data
    private var outcomesData: [OutcomeComparisonData] {
        AnalyticsManager.generateOutcomeComparisonData(thoughts: viewModel.resolvedThoughts)
    }
    
    private var trendData: [FearAccuracyData] {
        AnalyticsManager.generateFearAccuracyData(thoughts: viewModel.resolvedThoughts)
    }
    
    private var positivityScore: Double {
        AnalyticsManager.calculatePositivityScore(thoughts: viewModel.resolvedThoughts)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header with chart title and description
                VStack(alignment: .leading, spacing: 8) {
                    Text(chartType.rawValue)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(getChartDescription())
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal)
                
                // Chart card
                VStack(spacing: 16) {
                    switch chartType {
                    case .stackedBar:
                        largeOutcomeComparisonChart
                            .frame(height: 300)
                            .padding(.horizontal)
                        
                        // Data table for comparison
                        outcomeComparisonTable
                        
                    case .trendLine:
                        largeFearAccuracyTrendChart
                            .frame(height: 300)
                            .padding(.horizontal)
                        
                        // Monthly accuracy data
                        accuracyTrendTable
                        
                    case .pieChart:
                        largeOutcomeDistributionChart
                            .frame(height: 300)
                            .padding(.horizontal)
                        
                        // Distribution percentages
                        outcomeDistributionTable
                        
                    case .positivityScore:
                        largePositivityScoreView
                            .frame(height: 300)
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
                    
                    Text(getPositiveMessage())
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
    
    // MARK: - Chart Components
    
    // Large Stacked Bar Chart: Expectations vs Reality
    private var largeOutcomeComparisonChart: some View {
        Chart {
            ForEach(outcomesData) { data in
                BarMark(
                    x: .value("Outcome", data.outcomeType.displayName),
                    y: .value("Count", animateChart ? data.expectedCount : 0)
                )
                .foregroundStyle(data.outcomeType.color.opacity(0.7))
                .annotation(position: .top) {
                    if data.expectedCount > 0 {
                        Text("\(data.expectedCount)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .position(by: .value("Type", "Expected"))
                
                BarMark(
                    x: .value("Outcome", data.outcomeType.displayName),
                    y: .value("Count", animateChart ? data.actualCount : 0)
                )
                .foregroundStyle(data.outcomeType.color)
                .annotation(position: .top) {
                    if data.actualCount > 0 {
                        Text("\(data.actualCount)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .position(by: .value("Type", "Actual"))
            }
        }
        .chartForegroundStyleScale(["Expected": Color.gray.opacity(0.5), "Actual": Color.blue.opacity(0.8)])
        .chartLegend(position: .bottom, alignment: .center)
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .chartYAxis {
            AxisMarks { _ in
                AxisGridLine()
                AxisTick()
                AxisValueLabel()
            }
        }
    }
    
    // Large Line Chart: Fear Accuracy Trend
    private var largeFearAccuracyTrendChart: some View {
        Chart {
            ForEach(trendData) { data in
                LineMark(
                    x: .value("Month", data.month),
                    y: .value("Accuracy %", animateChart ? data.accuracyPercentage : 0)
                )
                .symbol(Circle())
                .symbolSize(animateChart ? 50 : 0)
                .lineStyle(StrokeStyle(lineWidth: 3))
                .foregroundStyle(Gradient(colors: [.blue, .purple]))
                .interpolationMethod(.catmullRom)
                .annotation(position: .top) {
                    Text("\(Int(data.accuracyPercentage))%")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            if !trendData.isEmpty {
                RuleMark(
                    y: .value("Average", 50)
                )
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                .foregroundStyle(.gray.opacity(0.5))
                .annotation(alignment: .leading) {
                    Text("50%")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .chartYScale(domain: 0...100)
        .chartYAxis {
            AxisMarks { value in
                AxisGridLine()
                AxisTick()
                AxisValueLabel {
                    if let doubleValue = value.as(Double.self) {
                        Text("\(Int(doubleValue))%")
                            .font(.caption)
                    }
                }
            }
        }
    }
    
    // Large Pie Chart: Outcome Distribution
    private var largeOutcomeDistributionChart: some View {
        let actualOutcomes = outcomesData.filter { $0.actualCount > 0 }
        let totalCount = actualOutcomes.reduce(0) { $0 + $1.actualCount }
        
        return Chart(actualOutcomes) { data in
            SectorMark(
                angle: .value("Count", animateChart ? data.actualCount : 0),
                innerRadius: .ratio(0.6),
                angularInset: 1
            )
            .cornerRadius(5)
            .foregroundStyle(data.outcomeType.color)
            .annotation(position: .overlay) {
                if data.actualCount > 0 {
                    VStack {
                        Text(data.outcomeType.displayName)
                            .font(.caption)
                            .bold()
                        
                        if totalCount > 0 {
                            Text("\(Int((Double(data.actualCount) / Double(totalCount)) * 100))%")
                                .font(.caption2)
                        }
                    }
                    .foregroundColor(.white)
                    .shadow(radius: 1)
                }
            }
        }
    }
    
    // Large Positivity Score Gauge
    private var largePositivityScoreView: some View {
        VStack {
            ZStack {
                Circle()
                    .trim(from: 0, to: 1)
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: [.red, .orange, .yellow, .green, .blue, .purple]),
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: 30, lineCap: .round)
                    )
                    .frame(width: 250, height: 250)
                    .rotationEffect(.degrees(90))
                    .opacity(0.2)
                
                Circle()
                    .trim(from: 0, to: animateChart ? positivityScore / 100 : 0)
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: [.red, .orange, .yellow, .green, .blue, .purple]),
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: 30, lineCap: .round)
                    )
                    .frame(width: 250, height: 250)
                    .rotationEffect(.degrees(90))
                
                VStack(spacing: 8) {
                    Text("\(Int(positivityScore))")
                        .font(.system(size: 60, weight: .bold))
                        .foregroundColor(getScoreColor(score: positivityScore))
                    
                    Text(getScoreDescription(score: positivityScore))
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }
        }
    }
    
    // MARK: - Data Tables and Explanations
    
    private var outcomeComparisonTable: some View {
        VStack(alignment: .leading, spacing: 8) {
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
    
    private var accuracyTrendTable: some View {
        VStack(alignment: .leading, spacing: 8) {
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
                        
                        Text(getAccuracyRating(percentage: data.accuracyPercentage))
                            .foregroundColor(getAccuracyColor(percentage: data.accuracyPercentage))
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
    
    private var outcomeDistributionTable: some View {
        let actualOutcomes = outcomesData.filter { $0.actualCount > 0 }
        let totalCount = actualOutcomes.reduce(0) { $0 + $1.actualCount }
        
        return VStack(alignment: .leading, spacing: 8) {
            Text("Outcome Distribution")
                .font(.headline)
                .padding(.top, 8)
            
            Divider()
            
            if totalCount == 0 {
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
                    
                    Text("Count")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .frame(width: 80)
                    
                    Text("Percentage")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .frame(width: 100)
                }
                .padding(.vertical, 4)
                
                // Table rows
                ForEach(actualOutcomes) { data in
                    HStack {
                        HStack {
                            Circle()
                                .fill(data.outcomeType.color)
                                .frame(width: 12, height: 12)
                            
                            Text(data.outcomeType.displayName)
                                .font(.callout)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text("\(data.actualCount)")
                            .frame(width: 80)
                        
                        Text("\(Int((Double(data.actualCount) / Double(totalCount)) * 100))%")
                            .frame(width: 100)
                    }
                    .padding(.vertical, 4)
                    
                    Divider()
                }
                
                // Summary
                Text("This distribution shows where your actual outcomes landed on the spectrum from worst to best.")
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .padding(.top, 8)
            }
        }
        .padding(.horizontal)
    }
    
    private var positivityScoreExplanation: some View {
        VStack(alignment: .leading, spacing: 12) {
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
            
            Text("A score of 50 means your outcomes generally matched your expectations. Higher scores indicate reality consistently exceeded your fears.")
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
    
    private func getChartDescription() -> String {
        switch chartType {
        case .stackedBar:
            return "This chart compares how many times you expected each outcome type versus how many times each actually occurred."
        case .trendLine:
            return "This trend shows how accurately your expectations matched reality over time. Higher percentages mean reality was as good as or better than you expected."
        case .pieChart:
            return "This pie chart shows the distribution of your actual outcomes, revealing where reality typically lands on the spectrum from worst to best."
        case .positivityScore:
            return "Your positivity score measures the gap between your expectations and reality. A higher score means reality consistently exceeds your expectations."
        }
    }
    
    private func getPositiveMessage() -> String {
        let positiveMessages: [InsightsChartView.ChartType: [String]] = [
            .stackedBar: [
                "When we compare our expectations to reality, we often find that our fears rarely materialize in the way we imagine. This awareness helps recalibrate our thinking.",
                "Your brain evolved to prepare for the worst as a survival mechanism. This chart helps you see the gap between ancient instincts and modern reality.",
                "Notice any patterns in how you predict outcomes versus what actually happens. This awareness builds your emotional intelligence over time."
            ],
            .trendLine: [
                "As you continue to track your thoughts, notice how your prediction accuracy changes. Many people become more optimistic as they see evidence that outcomes are often better than feared.",
                "This trend line represents your growing ability to distinguish between helpful caution and limiting catastrophic thinking.",
                "Each point on this chart represents a moment of learning - a time when you challenged a fear-based thought and discovered what actually happened."
            ],
            .pieChart: [
                "This distribution of outcomes shows you the true landscape of your experiences. Our minds tend to remember negative outcomes more strongly, but this chart shows the complete picture.",
                "Looking at this distribution helps counteract 'negativity bias' - our tendency to focus on and remember negative experiences more than positive ones.",
                "This chart represents the actual fabric of your experiences, not filtered through fear or anticipation."
            ],
            .positivityScore: [
                "Your positivity score isn't about toxic positivity or ignoring real concerns. It's about calibrating your expectations to match reality more accurately.",
                "Think of this score as your brain's operating system gradually receiving updates based on real-world data rather than ancient survival programming.",
                "As this score changes over time, it represents your growing ability to see situations clearly rather than through a lens of fear."
            ]
        ]
        
        if let messages = positiveMessages[chartType], !messages.isEmpty {
            return messages.randomElement()!
        }
        
        return "By tracking your thoughts and outcomes, you're developing greater emotional resilience and a more balanced perspective."
    }
    
    private func getRelatedInsights() -> [InsightCard] {
        // Get all insights and filter to show only those related to the current chart type
        let allInsights = AnalyticsManager.generateInsights(thoughts: viewModel.resolvedThoughts)
        
        switch chartType {
        case .stackedBar, .pieChart:
            // Return insights about outcome patterns
            return allInsights.filter { insight in
                insight.title.contains("Pattern") ||
                insight.title.contains("Reality") ||
                insight.title.contains("Perspective")
            }
            
        case .trendLine:
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
    
    private func getScoreColor(score: Double) -> Color {
        switch score {
        case 0..<30: return .red
        case 30..<50: return .orange
        case 50..<70: return .yellow
        case 70..<90: return .green
        default: return .blue
        }
    }
    
    private func getScoreDescription(score: Double) -> String {
        switch score {
        case 0..<30: return "Worse than expected"
        case 30..<50: return "Slightly worse than expected"
        case 50..<70: return "Matches expectations"
        case 70..<90: return "Better than expected"
        default: return "Much better than expected"
        }
    }
    
    private func getAccuracyRating(percentage: Double) -> String {
        switch percentage {
        case 0..<20: return "Very Low"
        case 20..<40: return "Low"
        case 40..<60: return "Moderate"
        case 60..<80: return "Good"
        default: return "Excellent"
        }
    }
    
    private func getAccuracyColor(percentage: Double) -> Color {
        switch percentage {
        case 0..<20: return .red
        case 20..<40: return .orange
        case 40..<60: return .yellow
        case 60..<80: return .green
        default: return .blue
        }
    }
}

#Preview {
    NavigationStack {
        ChartDetailView(
            chartType: .stackedBar,
            viewModel: ThoughtViewModel(dataStore: DataStore())
        )
    }
}