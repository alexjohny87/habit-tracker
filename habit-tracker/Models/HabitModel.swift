import Foundation
import SwiftUI

struct Habit: Identifiable, Codable, Hashable {
    var id = UUID()
    var title: String
    var emoji: String
    var colorHex: String
    var createdDate: Date = Date()

    var color: Color {
        Color(hex: colorHex)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Habit, rhs: Habit) -> Bool {
        lhs.id == rhs.id
    }

    private enum CodingKeys: String, CodingKey {
        case id, title, emoji, colorHex, createdDate
    }
}

class HabitStore: ObservableObject {
    @Published var habits: [Habit] = []
    @Published var completions: [String: [String]] = [:]
    @Published var selectedHabitId: UUID? = nil

    static let habitColors = [
        "5E5CE6", // indigo
        "FF453A", // red
        "FF9F0A", // orange
        "30D158", // green
        "64D2FF", // cyan
        "BF5AF2", // purple
        "FF375F", // pink
        "FFD60A", // yellow
    ]

    private let habitsKey = "habits_v2"
    private let completionsKey = "completions_v2"

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.timeZone = .current
        return f
    }()

    init() {
        loadHabits()
        loadCompletions()
    }

    // MARK: - Habit Management

    func addHabit(title: String, emoji: String, colorHex: String) {
        let habit = Habit(title: title, emoji: emoji, colorHex: colorHex)
        habits.append(habit)
        saveHabits()
    }

    func deleteHabit(id: UUID) {
        habits.removeAll { $0.id == id }
        completions.removeValue(forKey: id.uuidString)
        if selectedHabitId == id { selectedHabitId = nil }
        saveHabits()
        saveCompletions()
    }

    func selectHabit(_ id: UUID?) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            selectedHabitId = (selectedHabitId == id) ? nil : id
        }
    }

    // MARK: - Completion Tracking

    func toggleTodayCompletion(for habitId: UUID) {
        toggleCompletion(for: habitId, on: Date())
    }

    func toggleCompletion(for habitId: UUID, on date: Date) {
        let dateString = Self.dateFormatter.string(from: Calendar.current.startOfDay(for: date))
        let key = habitId.uuidString

        if completions[key] == nil {
            completions[key] = []
        }

        if let index = completions[key]?.firstIndex(of: dateString) {
            completions[key]?.remove(at: index)
        } else {
            completions[key]?.append(dateString)
        }

        saveCompletions()
    }

    func isCompletedToday(_ habitId: UUID) -> Bool {
        isCompleted(habitId, on: Date())
    }

    func isCompleted(_ habitId: UUID, on date: Date) -> Bool {
        let dateString = Self.dateFormatter.string(from: Calendar.current.startOfDay(for: date))
        return completions[habitId.uuidString]?.contains(dateString) ?? false
    }

    func completionDateStrings(for habitId: UUID) -> Set<String> {
        Set(completions[habitId.uuidString] ?? [])
    }

    var selectedHabitCompletionDates: Set<String> {
        guard let id = selectedHabitId else { return [] }
        return completionDateStrings(for: id)
    }

    var selectedHabit: Habit? {
        guard let id = selectedHabitId else { return nil }
        return habits.first { $0.id == id }
    }

    var selectedHabitColor: Color {
        selectedHabit?.color ?? .accentColor
    }

    // MARK: - Stats

    struct MonthlyCount: Identifiable {
        let id: String
        let date: Date
        let label: String
        let count: Int
        let daysInMonth: Int
    }

    struct YearlyStats {
        let completedDays: Int
        let totalDays: Int
        let percentage: Double
    }

    func monthlyBreakdown(for habitId: UUID) -> [MonthlyCount] {
        let dateStrings = Set(completions[habitId.uuidString] ?? [])
        let calendar = Calendar.current
        let today = Date()

        let habit = habits.first { $0.id == habitId }
        let createdDate = habit?.createdDate ?? today
        let startMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: createdDate))!
        let currentMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: today))!

        let monthsBetween = calendar.dateComponents([.month], from: startMonth, to: currentMonth).month ?? 0

        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MMM yyyy"

        var results: [MonthlyCount] = []

        for offset in 0...monthsBetween {
            guard let monthDate = calendar.date(byAdding: .month, value: offset, to: startMonth),
                  let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: monthDate)),
                  let range = calendar.range(of: .day, in: .month, for: monthDate)
            else { continue }

            var count = 0
            for day in 0..<range.count {
                if let date = calendar.date(byAdding: .day, value: day, to: firstOfMonth) {
                    if dateStrings.contains(Self.dateFormatter.string(from: date)) {
                        count += 1
                    }
                }
            }

            let label = monthFormatter.string(from: firstOfMonth)
            results.append(MonthlyCount(
                id: label,
                date: firstOfMonth,
                label: label,
                count: count,
                daysInMonth: range.count
            ))
        }

        return results
    }

    func yearlyStats(for habitId: UUID) -> YearlyStats {
        let dateStrings = completions[habitId.uuidString] ?? []
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())

        let yearCount = dateStrings.filter { dateString in
            if let date = Self.dateFormatter.date(from: dateString) {
                return calendar.component(.year, from: date) == currentYear
            }
            return false
        }.count

        let startOfYear = calendar.date(from: DateComponents(year: currentYear, month: 1, day: 1))!
        let today = calendar.startOfDay(for: Date())
        let daysSoFar = max(1, (calendar.dateComponents([.day], from: startOfYear, to: today).day ?? 0) + 1)

        return YearlyStats(
            completedDays: yearCount,
            totalDays: daysSoFar,
            percentage: Double(yearCount) / Double(daysSoFar) * 100
        )
    }

    func currentStreak(for habitId: UUID) -> Int {
        let dateStrings = completions[habitId.uuidString] ?? []
        guard !dateStrings.isEmpty else { return 0 }

        let calendar = Calendar.current
        var streak = 0
        var checkDate = calendar.startOfDay(for: Date())

        let todayString = Self.dateFormatter.string(from: checkDate)
        if !dateStrings.contains(todayString) {
            checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
        }

        for _ in 0..<365 {
            let dateString = Self.dateFormatter.string(from: checkDate)
            if dateStrings.contains(dateString) {
                streak += 1
                checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
            } else {
                break
            }
        }
        return streak
    }

    func totalCompletions(for habitId: UUID) -> Int {
        completions[habitId.uuidString]?.count ?? 0
    }

    // MARK: - Persistence

    private func saveHabits() {
        if let data = try? JSONEncoder().encode(habits) {
            UserDefaults.standard.set(data, forKey: habitsKey)
        }
    }

    private func loadHabits() {
        if let data = UserDefaults.standard.data(forKey: habitsKey),
           let decoded = try? JSONDecoder().decode([Habit].self, from: data) {
            habits = decoded
        }
    }

    private func saveCompletions() {
        if let data = try? JSONEncoder().encode(completions) {
            UserDefaults.standard.set(data, forKey: completionsKey)
        }
    }

    private func loadCompletions() {
        if let data = UserDefaults.standard.data(forKey: completionsKey),
           let decoded = try? JSONDecoder().decode([String: [String]].self, from: data) {
            completions = decoded
        }
    }

    static func dateString(from date: Date) -> String {
        dateFormatter.string(from: date)
    }
}
