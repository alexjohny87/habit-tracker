import SwiftUI

struct HabitDetailView: View {
    let habit: Habit
    @ObservedObject var habitStore: HabitStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    headerSection
                    yearlyCard
                    monthlyCard
                    calendarCard
                }
                .padding(.top, 8)
                .padding(.bottom, 40)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(habit.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 10) {
            Text(habit.emoji)
                .font(.system(size: 52))
                .frame(width: 80, height: 80)
                .background(habit.color.opacity(0.12))
                .clipShape(Circle())

            Text(habit.title)
                .font(.title2)
                .fontWeight(.bold)

            HStack(spacing: 20) {
                let streak = habitStore.currentStreak(for: habit.id)
                let total = habitStore.totalCompletions(for: habit.id)

                StatPill(value: "\(streak)", label: "Streak", icon: "flame.fill", color: .orange)
                StatPill(value: "\(total)", label: "Total", icon: "checkmark.circle.fill", color: habit.color)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
    }

    // MARK: - Yearly Percentage

    private var yearlyCard: some View {
        let stats = habitStore.yearlyStats(for: habit.id)

        return VStack(spacing: 12) {
            HStack {
                Text("This Year")
                    .font(.headline)
                Spacer()
            }

            HStack(spacing: 20) {
                ZStack {
                    Circle()
                        .stroke(habit.color.opacity(0.15), lineWidth: 8)
                        .frame(width: 72, height: 72)
                    Circle()
                        .trim(from: 0, to: min(stats.percentage / 100, 1.0))
                        .stroke(habit.color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .frame(width: 72, height: 72)
                        .rotationEffect(.degrees(-90))
                    Text("\(Int(stats.percentage))%")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("\(stats.completedDays) of \(stats.totalDays) days")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text("completed so far in \(currentYearString)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.06), radius: 10, y: 3)
        )
        .padding(.horizontal)
    }

    // MARK: - Monthly Breakdown

    private var monthlyCard: some View {
        let breakdown = habitStore.monthlyBreakdown(for: habit.id)
        let maxCount = breakdown.map(\.count).max() ?? 1

        return VStack(alignment: .leading, spacing: 12) {
            Text("Monthly Breakdown")
                .font(.headline)

            ForEach(breakdown.reversed()) { month in
                HStack(spacing: 10) {
                    Text(month.label)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(width: 64, alignment: .leading)

                    GeometryReader { geo in
                        let width = maxCount > 0
                            ? geo.size.width * CGFloat(month.count) / CGFloat(maxCount)
                            : 0

                        RoundedRectangle(cornerRadius: 4)
                            .fill(month.count > 0 ? habit.color : habit.color.opacity(0.1))
                            .frame(width: max(width, month.count > 0 ? 4 : 0))
                    }
                    .frame(height: 16)

                    Text("\(month.count)")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(month.count > 0 ? .primary : .quaternary)
                        .frame(width: 28, alignment: .trailing)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.06), radius: 10, y: 3)
        )
        .padding(.horizontal)
    }

    // MARK: - Calendar

    private var calendarCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("History")
                .font(.headline)
                .padding(.horizontal)
                .padding(.top, 4)

            CalendarView(
                completionDates: habitStore.completionDateStrings(for: habit.id),
                accentColor: habit.color,
                onToggleDate: { date in
                    habitStore.toggleCompletion(for: habit.id, on: date)
                }
            )
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.06), radius: 10, y: 3)
        )
        .padding(.horizontal)
    }

    private var currentYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter.string(from: Date())
    }
}

// MARK: - Stat Pill

private struct StatPill: View {
    let value: String
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(color)
            VStack(alignment: .leading, spacing: 1) {
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.bold)
                Text(label)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(color.opacity(0.1))
        .clipShape(Capsule())
    }
}
