import Foundation
import SwiftUI

struct Habit: Identifiable, Codable {
    var id = UUID()
    var title: String
    var time: String
    var isCompleted: Bool = false
    var isEnabled: Bool = true
}

class HabitStore: ObservableObject {
    @Published var habits: [Habit] = []
    
    var streakCount: Int = 5
    var habitCount: Int { return habits.count }
    var weeklyProgress: [CGFloat] = [0, 80, 10, 80, 30, 90, 50]
    var weeklyGrowth: String = "+30%"
    
    // Calendar completion data
    @Published var completionData: [Date: Bool] = [:]
    
    init() {
        loadHabits()
        
        // If no habits exist, create default ones
        if habits.isEmpty {
            habits = [
                Habit(title: "Meditate", time: "7am"),
                Habit(title: "Workout", time: "12pm"),
                Habit(title: "Read", time: "8pm")
            ]
            saveHabits()
        }
        
        // Generate sample completion data for the past month
        generateSampleCompletionData()
    }
    
    private func generateSampleCompletionData() {
        let calendar = Calendar.current
        let today = Date()
        
        // Generate data for the last 30 days
        for dayOffset in 0..<30 {
            if let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) {
                // Random completion status (more likely to be completed for recent days)
                let isCompleted = dayOffset < 5 ? Bool.random() : (Double.random(in: 0...1) > 0.4)
                
                // Normalize date to remove time component
                let normalizedDate = calendar.startOfDay(for: date)
                completionData[normalizedDate] = isCompleted
            }
        }
    }
    
    func toggleCompleted(for habitId: UUID) {
        if let index = habits.firstIndex(where: { $0.id == habitId }) {
            habits[index].isCompleted.toggle()
            saveHabits()
        }
        
        // Update today's completion status in the calendar data
        let today = Calendar.current.startOfDay(for: Date())
        if habits.allSatisfy({ $0.isCompleted || !$0.isEnabled }) {
            completionData[today] = true
        } else {
            completionData[today] = false
        }
    }
    
    func toggleEnabled(for habitId: UUID) {
        if let index = habits.firstIndex(where: { $0.id == habitId }) {
            habits[index].isEnabled.toggle()
            saveHabits()
        }
    }
    
    func addHabit(title: String, time: String) {
        let newHabit = Habit(title: title, time: time)
        habits.append(newHabit)
        saveHabits()
    }
    
    func deleteHabit(id: UUID) {
        habits.removeAll { $0.id == id }
        saveHabits()
    }
    
    // MARK: - UserDefaults Methods
    
    private func saveHabits() {
        if let encoded = try? JSONEncoder().encode(habits) {
            UserDefaults.standard.set(encoded, forKey: "habits")
        }
    }
    
    private func loadHabits() {
        if let habitsData = UserDefaults.standard.data(forKey: "habits"),
           let decodedHabits = try? JSONDecoder().decode([Habit].self, from: habitsData) {
            habits = decodedHabits
        }
    }
} 