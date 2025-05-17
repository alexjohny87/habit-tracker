import Foundation
import SwiftUI

/// Manages app session data and acts as a central store for temporary app state
class SessionData: ObservableObject {
    static let shared = SessionData()
    
    // User session data
    @Published var userData: [String: Any] = [:]
    @Published var viewHistory: [String] = []
    
    // App session statistics
    @Published var currentStreak: Int = 0
    @Published var todayCompletionRate: Double = 0.0
    @Published var lastActiveDate: Date = Date()
    
    // App settings that might change during a session
    @Published var notificationsEnabled: Bool = true
    @Published var themeMode: String = "system" // "light", "dark", "system"
    
    // Session activity tracking
    @Published var habitCompletedCount: Int = 0
    @Published var sessionStartTime: Date = Date()
    
    // Selected habits tracking
    @Published var selectedHabitIds: Set<String> = []
    @Published var currentlyViewedHabitId: String? = nil
    
    // Cache
    @Published var cachedHabits: [String: Any] = [:]
    @Published var cachedCompletionData: [String: Any] = [:]
    
    /// Updates session activity for analytics
    func recordActivityEvent(eventName: String, metadata: [String: Any]? = nil) {
        let timestamp = Date()
        // Logic to store the event would go here
        print("Event recorded: \(eventName) at \(timestamp)")
    }
    
    /// Navigates to a new view and updates history
    func navigateToView(viewName: String) {
        viewHistory.append(viewName)
        recordActivityEvent(eventName: "view_navigation", metadata: ["view": viewName])
    }
    
    /// Updates the current streak
    func updateStreak(count: Int) {
        currentStreak = count
        userData["streak"] = count
    }
    
    /// Selects or deselects a habit
    func toggleHabitSelection(habitId: String) {
        if selectedHabitIds.contains(habitId) {
            selectedHabitIds.remove(habitId)
        } else {
            selectedHabitIds.insert(habitId)
        }
    }
    
    /// Sets the currently viewed habit
    func setCurrentHabit(habitId: String?) {
        currentlyViewedHabitId = habitId
    }
    
    /// Clears session data on logout
    func clearSession() {
        userData = [:]
        viewHistory = []
        cachedHabits = [:]
        cachedCompletionData = [:]
        habitCompletedCount = 0
        sessionStartTime = Date()
        selectedHabitIds = []
        currentlyViewedHabitId = nil
    }
    
    private init() {
        // Initialize with default values
        sessionStartTime = Date()
    }
} 