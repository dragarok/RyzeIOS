//
//  ExpectationVsRealityChart.swift
//  Ryze
//
//  Created for Ryze app on 13/05/2025.
//

import SwiftUI
import Charts

struct ExpectationVsRealityChart: View {
    let thoughts: [Thought]
    let animate: Bool
    
    @State private var animationProgress: Double = 0.0
    
    init(thoughts: [Thought], animate: Bool = true) {
        self.thoughts = thoughts
        self.animate = animate
    }
    
    // Computed chart data
    private var chartData: [ExpectationToRealityData] {
        ChartDataProvider.generateExpectationToRealityData(thoughts: thoughts)
    }
    
    // Flattened data structure for the chart
    private var flattenedChartData: [(expected: String, actual: String, count: Int, color: Color)] {
        var result: [(expected: String, actual: String, count: Int, color: Color)] = []
        for data in chartData {
            for outcome in data.actualOutcomes {
                result.append((
                    expected: data.expectedType.displayName,
                    actual: outcome.outcomeType.displayName,
                    count: outcome.count,
                    color: outcome.outcomeType.color
                ))
            }
        }
        return result
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if chartData.isEmpty {
                // Placeholder when no data is available
                noDataPlaceholder
            } else {
                // Title and description
                VStack(alignment: .leading, spacing: 4) {
                    Text("Expectations vs. Reality")
                        .font(.headline)
                    
                    Text("Showing what actually happened when you expected each outcome")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Vertical stacked bar chart
                verticalStackedBarChart
                
                // Legend
                outcomeColorLegend
            }
        }
        .onAppear {
            if animate {
                withAnimation(.easeInOut(duration: 1.0)) {
                    animationProgress = 1.0
                }
            } else {
                animationProgress = 1.0
            }
        }
    }
    
    // MARK: - Chart Components
    
    private var verticalStackedBarChart: some View {
        Chart(flattenedChartData, id: \.actual) { data in
            BarMark(
                x: .value("Expected", data.expected),
                y: .value("Count", Double(data.count) * animationProgress)
            )
            .foregroundStyle(data.color)
            .position(by: .value("Actual", data.actual))
            .annotation(position: .top) {
                if data.count > 0 && animationProgress > 0.9 {
                    Text("\(data.count)")
                        .font(.caption2.bold())
                        .foregroundStyle(.secondary)
                }
            }
        }
        .chartForegroundStyleScale { (value: String) in
            if let outcomeType = OutcomeType.allCases.first(where: { $0.displayName == value }) {
                return outcomeType.color
            }
            return .gray
        }
        .chartLegend(.hidden) // We'll create our own custom legend
        .chartXAxis {
            AxisMarks { _ in
                AxisValueLabel()
                AxisGridLine()
            }
        }
        .chartYAxis {
            AxisMarks { _ in
                AxisGridLine()
                AxisTick()
                AxisValueLabel()
            }
        }
        .frame(height: 300)
        .padding(.vertical)
    }
    
    private var outcomeColorLegend: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Actual Outcomes")
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack(spacing: 12) {
                ForEach(OutcomeType.allCases) { outcomeType in
                    HStack(spacing: 4) {
                        Circle()
                            .fill(outcomeType.color)
                            .frame(width: 10, height: 10)
                        
                        Text(outcomeType.displayName)
                            .font(.caption2)
                    }
                }
            }
        }
        .padding(.horizontal, 4)
    }
    
    private var noDataPlaceholder: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 40))
                .foregroundColor(.secondary.opacity(0.6))
            
            Text("No data available yet")
                .font(.headline)
                .foregroundColor(.secondary)
                
            Text("Resolve thoughts to see how your expectations compare with reality")
                .font(.caption)
                .foregroundColor(.secondary.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, minHeight: 200)
        .padding()
    }
}

#Preview {
    ExpectationVsRealityChart(thoughts: [])
        .padding()
}
