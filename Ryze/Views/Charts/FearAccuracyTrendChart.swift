import SwiftUI
import Charts

struct FearAccuracyTrendChart: View {
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
    private var trendData: [FearAccuracyData] {
        ChartDataProvider.generateFearAccuracyData(thoughts: thoughts)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 28) {
            if trendData.isEmpty {
                // Placeholder when no data is available
                noDataPlaceholder
            } else {
                // Only show title and description if showHeader is true
                if showHeader {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Fear Accuracy Trend")
                            .font(.title3)
                            .fontWeight(.medium)

                        Text("Track how your ability to predict outcomes improves over time")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }

                // Refined line chart
                refinedTrendChart
                    .frame(height: 240)
                    .padding(.vertical, 8)
                
                // Add a compact legend
                compactLegend
            }
        }
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

    private var refinedTrendChart: some View {
        Chart {
            ForEach(trendData) { data in
                LineMark(
                    x: .value("Month", data.month),
                    y: .value("Accuracy %", data.accuracyPercentage * animationProgress)
                )
                .symbol(Circle())
                .symbolSize(animationProgress > 0.9 ? 25 : 0)
                .lineStyle(StrokeStyle(lineWidth: 2.5))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.purple.opacity(0.8), .blue.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .interpolationMethod(.catmullRom)
                .annotation(position: .top) {
                    if animationProgress > 0.9 {
                        Text("\(Int(data.accuracyPercentage))%")
                            .font(.callout)
                            .fontWeight(.medium)
                            .foregroundStyle(.primary)
                    }
                }
            }
        }
        .chartYScale(domain: 0...100)
        .chartYAxis {
            AxisMarks(position: .leading, values: [0, 25, 50, 75, 100]) { value in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                AxisTick(stroke: StrokeStyle(lineWidth: 0.5))
                AxisValueLabel {
                    if let doubleValue = value.as(Double.self) {
                        Text("\(Int(doubleValue))%")
                            .font(.callout)
                    }
                }
            }
        }
        .chartXAxis {
            AxisMarks { _ in
                AxisValueLabel()
                    .font(.callout)
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
            }
        }
    }
    
    private var compactLegend: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Legend")
                .font(.subheadline)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 14) {
                legendItem(range: "0-50%", description: "Poor", color: .red)
                legendItem(range: "50-75%", description: "Good", color: .green)
                legendItem(range: "75-100%", description: "Excellent", color: .blue)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.secondarySystemBackground))
        )
        .padding(.horizontal, 16)
    }
    
    private func legendItem(range: String, description: String, color: Color) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            
            VStack(alignment: .leading, spacing: 0) {
                Text(range)
                    .font(.caption)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private func accuracyColor(for percentage: Double) -> Color {
        switch percentage {
        case 0..<50: return .red
        case 50..<75: return .green
        default: return .blue
        }
    }

    private var noDataPlaceholder: some View {
        VStack(spacing: 24) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 48))
                .foregroundColor(.secondary.opacity(0.6))

            VStack(spacing: 8) {
                Text("No trend data available yet")
                    .font(.headline)
                    .foregroundColor(.primary)

                Text("Track thoughts over time to see how your prediction accuracy improves")
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

#Preview {
    FearAccuracyTrendChart(thoughts: [])
        .padding()
}