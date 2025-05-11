//
//  ExampleView.swift
//  Ryze
//
//  Created for Ryze app on 11/05/2025.
//

import SwiftUI

struct ExampleView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var animateIcon = false

    var body: some View {
        NavigationStack {
            ExampleContentView(
                presentationType: .settings,
                onComplete: { dismiss() },
                onSkip: nil
            )
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                    animateIcon = true
                }
            }
        }
    }
}

#Preview {
    ExampleView()
}