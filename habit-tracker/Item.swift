//
//  Item.swift
//  habit-tracker
//
//  Created by Alex Johny on 5/11/25.
//

import Foundation
import SwiftData

@Model
final class Habit {
    var title: String
    var habitDescription: String
    var category: String
    var createdAt: Date
    var completedDates: [Date] // Track completion dates
    var targetDaysPerWeek: Int // Target number of days per week
    var streak: Int // Current streak
    var color: String // Store color as a string representation
    
    init(title: String, habitDescription: String = "", category: String = "General", targetDaysPerWeek: Int = 7, color: String = "blue") {
        self.title = title
        self.habitDescription = habitDescription
        self.category = category
        self.createdAt = Date()
        self.completedDates = []
        self.targetDaysPerWeek = targetDaysPerWeek
        self.streak = 0
        self.color = color
    }
    
    // Helper computed properties
    var isCompletedToday: Bool {
        guard let lastCompletion = completedDates.last else { return false }
        return Calendar.current.isDateInToday(lastCompletion)
    }
    
    // Calculate streak
    func updateStreak() {
        guard !completedDates.isEmpty else {
            streak = 0
            return
        }
        
        // Sort dates in ascending order
        let sortedDates = completedDates.sorted()
        
        let calendar = Calendar.current
        var currentStreak = 1
        
        // Start from the most recent date
        var currentDate = sortedDates.last!
        
        // Go backwards checking for consecutive days
        for i in (0..<sortedDates.count - 1).reversed() {
            let previousDate = sortedDates[i]
            
            // Check if the previous date is exactly 1 day before the current date
            let daysBetween = calendar.dateComponents([.day], from: previousDate, to: currentDate).day ?? 0
            
            if daysBetween == 1 {
                currentStreak += 1
                currentDate = previousDate
            } else if daysBetween > 1 {
                // Break the streak
                break
            }
            // If days between is 0 (same day), skip this iteration
        }
        
        // Check if the streak is current (completed yesterday or today)
        let lastCompletionDate = sortedDates.last!
        
        // If the last completion is today or yesterday, streak is current
        if calendar.isDateInToday(lastCompletionDate) ||
           calendar.isDate(lastCompletionDate, inSameDayAs: calendar.date(byAdding: .day, value: -1, to: Date())!) {
            streak = currentStreak
        } else {
            // The streak was broken
            streak = 0
        }
    }
}
