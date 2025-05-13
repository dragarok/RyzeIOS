import SwiftUI
import Charts

struct FearAccuracyTrendChart: View {
    let thoughts: [Thought]
    let animate: Bool

    @State private var animationProgress: Double = 0.0

    init(thoughts: [Thought], animate: Bool = true) {
        self.thoughts = thoughts
        self.animate = animate
    }

    // Computed chart data
    private var trendData: [FearAccuracyData] {
        ChartDataProvider.generateFearAccuracyData(thoughts: thoughts)
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
        }
        .chartYScale(domain: 0...100)
        .chartYAxis {
            AxisMarks(position: .leading, values: [0, 25, 50, 75, 100]) { value in
                AxisGridLine()
                AxisTick()
                AxisValueLabel {
                    if let doubleValue = value.as(Double.self) {
                        Text("\(Int(doubleValue))%")
                            .font(.caption) // Consistent font for all Y-axis labels
                    }
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
