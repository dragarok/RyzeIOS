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
    let showHeader: Bool
    
    @State private var animationProgress: Double = 0.0
    @Environment(\.colorScheme) private var colorScheme
    
    init(thoughts: [Thought], animate: Bool = true, showHeader: Bool = true) {
        self.thoughts = thoughts
        self.animate = animate
        self.showHeader = showHeader
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
        VStack(alignment: .leading, spacing: 28) {
            if !hasData {
                // Placeholder when no data is available
                noDataPlaceholder
            } else {
                // Only show title and description if showHeader is true
                if showHeader {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Outcome Distribution")
                            .font(.title3)
                            .fontWeight(.medium)
                        
                        Text("Compare your expected outcomes with what actually happened")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Separate donut charts with legends
                refinedDonutCharts
            }
        }
        .padding(.vertical, 8)
        .onAppear {
            if animate {
                withAnimation(.easeInOut(duration: 1.2)) {
                    animationProgress = 1.0
                }
            } else {
                animationProgress = 1.0
            }
        }
    }
    
    // MARK: - Chart Components
    
    private var refinedDonutCharts: some View {
        VStack(spacing: 32) {
            // Labels row
            HStack(spacing: 0) {
                Text("Expected")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                Text("Actual")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(.horizontal, 16)
            
            // Charts row
            HStack(alignment: .center, spacing: 24) {
                // Expected outcomes donut chart
                ZStack {
                    Chart(chartData.filter { $0.expectedCount > 0 }) { data in
                        SectorMark(
                            angle: .value("Count", Double(data.expectedCount) * animationProgress),
                            innerRadius: .ratio(0.65),
                            angularInset: 1.5
                        )
                        .cornerRadius(4)
                        .foregroundStyle(data.type.refinedColor)
                    }
                }
                .frame(height: 160)
                .frame(maxWidth: .infinity)
                
                // Actual outcomes donut chart
                ZStack {
                    Chart(chartData.filter { $0.actualCount > 0 }) { data in
                        SectorMark(
                            angle: .value("Count", Double(data.actualCount) * animationProgress),
                            innerRadius: .ratio(0.65),
                            angularInset: 1.5
                        )
                        .cornerRadius(4)
                        .foregroundStyle(data.type.refinedColor)
                    }
                }
                .frame(height: 160)
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 8)
            
            // Legend
            VStack(spacing: 12) {
                // Legend title
                Text("Legend")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Legend items in a more compact layout
                VStack(spacing: 6) {
                    ForEach(OutcomeType.allCases.sorted(by: { $0.rawValue < $1.rawValue }), id: \.self) { type in
                        legendItem(for: type)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(UIColor.secondarySystemBackground))
            )
            .padding(.horizontal, 16)
        }
    }
    
    private func legendItem(for type: OutcomeType) -> some View {
        HStack(spacing: 8) {
            Circle()
                .fill(type.refinedColor)
                .frame(width: 8, height: 8)
            
            Text(type.displayName)
                .font(.caption)
                .lineLimit(1)
                .frame(width: 46, alignment: .leading)
            
            // Find the data for this type
            let expectedData = chartData.first(where: { $0.type == type })
            let actualData = chartData.first(where: { $0.type == type })
            
            // Display percentages
            if let expectedPct = expectedData?.expectedPercentage, 
               let actualPct = actualData?.actualPercentage,
               (expectedPct > 0 || actualPct > 0) {
                
                Text("\(Int(expectedPct))% → \(Int(actualPct))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
    
    private var noDataPlaceholder: some View {
        VStack(spacing: 24) {
            Image(systemName: "chart.pie.fill")
                .font(.system(size: 48))
                .foregroundColor(.secondary.opacity(0.6))
            
            VStack(spacing: 8) {
                Text("No distribution data available yet")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("Resolve thoughts to see how your expected outcomes compare with reality")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 240)
        .padding()
    }
}

// Extension to provide refined colors for a more elegant palette
extension OutcomeType {
    var refinedColor: Color {
        switch self {
        case .worst:
            return Color(red: 0.85, green: 0.20, blue: 0.25) // Refined red
        case .worse:
            return Color(red: 0.90, green: 0.42, blue: 0.30) // Refined orange-red
        case .okay:
            return Color(red: 0.95, green: 0.75, blue: 0.25) // Refined gold
        case .good:
            return Color(red: 0.35, green: 0.65, blue: 0.40) // Refined green
        case .better:
            return Color(red: 0.32, green: 0.55, blue: 0.75) // Refined blue
        case .best:
            return Color(red: 0.40, green: 0.30, blue: 0.75) // Refined purple
        }
    }
}

#Preview {
    OutcomeDistributionChart(thoughts: [])
        .padding()
}