//
//  OutcomeDistributionChart.swift
//  Ryze
//
//  Created for Ryze app on 13/05/2025.
//

import SwiftUI
import Charts

struct OutcomeDistributionChart: View {
    let thoughts: [Thought]
    let animate: Bool
    
    @State private var animationProgress: Double = 0.0
    @State private var selectedChartType: ChartDisplayType = .sideBySide
    
    enum ChartDisplayType: String, CaseIterable, Identifiable {
        case sideBySide = "Side by Side"
        case overlapping = "Overlapping"
        
        var id: Self { self }
    }
    
    init(thoughts: [Thought], animate: Bool = true) {
        self.thoughts = thoughts
        self.animate = animate
    }
    
    // Computed chart data
    private var chartData: [PieChartData] {
        ChartDataProvider.generatePieChartData(thoughts: thoughts)
    }
    
    // Helper to check if we have data
    private var hasData: Bool {
        !chartData.isEmpty && chartData.contains(where: { $0.expectedCount > 0 || $0.actualCount > 0 })
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if !hasData {
                // Placeholder when no data is available
                noDataPlaceholder
            } else {
                // Title and description
                VStack(alignment: .leading, spacing: 4) {
                    Text("Outcome Distribution")
                        .font(.headline)
                    
                    Text("Compare your expected outcomes with what actually happened")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Chart type toggle
                Picker("Display", selection: $selectedChartType) {
                    ForEach(ChartDisplayType.allCases) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                // Distribution chart based on selected type
                if selectedChartType == .sideBySide {
                    sideBySidePieCharts
                } else {
                    overlappingDonutChart
                }
                
                // Legend
                distributionLegend
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
    
    // Side by Side Pie Charts
    private var sideBySidePieCharts: some View {
        HStack(alignment: .center, spacing: 8) {
            // Expected outcomes pie chart
            VStack {
                Text("Expected")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Chart(chartData.filter { $0.expectedCount > 0 }) { data in
                    SectorMark(
                        angle: .value("Count", Double(data.expectedCount) * animationProgress),
                        innerRadius: .ratio(0.6),
                        angularInset: 1
                    )
                    .cornerRadius(5)
                    .foregroundStyle(data.type.color)
                    .annotation(position: .overlay) {
                        if data.expectedCount > 0 && animationProgress > 0.9 {
                            VStack {
                                Text(data.type.displayName)
                                    .font(.caption)
                                    .bold()
                                
                                Text("\(Int(data.expectedPercentage))%")
                                    .font(.caption2)
                            }
                            .foregroundColor(.white)
                            .shadow(radius: 1)
                        }
                    }
                }
                .frame(height: 150)
            }
            .frame(maxWidth: .infinity)
            
            // Divider
            Rectangle()
                .fill(Color.secondary.opacity(0.3))
                .frame(width: 1)
                .padding(.vertical, 20)
            
            // Actual outcomes pie chart
            VStack {
                Text("Actual")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Chart(chartData.filter { $0.actualCount > 0 }) { data in
                    SectorMark(
                        angle: .value("Count", Double(data.actualCount) * animationProgress),
                        innerRadius: .ratio(0.6),
                        angularInset: 1
                    )
                    .cornerRadius(5)
                    .foregroundStyle(data.type.color)
                    .annotation(position: .overlay) {
                        if data.actualCount > 0 && animationProgress > 0.9 {
                            VStack {
                                Text(data.type.displayName)
                                    .font(.caption)
                                    .bold()
                                
                                Text("\(Int(data.actualPercentage))%")
                                    .font(.caption2)
                            }
                            .foregroundColor(.white)
                            .shadow(radius: 1)
                        }
                    }
                }
                .frame(height: 150)
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
    }
    
    // Overlapping Donut Chart
    private var overlappingDonutChart: some View {
        ZStack {
            // Outer ring (actual outcomes)
            Chart(chartData.filter { $0.actualCount > 0 }) { data in
                SectorMark(
                    angle: .value("Count", Double(data.actualCount) * animationProgress),
                    innerRadius: .ratio(0.6),
                    angularInset: 1
                )
                .cornerRadius(5)
                .foregroundStyle(data.type.color)
            }
            
            // Inner ring (expected outcomes)
            Chart(chartData.filter { $0.expectedCount > 0 }) { data in
                SectorMark(
                    angle: .value("Count", Double(data.expectedCount) * animationProgress),
                    innerRadius: .ratio(0.8),
                    angularInset: 1
                )
                .cornerRadius(3)
                .foregroundStyle(data.type.color.opacity(0.6))
            }
            
            // Center label
            VStack(spacing: 4) {
                Text("Expected")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                Text("vs")
                    .font(.caption2.bold())
                    .foregroundColor(.primary)
                
                Text("Actual")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(8)
            .background(
                Circle()
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
            )
        }
        .frame(height: 250)
        .padding()
    }
    
    // Legend for the distribution charts
    private var distributionLegend: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Outcome Types")
                .font(.caption)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 6) {
                ForEach(chartData) { data in
                    HStack(spacing: 12) {
                        // Color indicator
                        Circle()
                            .fill(data.type.color)
                            .frame(width: 10, height: 10)
                        
                        // Outcome type
                        Text(data.type.displayName)
                            .font(.caption2)
                        
                        Spacer()
                        
                        // Expected percentage
                        HStack(spacing: 2) {
                            Text("Expected:")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            
                            Text("\(Int(data.expectedPercentage))%")
                                .font(.caption2.bold())
                        }
                        
                        // Actual percentage
                        HStack(spacing: 2) {
                            Text("Actual:")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            
                            Text("\(Int(data.actualPercentage))%")
                                .font(.caption2.bold())
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
    }
    
    private var noDataPlaceholder: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.pie.fill")
                .font(.system(size: 40))
                .foregroundColor(.secondary.opacity(0.6))
            
            Text("No distribution data available yet")
                .font(.headline)
                .foregroundColor(.secondary)
                
            Text("Resolve thoughts to see how your expected outcomes compare with reality")
                .font(.caption)
                .foregroundColor(.secondary.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, minHeight: 200)
        .padding()
    }
}

#Preview {
    OutcomeDistributionChart(thoughts: [])
        .padding()
}
