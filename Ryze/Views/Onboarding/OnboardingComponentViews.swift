//
//  OnboardingComponentViews.swift
//  Ryze
//
//  Created for Ryze app on 13/04/2025.
//

import SwiftUI

// Helper components for the onboarding view
struct OnboardingComponentViews {
    // Philosophy page thought point
    static func thoughtPoint(icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(.purple)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
    
    // Process page step
    static func processStep(number: Int, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Text("\(number)")
                    .font(.headline)
                    .foregroundColor(.blue)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    // Benefits point
    static func benefitPoint(_ text: String) -> some View {
        HStack(spacing: 14) { // Increased spacing between checkmark and text
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.system(size: 18)) // Slightly larger icon
            
            Text(text)
                .font(.system(size: 16, weight: .regular)) // Slightly improved typography
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity) // Center in parent
        .padding(.horizontal, 20) // Add horizontal padding
        .padding(.vertical, 2) // Small vertical padding for better spacing
    }
    
    // Example step
    static func exampleStep<Content: View>(number: Int, title: String, description: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Step header
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: 36, height: 36)
                    
                    Text("\(number)")
                        .font(.headline)
                        .foregroundColor(.blue)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                    
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            // Step content
            content()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground).opacity(0.6))
        )
        .padding(.horizontal)
    }
    
    // Outcome row
    static func outcomeRow(type: OutcomeType, description: String, isSelected: Bool = false, isActual: Bool = false) -> some View {
        HStack {
            Circle()
                .fill(type.color)
                .frame(width: 12, height: 12)
            
            Text(type.displayName)
                .font(.subheadline)
                .foregroundColor(type.color)
                .frame(width: 60, alignment: .leading)
            
            Text(description)
                .font(.callout)
            
            Spacer()
            
            if isSelected {
                Image(systemName: isActual ? "checkmark.circle.fill" : "circle.fill")
                    .foregroundColor(isActual ? .green : .blue)
                    .font(.system(size: isActual ? 22 : 18))
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(isSelected ? .secondarySystemBackground : .systemBackground))
                .opacity(isSelected ? 1 : 0.5)
        )
    }
}