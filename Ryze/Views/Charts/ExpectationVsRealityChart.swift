import SwiftUI
import Charts

struct ExpectationVsRealityChart: View {
    let thoughts: [Thought]
    let animate: Bool
    
    @State private var animationProgress: Double = 0.0
    @Environment(\.colorScheme) private var colorScheme
    
    init(thoughts: [Thought], animate: Bool = true) {
        self.thoughts = thoughts
        self.animate = animate
    }
    
    private var chartData: [ExpectationToRealityData] {
        ChartDataProvider.generateExpectationToRealityData(thoughts: thoughts)
    }
    
    private var flattenedChartData: [(expected: String, actual: String, count: Int, color: Color)] {
        var result: [(expected: String, actual: String, count: Int, color: Color)] = []
        for data in chartData {
            for outcome in data.actualOutcomes {
                result.append((
                    expected: data.expectedType.displayName,
                    actual: outcome.outcomeType.displayName,
                    count: outcome.count,
                    color: outcome.outcomeType.refinedColor // Using the refined color
                ))
            }
        }
        return result
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 28) {
            if chartData.isEmpty {
                noDataPlaceholder
            } else {
                // Title and description with consistent styling
                VStack(alignment: .leading, spacing: 6) {
                    Text("Expectations vs. Reality")
                        .font(.title3)
                        .fontWeight(.medium)
                    
                    Text("Showing what actually happened when you expected each outcome")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // Refined bar chart
                refinedBarChart
                
                // Outcome legend with consistent styling
                outcomeLegend
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
    
    private var refinedBarChart: some View {
        Chart(flattenedChartData, id: \.actual) { data in
            BarMark(
                x: .value("Expected", data.expected),
                y: .value("Count", Double(data.count) * animationProgress)
            )
            .cornerRadius(4)
            .foregroundStyle(data.color)
            .position(by: .value("Actual", data.actual))
            .annotation(position: .top) {
                if data.count > 0 && animationProgress > 0.9 {
                    Text("\(data.count)")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .chartForegroundStyleScale { (value: String) in
            if let outcomeType = OutcomeType.allCases.first(where: { $0.displayName == value }) {
                return outcomeType.refinedColor
            }
            return .gray
        }
        .chartLegend(.hidden)
        .chartXAxis {
            AxisMarks { _ in
                AxisValueLabel()
                    .font(.callout)
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
            }
        }
        .chartYAxis {
            AxisMarks { _ in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                AxisTick(stroke: StrokeStyle(lineWidth: 0.5))
                AxisValueLabel()
                    .font(.callout)
            }
        }
        .frame(height: 300)
        .padding(.vertical, 8)
    }
    
    private var outcomeLegend: some View {
        VStack(spacing: 12) {
            Text("Legend")
                .font(.subheadline)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // More compact layout with grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(OutcomeType.allCases.sorted(by: { $0.rawValue < $1.rawValue }), id: \.self) { type in
                    HStack(spacing: 8) {
                        Circle()
                            .fill(type.refinedColor)
                            .frame(width: 8, height: 8)
                        
                        Text(type.displayName)
                            .font(.caption)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Spacer(minLength: 0)
                    }
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
    
    private var noDataPlaceholder: some View {
        VStack(spacing: 24) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 48))
                .foregroundColor(.secondary.opacity(0.6))
            
            VStack(spacing: 8) {
                Text("No data available yet")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("Resolve thoughts to see how your expectations compare with reality")
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