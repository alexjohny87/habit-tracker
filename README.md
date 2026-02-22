# Habit Tracker

A native iOS habit tracking app built with SwiftUI. Create habits, track daily completions, and view detailed statistics over time.

## Features

- **Daily tracking** — Mark habits as complete with a single tap on the checkmark
- **Per-habit calendar** — Tap any habit to see a calendar view highlighting every day it was completed
- **Historical entry** — Tap any past date on the calendar to retroactively add or remove completions
- **Statistics modal** — View detailed stats for each habit including:
  - Current streak and total completions
  - Yearly completion percentage with a progress ring
  - Monthly breakdown bar chart (starting from the month the habit was created)
- **Custom habits** — Choose an emoji icon and color for each habit
- **Persistent storage** — All data is saved locally via UserDefaults and structured for future aggregation

## Architecture

```
habit-tracker/
├── habit_trackerApp.swift          # App entry point
├── ContentView.swift               # Main screen (date header, calendar, habit list)
├── Models/
│   └── HabitModel.swift            # Habit struct, HabitStore (data + persistence)
├── Views/
│   ├── AddHabitView.swift          # New habit form (emoji picker, color picker)
│   ├── HabitDetailView.swift       # Stats modal (yearly %, monthly breakdown, calendar)
│   ├── HabitItemView.swift         # Habit card component
│   └── Components/
│       └── CalendarView.swift      # Month calendar grid with completion highlights
├── Extensions/
│   └── ColorExtensions.swift       # Color hex initializer
└── Assets.xcassets/                # App icon and accent color
```

## Data Model

**Habit** — `id`, `title`, `emoji`, `colorHex`, `createdDate`

**Completions** — Stored as `[habitId: [dateStrings]]` where each date string is `yyyy-MM-dd`. This flat structure supports querying by habit, by date, or by date range for future features like cross-habit reports or exports.

## Requirements

- iOS 17.0+
- Xcode 16+
- Swift 5.9+

## Getting Started

1. Clone the repository
2. Open `habit-tracker.xcodeproj` in Xcode
3. Build and run on a simulator or device
