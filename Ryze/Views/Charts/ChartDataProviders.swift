//
//  ChartDataProviders.swift
//  Ryze
//
//  Created for Ryze app on 13/05/2025.
//

import SwiftUI
import Foundation

// MARK: - Data Structures for Charts

// New data structure for horizontal stacked bar chart
struct ExpectationToRealityData: Identifiable {
    var id = UUID()
    var expectedType: OutcomeType
    var actualOutcomes: [OutcomeCount] // Counts of each actual outcome for this expectation
    var totalCount: Int
    
    // Helper to get percentage of a specific outcome type
    func percentage(for outcomeType: OutcomeType) -> Double {
        let count = actualOutcomes.first(where: { $0.outcomeType == outcomeType })?.count ?? 0
        return totalCount > 0 ? Double(count) / Double(totalCount) * 100.0 : 0.0
    }
}

struct OutcomeCount: Identifiable {
    var id = UUID()
    var outcomeType: OutcomeType
    var count: Int
}

// New data structure for the dual pie chart
struct PieChartData: Identifiable {
    var id = UUID()
    var type: OutcomeType
    var expectedCount: Int
    var expectedPercentage: Double
    var actualCount: Int
    var actualPercentage: Double
}

// MARK: - Chart Data Provider

class ChartDataProvider {
    
    // MARK: - Original Data Methods (using AnalyticsManager)
    
    static func generateOutcomeComparisonData(thoughts: [Thought]) -> [OutcomeComparisonData] {
        return AnalyticsManager.generateOutcomeComparisonData(thoughts: thoughts)
    }
    
    // MARK: - Improved Fear Accuracy Trend Data (with better sorting)
    
    static func generateFearAccuracyData(thoughts: [Thought]) -> [FearAccuracyData] {
        // Get the standard fear accuracy data from AnalyticsManager
        let basicData = AnalyticsManager.generateFearAccuracyData(thoughts: thoughts)
        
        // Group thoughts by month for sorting information
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM yyyy"
        
        // Create a map of month strings to actual dates for sorting purposes
        let monthToDateMap: [String: Date] = {
            var map: [String: Date] = [:]
            
            let resolvedThoughts = thoughts.filter { $0.isResolved && $0.actualOutcomeType != nil && $0.expectedOutcomeType != nil }
            
            let groupedByMonth = Dictionary(grouping: resolvedThoughts) { thought in
                let components = calendar.dateComponents([.year, .month], from: thought.createdAt)
                return calendar.date(from: components) ?? thought.createdAt
            }
            
            for (date, _) in groupedByMonth {
                let monthString = dateFormatter.string(from: date)
                map[monthString] = date
            }
            
            return map
        }()
        
        // Sort data chronologically by the actual date behind each month string
        return basicData.sorted { first, second in
            let firstDate = monthToDateMap[first.month] ?? Date.distantFuture
            let secondDate = monthToDateMap[second.month] ?? Date.distantFuture
            return firstDate < secondDate
        }
    }
    
    // MARK: - New Horizontal Stacked Bar Chart Data (Expectation to Reality)
    
    static func generateExpectationToRealityData(thoughts: [Thought]) -> [ExpectationToRealityData] {
        var data: [ExpectationToRealityData] = []
        
        // Only include resolved thoughts with both expected and actual outcomes
        let resolvedThoughts = thoughts.filter { 
            $0.isResolved && $0.expectedOutcomeType != nil && $0.actualOutcomeType != nil 
        }
        
        // Group thoughts by expected outcome type
        for expectedType in OutcomeType.allCases {
            // Get all thoughts with this expected outcome
            let thoughtsWithExpectation = resolvedThoughts.filter { $0.expectedOutcomeType == expectedType }
            
            if !thoughtsWithExpectation.isEmpty {
                var actualOutcomes: [OutcomeCount] = []
                
                // Count actual outcomes for each outcome type
                for actualType in OutcomeType.allCases {
                    let count = thoughtsWithExpectation.filter { $0.actualOutcomeType == actualType }.count
                    
                    if count > 0 {
                        actualOutcomes.append(OutcomeCount(
                            outcomeType: actualType,
                            count: count
                        ))
                    }
                }
                
                // Add data for this expected outcome type
                data.append(ExpectationToRealityData(
                    expectedType: expectedType,
                    actualOutcomes: actualOutcomes,
                    totalCount: thoughtsWithExpectation.count
                ))
            }
        }
        
        return data
    }
    
    // MARK: - Dual Pie Chart Data (Expected vs. Actual Distribution)
    
    static func generatePieChartData(thoughts: [Thought]) -> [PieChartData] {
        var data: [PieChartData] = []
        
        // Only include resolved thoughts with both expected and actual outcomes
        let resolvedThoughts = thoughts.filter { 
            $0.isResolved && $0.expectedOutcomeType != nil && $0.actualOutcomeType != nil 
        }
        
        if resolvedThoughts.isEmpty {
            return data
        }
        
        let totalCount = resolvedThoughts.count
        
        // Calculate counts and percentages for each outcome type
        for outcomeType in OutcomeType.allCases {
            let expectedCount = resolvedThoughts.filter { $0.expectedOutcomeType == outcomeType }.count
            let actualCount = resolvedThoughts.filter { $0.actualOutcomeType == outcomeType }.count
            
            let expectedPercentage = Double(expectedCount) / Double(totalCount) * 100.0
            let actualPercentage = Double(actualCount) / Double(totalCount) * 100.0
            
            data.append(PieChartData(
                type: outcomeType,
                expectedCount: expectedCount,
                expectedPercentage: expectedPercentage,
                actualCount: actualCount,
                actualPercentage: actualPercentage
            ))
        }
        
        return data.filter { $0.expectedCount > 0 || $0.actualCount > 0 }
    }
    
    // MARK: - Positivity Score Calculation (using AnalyticsManager)
    
    static func calculatePositivityScore(thoughts: [Thought]) -> Double {
        return AnalyticsManager.calculatePositivityScore(thoughts: thoughts)
    }
}