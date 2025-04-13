//
//  InsightsChartView.swift
//  Ryze
//
//  Created for Ryze app on 13/04/2025.
//

import SwiftUI
import Charts

struct InsightsChartView: View {
    let viewModel: ThoughtViewModel
    @State private var selectedChartType: ChartType = .stackedBar
    @State private var selectedChart: String? = nil
    @State private var animateCharts: Bool = false
    
    // Computed properties
    private var outcomesData: [OutcomeComparisonData] {
        AnalyticsManager.generateOutcomeComparisonData(thoughts: viewModel.resolvedThoughts)
    }
    
    private var trendData: [FearAccuracyData] {
        AnalyticsManager.generateFearAccuracyData(thoughts: viewModel.resolvedThoughts)
    }
    
    private var positivityScore: Double {
        AnalyticsManager.calculatePositivityScore(thoughts: viewModel.resolvedThoughts)
    }
    
    private var insights: [InsightCard] {
        AnalyticsManager.generateInsights(thoughts: viewModel.resolvedThoughts)
    }
    
    // Chart type enum
    enum ChartType: String, CaseIterable, Identifiable {
        case stackedBar = "Expectations vs. Reality"
        case trendLine = "Fear Accuracy Trend"
        case pieChart = "Outcome Distribution"
        case positivityScore = "Positivity Score"
        
        var id: Self { self }
        
        var systemImage: String {
            switch self {
            case .stackedBar: return "chart.bar.fill"
            case .trendLine: return "chart.line.uptrend.xyaxis"
            case .pieChart: return "chart.pie.fill"
            case .positivityScore: return "gauge.medium"
            }
        }
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
            
            // Chart view
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.secondarySystemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                
                VStack(alignment: .leading, spacing: 12) {
                    // Chart title
                    Text(selectedChartType.rawValue)
                        .font(.headline)
                        .padding(.horizontal)
                        .padding(.top)
                    
                    // Different chart types
                    switch selectedChartType {
                    case .stackedBar:
                        outcomeComparisonChart
                            .frame(height: 250)
                            .padding(.horizontal)
                        
                    case .trendLine:
                        fearAccuracyTrendChart
                            .frame(height: 250)
                            .padding(.horizontal)
                        
                    case .pieChart:
                        outcomeDistributionChart
                            .frame(height: 250)
                            .padding(.horizontal)
                        
                    case .positivityScore:
                        positivityScoreView
                            .frame(height: 250)
                            .padding(.horizontal)
                    }
                    
                    // Insight message for the selected chart
                    Text(getChartMessage())
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
    
    // MARK: - Chart Components
    
    // Stacked Bar Chart: Expectations vs Reality
    private var outcomeComparisonChart: some View {
        Chart {
            ForEach(outcomesData) { data in
                BarMark(
                    x: .value("Outcome", data.outcomeType.displayName),
                    y: .value("Count", animateCharts ? data.expectedCount : 0)
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
                    y: .value("Count", animateCharts ? data.actualCount : 0)
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
        .accessibilityLabel("Bar chart comparing expected vs. actual outcomes")
    }
    
    // Line Chart: Fear Accuracy Trend
    private var fearAccuracyTrendChart: some View {
        Chart {
            ForEach(trendData) { data in
                LineMark(
                    x: .value("Month", data.month),
                    y: .value("Accuracy %", animateCharts ? data.accuracyPercentage : 0)
                )
                .symbol(Circle())
                .symbolSize(animateCharts ? 40 : 0)
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
        .accessibilityLabel("Line chart showing improvement in prediction accuracy over time")
    }
    
    // Pie Chart: Outcome Distribution
    private var outcomeDistributionChart: some View {
        let actualOutcomes = outcomesData.filter { $0.actualCount > 0 }
        
        return Chart(actualOutcomes) { data in
            SectorMark(
                angle: .value("Count", animateCharts ? data.actualCount : 0),
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
                        Text("\(data.actualCount)")
                            .font(.caption2)
                    }
                    .foregroundColor(.white)
                    .shadow(radius: 1)
                }
            }
        }
        .accessibilityLabel("Pie chart showing distribution of actual outcomes")
    }
    
    // Positivity Score Gauge
    private var positivityScoreView: some View {
        VStack {
            ZStack {
                Circle()
                    .trim(from: 0, to: 1)
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: [.red, .orange, .yellow, .green, .blue, .purple]),
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(90))
                    .opacity(0.2)
                
                Circle()
                    .trim(from: 0, to: animateCharts ? positivityScore / 100 : 0)
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: [.red, .orange, .yellow, .green, .blue, .purple]),
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(90))
                
                VStack(spacing: 8) {
                    Text("\(Int(positivityScore))")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(getScoreColor(score: positivityScore))
                    
                    Text(getScoreDescription(score: positivityScore))
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }
        }
        .accessibilityLabel("Positivity score gauge showing \(Int(positivityScore)) points")
    }
    
    // Insight Card
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
    
    // MARK: - Helper Methods
    
    private func getChartMessage() -> String {
        switch selectedChartType {
        case .stackedBar:
            return AnalyticsManager.getPositiveMessage(for: "stackedBar")
        case .trendLine:
            return AnalyticsManager.getPositiveMessage(for: "trendLine")
        case .pieChart:
            return AnalyticsManager.getPositiveMessage(for: "pieChart")
        case .positivityScore:
            return AnalyticsManager.getPositiveMessage(for: "positivityScore")
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
}

#Preview {
    InsightsChartView(viewModel: ThoughtViewModel(dataStore: DataStore()))
}