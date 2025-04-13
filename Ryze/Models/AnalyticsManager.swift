//
//  AnalyticsManager.swift
//  Ryze
//
//  Created for Ryze app on 13/04/2025.
//

import SwiftUI
import Foundation

// Struct to represent data for stacked bar chart
struct OutcomeComparisonData: Identifiable {
    var id = UUID()
    var outcomeType: OutcomeType
    var expectedCount: Int
    var actualCount: Int
}

// Struct to represent data for trend line chart
struct FearAccuracyData: Identifiable {
    var id = UUID()
    var month: String
    var accuracyPercentage: Double
}

// Struct to hold insight card data
struct InsightCard: Identifiable {
    var id = UUID()
    var title: String
    var description: String
    var icon: String
    var color: Color
}

// Class to manage analytics data processing
class AnalyticsManager {
    
    // MARK: - Outcome Comparison Chart Data
    
    static func generateOutcomeComparisonData(thoughts: [Thought]) -> [OutcomeComparisonData] {
        var data: [OutcomeComparisonData] = []
        
        // Only include resolved thoughts
        let resolvedThoughts = thoughts.filter { $0.isResolved && $0.actualOutcomeType != nil }
        
        // Count expected and actual outcomes for each outcome type
        for outcomeType in OutcomeType.allCases {
            let expectedCount = resolvedThoughts.filter { $0.expectedOutcomeType == outcomeType }.count
            let actualCount = resolvedThoughts.filter { $0.actualOutcomeType == outcomeType }.count
            
            data.append(OutcomeComparisonData(
                outcomeType: outcomeType,
                expectedCount: expectedCount,
                actualCount: actualCount
            ))
        }
        
        return data
    }
    
    // MARK: - Fear Accuracy Over Time
    
    static func generateFearAccuracyData(thoughts: [Thought]) -> [FearAccuracyData] {
        var data: [FearAccuracyData] = []
        
        // Only include resolved thoughts
        let resolvedThoughts = thoughts.filter { $0.isResolved && $0.actualOutcomeType != nil && $0.expectedOutcomeType != nil }
        
        // Group thoughts by month
        let calendar = Calendar.current
        let groupedByMonth = Dictionary(grouping: resolvedThoughts) { thought in
            let components = calendar.dateComponents([.year, .month], from: thought.createdAt)
            return calendar.date(from: components)!
        }
        
        // Sort months chronologically
        let sortedMonths = groupedByMonth.keys.sorted()
        
        // Calculate accuracy for each month
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM yyyy"
        
        for month in sortedMonths {
            if let thoughtsInMonth = groupedByMonth[month] {
                // Calculate accuracy as percentage of thoughts where expected outcome category >= actual outcome category
                var accurateCount = 0
                
                for thought in thoughtsInMonth {
                    if let expectedType = thought.expectedOutcomeType,
                       let actualType = thought.actualOutcomeType {
                        
                        // Count as accurate if reality was same or better than feared
                        // We convert enum to index to compare (worst = 0, best = 5)
                        let expectedIndex = OutcomeType.allCases.firstIndex(of: expectedType) ?? 0
                        let actualIndex = OutcomeType.allCases.firstIndex(of: actualType) ?? 0
                        
                        // Higher index means better outcome
                        if actualIndex >= expectedIndex {
                            accurateCount += 1
                        }
                    }
                }
                
                let accuracyPercentage = Double(accurateCount) / Double(thoughtsInMonth.count) * 100.0
                
                data.append(FearAccuracyData(
                    month: dateFormatter.string(from: month),
                    accuracyPercentage: accuracyPercentage
                ))
            }
        }
        
        return data
    }
    
    // MARK: - Positivity Score Calculation
    
    static func calculatePositivityScore(thoughts: [Thought]) -> Double {
        // Only include resolved thoughts
        let resolvedThoughts = thoughts.filter { $0.isResolved && $0.actualOutcomeType != nil && $0.expectedOutcomeType != nil }
        
        if resolvedThoughts.isEmpty {
            return 0.0
        }
        
        var totalImprovementPoints = 0.0
        
        for thought in resolvedThoughts {
            if let expectedType = thought.expectedOutcomeType,
               let actualType = thought.actualOutcomeType {
                
                // Convert enum to index for comparison
                let expectedIndex = OutcomeType.allCases.firstIndex(of: expectedType) ?? 0
                let actualIndex = OutcomeType.allCases.firstIndex(of: actualType) ?? 0
                
                // Calculate improvement points
                // +1 for each step better than expected, +0 for matching, negative for worse
                let improvement = Double(actualIndex - expectedIndex)
                totalImprovementPoints += improvement
            }
        }
        
        // Normalize score between 0 and 100
        // 100 means you consistently had better outcomes than expected
        // 50 means outcomes matched expectations on average
        // 0 means consistently worse outcomes than expected
        let maxPossibleImprovement = Double(resolvedThoughts.count) * 5.0  // Maximum 5 steps improvement per thought
        let normalizedScore = 50.0 + (totalImprovementPoints / maxPossibleImprovement) * 50.0
        
        // Clamp score between 0 and 100
        return min(max(normalizedScore, 0.0), 100.0)
    }
    
    // MARK: - Insights Generation
    
    static func generateInsights(thoughts: [Thought]) -> [InsightCard] {
        var insights: [InsightCard] = []
        
        // Only include resolved thoughts
        let resolvedThoughts = thoughts.filter { $0.isResolved && $0.actualOutcomeType != nil && $0.expectedOutcomeType != nil }
        
        if resolvedThoughts.isEmpty {
            // No resolved thoughts yet
            insights.append(InsightCard(
                title: "Begin Your Journey",
                description: "Start tracking your thoughts to reveal patterns between expectations and reality.",
                icon: "sparkles",
                color: .blue
            ))
            return insights
        }
        
        // Calculate percentage of thoughts where outcome was better than expected
        var betterThanExpectedCount = 0
        
        for thought in resolvedThoughts {
            if let expectedType = thought.expectedOutcomeType,
               let actualType = thought.actualOutcomeType {
                
                let expectedIndex = OutcomeType.allCases.firstIndex(of: expectedType) ?? 0
                let actualIndex = OutcomeType.allCases.firstIndex(of: actualType) ?? 0
                
                if actualIndex > expectedIndex {
                    betterThanExpectedCount += 1
                }
            }
        }
        
        let betterThanExpectedPercentage = Double(betterThanExpectedCount) / Double(resolvedThoughts.count) * 100.0
        
        // Generate insights based on data
        if betterThanExpectedPercentage >= 70 {
            insights.append(InsightCard(
                title: "Positive Reality",
                description: "In \(Int(betterThanExpectedPercentage))% of your thoughts, reality turned out better than you expected. Your mind may be overestimating negative outcomes.",
                icon: "sun.max",
                color: .orange
            ))
        } else if betterThanExpectedPercentage >= 50 {
            insights.append(InsightCard(
                title: "Balanced Perspective",
                description: "Reality has been better than you expected in about half of your recorded thoughts. You're developing a balanced outlook.",
                icon: "scale.3d",
                color: .green
            ))
        } else {
            insights.append(InsightCard(
                title: "Realistic Concerns",
                description: "Many of your concerns have materialized as expected. While some fears are valid, continue to distinguish between helpful caution and limiting anxiety.",
                icon: "eye",
                color: .purple
            ))
        }
        
        // Add additional insight based on thought patterns
        if resolvedThoughts.count >= 5 {
            // Check for catastrophic thinking pattern (consistently expecting worst outcomes)
            let worstExpectations = resolvedThoughts.filter { $0.expectedOutcomeType == .worst || $0.expectedOutcomeType == .worse }.count
            let worstExpectationPercentage = Double(worstExpectations) / Double(resolvedThoughts.count) * 100.0
            
            if worstExpectationPercentage >= 70 {
                insights.append(InsightCard(
                    title: "Catastrophic Thinking Pattern",
                    description: "You tend to expect the worst outcomes in \(Int(worstExpectationPercentage))% of situations. Consider challenging these thoughts when they arise.",
                    icon: "exclamationmark.triangle",
                    color: .red
                ))
            }
        }
        
        // Add encouragement insight
        let positivityMessages = [
            "Your commitment to self-awareness is creating lasting change.",
            "Each thought you examine breaks the cycle of fear-based thinking.",
            "Notice how your perspective shifts as you continue this practice.",
            "You're building resilience with every thought you process.",
            "This journey of awareness is already changing how you see challenges."
        ]
        
        insights.append(InsightCard(
            title: "Growth Mindset",
            description: positivityMessages.randomElement() ?? positivityMessages[0],
            icon: "leaf",
            color: .green
        ))
        
        return insights
    }
    
    // MARK: - Positive Messages for Charts
    
    static func getPositiveMessage(for chartType: String) -> String {
        let messagesForCharts: [String: [String]] = [
            "stackedBar": [
                "Notice the gap between what you expected and what actually happened.",
                "Our minds often prepare us for worse outcomes than reality delivers.",
                "This chart shows the difference between fear and reality.",
                "With each data point, you're building a more accurate view of life."
            ],
            "trendLine": [
                "Watch how your ability to predict outcomes improves over time.",
                "This growth reflects your developing emotional intelligence.",
                "Each data point represents a moment of learning and growth.",
                "Your brain is recalibrating expectations based on evidence."
            ],
            "pieChart": [
                "This visualization shows where your outcomes actually landed.",
                "Reality is often more balanced than our fears suggest.",
                "Your experiences create a beautiful tapestry of possibilities.",
                "This pie chart represents the true distribution of your life experiences."
            ],
            "positivityScore": [
                "This score captures your journey from fear toward reality.",
                "Each thought you process helps calibrate your internal compass.",
                "Watch this number grow as you continue your practice.",
                "This represents your brain's evolving relationship with uncertainty."
            ]
        ]
        
        // Return a random message for the specified chart type
        if let messages = messagesForCharts[chartType], !messages.isEmpty {
            return messages.randomElement()!
        }
        
        // Default message
        return "Each data point represents a moment of awareness and growth."
    }
}