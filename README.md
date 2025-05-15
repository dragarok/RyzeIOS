# Ryze

> Rise beyond fear. Challenge catastrophic thinking. Discover reality.

## About Ryze

Ryze is an iOS application designed to help users break free from fear-based thinking patterns that have been evolutionarily hardwired into our brains. While these instincts once served our survival, they now often limit our potential in the modern world.

### The Problem

Fear, particularly catastrophic thinking, influences many of our decisions. When faced with uncertainty, our minds tend to gravitate toward worst-case scenarios—most of which never materialize. This disconnect between our expectations and reality keeps us trapped in cycles of unnecessary anxiety.

### Our Solution

Ryze provides a simple yet powerful framework:

1. **Record** your overwhelming thoughts or concerns
2. **Identify** the spectrum of possible outcomes (from worst to best)
3. **Predict** which outcome you currently expect
4. **Set** a deadline for when you'll know the actual outcome
5. **Compare** your expectation with what actually happened
6. **Learn** from the patterns that emerge over time

By building a personal database of expected vs. actual outcomes, users can develop greater emotional resilience and more balanced thinking.

## Features

- **Thought Tracking**: Record worries and their possible outcomes
- **Outcome Spectrum**: Define scenarios ranging from worst to best case
- **Deadline Reminders**: Full-screen notifications when it's time to record what actually happened
- **Persistent Follow-ups**: Recurring notifications for unresolved thoughts
- **Enhanced Security**: Face ID/Touch ID protection and secure data storage options
- **Insights Dashboard**: Visualize the patterns between what you feared and what occurred
  - Stacked bar charts comparing expected vs. actual outcomes
  - Trend lines showing your fear accuracy over time
  - Outcome distribution analysis
  - Personalized positivity score with detailed explanations
  - Interactive chart details with meaningful insights and messages
- **Emotional Onboarding**: An engaging introduction that connects with users at a personal level
- **Interactive Examples**: Guided walkthroughs that demonstrate the app's value
- **Badge Notifications**: App icon badges for unresolved thoughts past their deadline
- **Privacy-First**: Biometric authentication and local data storage by default

## Philosophy

Meditation teaches us to observe our thoughts without attachment. Ryze brings this practice into everyday life by helping you externalize your fears, examine them objectively, and learn from the results.

Ryze is not about eliminating fear, but about understanding it. By seeing how rarely our worst fears materialize, we can gradually loosen their grip on our decision-making.

## Privacy

We believe your thoughts are deeply personal. By default, all your data stays on your device. Secure storage options with encryption are available for enhanced protection. The app uses biometric authentication (Face ID/Touch ID) to ensure only you can access your thoughts.

## Development Status

Ryze is currently in active development and preparing for App Store submission. Recently completed features include:

- Enhanced security features with biometric authentication
- Secure data storage with encryption
- Interactive data visualizations with personalized insights
- Follow-up notification system for unresolved thoughts
- Full analytics system with trend analysis and personalized messages
- Emotionally engaging onboarding experience

See [TODO.md](./TODO.md) for the complete roadmap and progress.

## Project Structure

### Architecture
- **MVVM Pattern**: The app follows the Model-View-ViewModel architecture pattern
- **SwiftData**: Uses SwiftData for persistence with secure storage options
- **SwiftUI**: Built entirely with SwiftUI for modern UI development

### Key Components
- **Models/**: Contains data models and storage logic
  - `Models.swift`: Core data models (Thought, Outcome)
  - `DataStore.swift`: Data persistence layer using SwiftData with enhanced security options
  - `ThoughtViewModel.swift`: View model managing thought data and user interactions
  - `AnalyticsManager.swift`: Processing and analysis of thought patterns
  - `AuthenticationManager.swift`: Biometric authentication handling
  - `SecureDataManager.swift`: Encryption and secure storage utilities
- **Views/**: UI components organized by function
  - `NewThoughtView.swift`: Form for creating new thoughts
  - `ThoughtListView.swift`: History of all thoughts
  - `ThoughtDetailView.swift`: Detailed view of a specific thought
  - `DashboardView.swift`: Analytics and insights
  - `InsightsChartView.swift`: Visualizations of thought patterns
  - `ChartDetailView.swift`: Detailed chart analysis with explanations
  - `OnboardingView.swift`: Personalized introduction experience
  - `SettingsView.swift`: App configuration
  - **Notifications/**: Components for handling deadline notifications
    - `NotificationManager.swift`: Comprehensive notification handling system
    - `NotificationView.swift`: UI components for notifications
    - `FullScreenNotificationView.swift`: Immersive notification experience
  - **Charts/**: Advanced visualization components
    - `ExpectationVsRealityChart.swift`: Comparison of expected and actual outcomes
    - `FearAccuracyTrendChart.swift`: Analysis of prediction accuracy over time
    - `PositivityScoreChart.swift`: Visual representation of the positivity metric
    - `OutcomeDistributionChart.swift`: Distribution of actual outcomes
    - `ChartMessages.swift`: Positive reinforcement messages for chart views
    - `ChartDataProviders.swift`: Data processing for visualizations
    - `ChartContainerView.swift`: Reusable chart container with consistent styling
- **ContentView.swift**: Main container view with tab navigation
- **RyzeApp.swift**: App entry point and dependency injection

### Navigation Flow
- Tab-based navigation with automatic sheet presentation for new thoughts
- Dashboard serves as the home screen with personalized insights
- "New Thought" tab automatically triggers the thought creation form
- History tab shows all past thoughts with resolution status and filtering options
- First-time users experience personalized onboarding
- Chart interactions provide deeper insights with positive messaging
- Notification system presents immersive full-screen views for deadline reminders

## Design Philosophy

Ryze embraces a zen-like minimalist design approach:

- **Minimal & Clean**: Following Steve Jobs' design sensibilities — nothing unnecessary, everything purposeful
- **Native iOS Experience**: Leveraging standard iOS UI components rather than custom elements
- **Zen Color Palette**: Subtle, calming colors that promote mindfulness and reflection
- **System Defaults**: Supporting light/dark mode through iOS system settings
- **Focus on Content**: The user's thoughts and insights take center stage, not the interface
- **Emotional Connection**: Creating moments of personal resonance through thoughtful design

This minimalist approach aligns perfectly with the app's purpose — creating mental clarity and reducing noise, both in thought patterns and in the interface itself.