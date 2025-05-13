//
//  FearAccuracyTrendChart.swift
//  Ryze
//
//  Created for Ryze app on 13/05/2025.
//

import SwiftUI
import Charts

struct FearAccuracyTrendChart: View {
    let thoughts: [Thought]
    let animate: Bool
    
    @State private var animationProgress: Double = 0.0
    @State private var showCumulative: Bool = false
    
    init(thoughts: [Thought], animate: Bool = true) {
        self.thoughts = thoughts
        self.animate = animate
    }
    
    // Computed chart data
    private var trendData: [FearAccuracyData] {
        ChartDataProvider.generateFearAccuracyData(thoughts: thoughts)
    }
    
    // Calculated average accuracy
    private var averageAccuracy: Double {
        if trendData.isEmpty {
            return 0.0
        }
        let sum = trendData.reduce(0.0) { $0 + $1.accuracyPercentage }
        return sum / Double(trendData.count)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if trendData.isEmpty {
                // Placeholder when no data is available
                noDataPlaceholder
            } else {
                // Title and description
                VStack(alignment: .leading, spacing: 4) {
                    Text("Fear Accuracy Trend")
                        .font(.headline)
                    
                    Text("Track how your ability to predict outcomes improves over time")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Toggle for view type
                Picker("View", selection: $showCumulative) {
                    Text("Monthly").tag(false)
                    Text("Cumulative").tag(true)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                // Line chart
                accuracyTrendChart
                    .frame(height: 250)
                    .padding(.vertical)
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
    
    private var accuracyTrendChart: some View {
        Chart {
            ForEach(trendData) { data in
                LineMark(
                    x: .value("Month", data.month),
                    y: .value("Accuracy %", data.accuracyPercentage * animationProgress)
                )
                .symbol(Circle())
                .symbolSize(animationProgress > 0.9 ? 40 : 0)
                .lineStyle(StrokeStyle(lineWidth: 3))
                .foregroundStyle(Gradient(colors: [.blue, .purple]))
                .interpolationMethod(.catmullRom)
                .annotation(position: .top) {
                    if animationProgress > 0.9 {
                        Text("\(Int(data.accuracyPercentage))%")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            // Add a single reference line at 50%
            RuleMark(
                y: .value("Baseline", 50)
            )
            .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
            .foregroundStyle(.gray.opacity(0.5))
            .annotation(alignment: .leading, spacing: 0) {
                Text("50%")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 4)
                    .background(Color(.systemBackground).opacity(0.8))
            }
        }
        .chartYScale(domain: 0...100)
        .chartYAxis {
            AxisMarks(position: .leading, values: [0, 25, 50, 75, 100]) { value in
                if let doubleValue = value.as(Double.self), doubleValue != 50 { // Skip 50% here to avoid duplication
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel {
                        Text("\(Int(doubleValue))%")
                            .font(.caption)
                    }
                } else {
                    AxisGridLine()
                    AxisTick()
                }
            }
        }
        .chartXAxis {
            AxisMarks { _ in
                AxisValueLabel()
                AxisGridLine()
            }
        }
    }
    
    private var noDataPlaceholder: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 40))
                .foregroundColor(.secondary.opacity(0.6))
            
            Text("No trend data available yet")
                .font(.headline)
                .foregroundColor(.secondary)
                
            Text("Track thoughts over time to see how your prediction accuracy improves")
                .font(.caption)
                .foregroundColor(.secondary.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, minHeight: 200)
        .padding()
    }
}

#Preview {
    FearAccuracyTrendChart(thoughts: [])
        .padding()
}