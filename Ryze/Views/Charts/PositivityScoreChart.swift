//
//  PositivityScoreChart.swift
//  Ryze
//
//  Created for Ryze app on 13/05/2025.
//

import SwiftUI

struct PositivityScoreChart: View {
    let thoughts: [Thought]
    let animate: Bool
    
    @State private var animationProgress: Double = 0.0
    
    init(thoughts: [Thought], animate: Bool = true) {
        self.thoughts = thoughts
        self.animate = animate
    }
    
    // Computed positivity score
    private var positivityScore: Double {
        ChartDataProvider.calculatePositivityScore(thoughts: thoughts)
    }
    
    // Description based on score
    private var scoreDescription: String {
        switch positivityScore {
        case 0..<30: return "Worse than expected"
        case 30..<50: return "Slightly worse than expected"
        case 50..<70: return "Matches expectations"
        case 70..<90: return "Better than expected"
        default: return "Much better than expected"
        }
    }
    
    // Color based on score
    private var scoreColor: Color {
        switch positivityScore {
        case 0..<30: return .red
        case 30..<50: return .orange
        case 50..<70: return .yellow
        case 70..<90: return .green
        default: return .blue
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if thoughts.filter({ $0.isResolved }).isEmpty {
                // Placeholder when no data is available
                noDataPlaceholder
            } else {
                // Title and description
                VStack(alignment: .leading, spacing: 4) {
                    Text("Positivity Score")
                        .font(.headline)
                    
                    Text("This represents your brain's evolving relationship with uncertainty")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Centered gauge view
                positivityScoreGauge
                    .frame(height: 250)
                    .padding(.vertical)
                
                // Score explanation
                VStack(alignment: .leading, spacing: 8) {
                    Text("Understanding Your Score")
                        .font(.subheadline)
                        .padding(.top, 4)
                    
                    Text(getScoreExplanation())
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal)
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
    
    private var positivityScoreGauge: some View {
        GeometryReader { geometry in
            let centerX = geometry.size.width / 2
            let centerY = geometry.size.height / 2
            let radius = min(centerX, centerY) - 20
            
            ZStack {
                // Background track
                Circle()
                    .trim(from: 0, to: 1)
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: [.red, .orange, .yellow, .green, .blue, .purple]),
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                    .frame(width: radius * 2, height: radius * 2)
                    .position(x: centerX, y: centerY)
                    .opacity(0.2)
                
                // Progress track
                Circle()
                    .trim(from: 0, to: animationProgress * (positivityScore / 100))
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: [.red, .orange, .yellow, .green, .blue, .purple]),
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                    .frame(width: radius * 2, height: radius * 2)
                    .position(x: centerX, y: centerY)
                    .rotationEffect(.degrees(-90))
                
                // Center score display
                VStack(spacing: 8) {
                    Text("\(Int(positivityScore * animationProgress))")
                        .font(.system(size: 60, weight: .bold))
                        .foregroundColor(scoreColor)
                        .contentTransition(.numericText())
                    
                    Text(scoreDescription)
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .position(x: centerX, y: centerY)
            }
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(1, contentMode: .fit)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Positivity score gauge showing \(Int(positivityScore)) points")
        .accessibilityValue(scoreDescription)
    }
    
    private var noDataPlaceholder: some View {
        VStack(spacing: 20) {
            Image(systemName: "gauge.medium")
                .font(.system(size: 40))
                .foregroundColor(.secondary.opacity(0.6))
            
            Text("No positivity score available yet")
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
    
    // MARK: - Helper Methods
    
    private func getScoreExplanation() -> String {
        switch positivityScore {
        case 0..<30:
            return "Your score suggests that outcomes have generally been worse than you expected. This may indicate a pattern of optimism or could reflect a truly challenging period. Remember that difficult times are temporary."
        case 30..<50:
            return "Your score shows that reality has been slightly less positive than your expectations. This awareness can help you develop more calibrated predictions while maintaining hope."
        case 50..<70:
            return "Your score indicates that your expectations generally match reality. This balance reflects a healthy and realistic outlook on life's uncertainties."
        case 70..<90:
            return "Your score reveals that outcomes are frequently better than you predict. This pattern suggests you may tend toward catastrophic thinking that isn't matching your actual experiences."
        default:
            return "Your score shows a significant positive gap between expectations and reality. Your mind appears to consistently prepare for worse outcomes than what actually occurs."
        }
    }
}

#Preview {
    PositivityScoreChart(thoughts: [])
        .padding()
}