//
//  ChartContainerView.swift
//  Ryze
//
//  Created for Ryze app on 15/05/2025.
//

import SwiftUI

struct ChartContainerView<Content: View>: View {
    let title: String
    let description: String
    let content: Content
    
    init(title: String, description: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.description = description
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Fixed position header
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.title3)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Chart content with fixed height
            content
                .frame(minHeight: 430)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    ChartContainerView(
        title: "Sample Chart",
        description: "This is a sample chart description"
    ) {
        Rectangle()
            .fill(Color.blue.opacity(0.2))
            .frame(height: 300)
    }
    .padding()
}
