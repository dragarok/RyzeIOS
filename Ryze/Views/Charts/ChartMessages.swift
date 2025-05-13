//
//  ChartMessages.swift
//  Ryze
//
//  Created for Ryze app on 13/05/2025.
//

import Foundation
import SwiftUI

/// Static class to handle all chart-related messages and descriptions
class ChartMessages {
    
    enum ChartType: String {
        case expectationsVsReality = "Expectations vs. Reality"
        case fearAccuracyTrend = "Fear Accuracy Trend"
        case outcomeDistribution = "Outcome Distribution"
        case positivityScore = "Positivity Score"
    }
    
    // MARK: - Chart Descriptions
    
    static func getChartDescription(for chartType: ChartType) -> String {
        switch chartType {
        case .expectationsVsReality:
            return "This chart shows what actually happened when you expected each outcome, revealing how your predictions compare to reality."
        case .fearAccuracyTrend:
            return "This trend shows how accurately your expectations matched reality over time. Higher percentages mean reality was as good as or better than you expected."
        case .outcomeDistribution:
            return "This visualization compares the distribution of your expected outcomes with what actually happened, showing where reality tends to land."
        case .positivityScore:
            return "Your positivity score measures the gap between your expectations and reality. A higher score means reality consistently exceeds your expectations."
        }
    }
    
    // MARK: - Chart Reflections
    
    static func getReflectionMessage(for chartType: ChartType) -> String {
        // Get a random message from the available options for each chart type
        let reflections = messagesByType[chartType] ?? [defaultMessage]
        return reflections.randomElement() ?? defaultMessage
    }
    
    // Private dictionary of messages by chart type
    private static let messagesByType: [ChartType: [String]] = [
        .expectationsVsReality: [
            "When we compare our expectations to reality, we often find that our fears rarely materialize in the way we imagine. This awareness helps recalibrate our thinking.",
            "Your brain evolved to prepare for the worst as a survival mechanism. This chart helps you see the gap between ancient instincts and modern reality.",
            "Notice any patterns in how you predict outcomes versus what actually happens. This awareness builds your emotional intelligence over time.",
            "The distance between the bars represents the gap between fear and reality. Over time, you may notice this gap shrinking as your predictions become more accurate."
        ],
        
        .fearAccuracyTrend: [
            "As you continue to track your thoughts, notice how your prediction accuracy changes. Many people become more optimistic as they see evidence that outcomes are often better than feared.",
            "This trend line represents your growing ability to distinguish between helpful caution and limiting catastrophic thinking.",
            "Each point on this chart represents a moment of learning - a time when you challenged a fear-based thought and discovered what actually happened.",
            "Watch how your ability to predict outcomes improves over time. This growth reflects your developing emotional intelligence."
        ],
        
        .outcomeDistribution: [
            "This distribution of outcomes shows you the true landscape of your experiences. Our minds tend to remember negative outcomes more strongly, but this chart shows the complete picture.",
            "Looking at this distribution helps counteract 'negativity bias' - our tendency to focus on and remember negative experiences more than positive ones.",
            "This chart represents the actual fabric of your experiences, not filtered through fear or anticipation.",
            "This visualization shows where your outcomes actually landed. Reality is often more balanced than our fears suggest."
        ],
        
        .positivityScore: [
            "Your positivity score isn't about toxic positivity or ignoring real concerns. It's about calibrating your expectations to match reality more accurately.",
            "Think of this score as your brain's operating system gradually receiving updates based on real-world data rather than ancient survival programming.",
            "As this score changes over time, it represents your growing ability to see situations clearly rather than through a lens of fear.",
            "This represents your brain's evolving relationship with uncertainty. Each thought you process helps calibrate your internal compass."
        ]
    ]
    
    // Default message if nothing is found
    private static let defaultMessage = "By tracking your thoughts and outcomes, you're developing greater emotional resilience and a more balanced perspective."
    
    // MARK: - Positivity Score Explanations
    
    static func getScoreExplanation(score: Double) -> String {
        switch score {
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
    
    // MARK: - Score Rating
    
    static func getAccuracyRating(percentage: Double) -> String {
        switch percentage {
        case 0..<20: return "Very Low"
        case 20..<40: return "Low"
        case 40..<60: return "Moderate"
        case 60..<80: return "Good"
        default: return "Excellent"
        }
    }
    
    static func getAccuracyColor(percentage: Double) -> Color {
        switch percentage {
        case 0..<20: return .red
        case 20..<40: return .orange
        case 40..<60: return .yellow
        case 60..<80: return .green
        default: return .blue
        }
    }
    
    static func getScoreColor(score: Double) -> Color {
        switch score {
        case 0..<30: return .red
        case 30..<50: return .orange
        case 50..<70: return .yellow
        case 70..<90: return .green
        default: return .blue
        }
    }
    
    static func getScoreDescription(score: Double) -> String {
        switch score {
        case 0..<30: return "Worse than expected"
        case 30..<50: return "Slightly worse than expected"
        case 50..<70: return "Matches expectations"
        case 70..<90: return "Better than expected"
        default: return "Much better than expected"
        }
    }
}