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
- **Insights Dashboard**: Visualize the patterns between what you feared and what occurred
- **Privacy-First**: Face ID protection and local data storage by default

## Philosophy

Meditation teaches us to observe our thoughts without attachment. Ryze brings this practice into everyday life by helping you externalize your fears, examine them objectively, and learn from the results.

Ryze is not about eliminating fear, but about understanding it. By seeing how rarely our worst fears materialize, we can gradually loosen their grip on our decision-making.

## Privacy

We believe your thoughts are deeply personal. By default, all your data stays on your device. If you choose to share insights anonymously to help others, you maintain complete control over what is shared.

## Development Status

Ryze is currently in early development. See [TODO.md](./TODO.md) for the current roadmap and progress.

## Project Structure

### Architecture
- **MVVM Pattern**: The app follows the Model-View-ViewModel architecture pattern
- **SwiftData**: Uses SwiftData for persistence (not Core Data as originally planned)
- **SwiftUI**: Built entirely with SwiftUI for modern UI development

### Key Components
- **Models/**: Contains data models and storage logic
  - `Models.swift`: Core data models (Thought, Outcome)
  - `DataStore.swift`: Data persistence layer using SwiftData
  - `ThoughtViewModel.swift`: View model managing thought data and user interactions
- **Views/**: UI components organized by function
  - `NewThoughtView.swift`: Form for creating new thoughts
  - `ThoughtListView.swift`: History of all thoughts
  - `ThoughtDetailView.swift`: Detailed view of a specific thought
  - `DashboardView.swift`: Analytics and insights
  - `SettingsView.swift`: App configuration
- **ContentView.swift**: Main container view with tab navigation
- **RyzeApp.swift**: App entry point

### Navigation Flow
- Tab-based navigation with automatic sheet presentation for new thoughts
- Dashboard serves as the home screen
- "New Thought" tab automatically triggers the thought creation form
- History tab shows all past thoughts with resolution status

## Design Philosophy

Ryze embraces a zen-like minimalist design approach:

- **Minimal & Clean**: Following Steve Jobs' design sensibilities — nothing unnecessary, everything purposeful
- **Native iOS Experience**: Leveraging standard iOS UI components rather than custom elements
- **Zen Color Palette**: Subtle, calming colors that promote mindfulness and reflection
- **System Defaults**: Supporting light/dark mode through iOS system settings
- **Focus on Content**: The user's thoughts and insights take center stage, not the interface

This minimalist approach aligns perfectly with the app's purpose — creating mental clarity and reducing noise, both in thought patterns and in the interface itself.