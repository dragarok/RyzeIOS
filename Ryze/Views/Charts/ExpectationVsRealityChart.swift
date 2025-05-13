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
                    color: outcome.outcomeType.color
                ))
            }
        }
        return result
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) { // Reduced spacing for compactness
            if chartData.isEmpty {
                noDataPlaceholder
            } else {
                VStack(alignment: .leading, spacing: 2) { // Reduced spacing
                    Text("Expectations vs. Reality")
                        .font(.subheadline) // Smaller font for title
                    
                    Text("Showing what actually happened when you expected each outcome")
                        .font(.caption2) // Smaller font for subtitle
                        .foregroundColor(.secondary)
                }
                
                verticalStackedBarChart
                
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
                        .font(.caption2.bold()) // Already small, kept as is
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
        .chartLegend(.hidden)
        .chartXAxis {
            AxisMarks { _ in
                AxisValueLabel()
                    .font(.caption2) // Smaller font for X-axis labels
                AxisGridLine()
            }
        }
        .chartYAxis {
            AxisMarks { _ in
                AxisGridLine()
                AxisTick()
                AxisValueLabel()
                    .font(.caption2) // Smaller font for Y-axis labels
            }
        }
        .frame(height: 300)
        .padding(.vertical)
    }
    
    private var outcomeColorLegend: some View {
        VStack(alignment: .leading, spacing: 4) { // Reduced spacing
            Text("Actual Outcomes")
                .font(.caption2) // Keep small font for the title
                .foregroundColor(.secondary)
            
            // Single row with smaller items to fit all in one line
            HStack(spacing: 8) { // Reduced spacing between items
                ForEach(OutcomeType.allCases) { outcomeType in
                    HStack(spacing: 4) { // Reduced spacing between circle and text
                        Circle()
                            .fill(outcomeType.color)
                            .frame(width: 10, height: 10) // Smaller circle
                        
                        Text(outcomeType.displayName)
                            .font(.system(size: 8)) // Even smaller font for legend items
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .center) // Center the legend under the chart
        }
        .padding(.horizontal, 4)
    }
    
    private var noDataPlaceholder: some View {
        VStack(spacing: 16) { // Reduced spacing
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 36)) // Slightly smaller icon
                .foregroundColor(.secondary.opacity(0.6))
            
            Text("No data available yet")
                .font(.subheadline) // Smaller font for placeholder title
                .foregroundColor(.secondary)
                
            Text("Resolve thoughts to see how your expectations compare with reality")
                .font(.caption2) // Smaller font for placeholder subtitle
                .foregroundColor(.secondary.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, minHeight: 200)
        .padding()
    }
}

// Custom FlowLayout to wrap items into multiple rows
struct FlowLayout: Layout {
    var alignment: HorizontalAlignment
    var spacing: CGFloat
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        let maxWidth = proposal.width ?? 0
        var totalHeight: CGFloat = 0
        var totalWidth: CGFloat = 0
        var lineWidth: CGFloat = 0
        var lineHeight: CGFloat = 0
        var itemsInCurrentRow = 0
        
        // Split into roughly equal rows (e.g., 3 items per row for 6 items)
        let itemsPerRow = subviews.count / 2 // For 6 items, this is 3 per row
        
        for (index, size) in sizes.enumerated() {
            if itemsInCurrentRow >= itemsPerRow && lineWidth > 0 {
                totalWidth = max(totalWidth, lineWidth - spacing)
                totalHeight += lineHeight + spacing
                lineWidth = 0
                lineHeight = 0
                itemsInCurrentRow = 0
            }
            lineWidth += size.width + spacing
            lineHeight = max(lineHeight, size.height)
            itemsInCurrentRow += 1
        }
        
        totalWidth = max(totalWidth, lineWidth - spacing)
        totalHeight += lineHeight
        
        return CGSize(width: maxWidth, height: totalHeight)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        let itemsPerRow = subviews.count / 2 // For 6 items, this is 3 per row
        var lineWidth: CGFloat = 0
        var lineHeight: CGFloat = 0
        var y: CGFloat = bounds.minY
        var x: CGFloat = bounds.minX
        var itemsInCurrentRow = 0
        
        // Calculate the total width of each row to center them
        var rowWidths: [CGFloat] = []
        var currentRowWidth: CGFloat = 0
        var currentRowItems = 0
        
        for size in sizes {
            if currentRowItems >= itemsPerRow && currentRowWidth > 0 {
                rowWidths.append(currentRowWidth - spacing)
                currentRowWidth = 0
                currentRowItems = 0
            }
            currentRowWidth += size.width + spacing
            currentRowItems += 1
        }
        rowWidths.append(currentRowWidth - spacing)
        
        var rowIndex = 0
        for (index, subview) in subviews.enumerated() {
            let size = sizes[index]
            
            if itemsInCurrentRow >= itemsPerRow && lineWidth > 0 {
                y += lineHeight + spacing
                x = bounds.minX
                lineWidth = 0
                lineHeight = 0
                itemsInCurrentRow = 0
                rowIndex += 1
            }
            
            // Center the row
            let rowWidth = rowWidths[rowIndex]
            let position: CGFloat
            switch alignment {
            case .center:
                position = bounds.minX + (bounds.width - rowWidth) / 2 + lineWidth
            case .leading:
                position = x
            case .trailing:
                position = bounds.maxX - rowWidth - lineWidth
            default:
                position = x
            }
            
            subview.place(
                at: CGPoint(x: position, y: y + (lineHeight - size.height) / 2),
                proposal: ProposedViewSize(width: size.width, height: size.height)
            )
            
            x += size.width + spacing
            lineWidth += size.width + spacing
            lineHeight = max(lineHeight, size.height)
            itemsInCurrentRow += 1
        }
    }
}

#Preview {
    ExpectationVsRealityChart(thoughts: [])
        .padding()
}
