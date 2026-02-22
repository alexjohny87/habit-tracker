import SwiftUI

struct ContentView: View {
    @StateObject private var habitStore = HabitStore()
    @State private var showingAddHabit = false
    @State private var detailHabit: Habit? = nil

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    dateHeader
                    calendarSection
                    todaySection
                }
                .padding(.top, 4)
                .padding(.bottom, 100)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Habits")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button { showingAddHabit = true } label: {
                        Image(systemName: "plus")
                            .fontWeight(.semibold)
                    }
                }
            }
            .sheet(isPresented: $showingAddHabit) {
                AddHabitView(habitStore: habitStore)
            }
            .sheet(item: $detailHabit) { habit in
                HabitDetailView(habit: habit, habitStore: habitStore)
            }
        }
    }

    // MARK: - Date Header

    private var dateHeader: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(Date(), format: .dateTime.weekday(.wide))
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
            Text(Date(), format: .dateTime.month(.wide).day())
                .font(.title2.bold())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
    }

    // MARK: - Calendar Section

    @ViewBuilder
    private var calendarSection: some View {
        if let habit = habitStore.selectedHabit {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 8) {
                    Text(habit.emoji)
                        .font(.title3)
                    Text(habit.title)
                        .font(.headline)
                    Spacer()

                    let streak = habitStore.currentStreak(for: habit.id)
                    if streak > 0 {
                        Label("\(streak) day streak", systemImage: "flame.fill")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(.orange)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 14)
                .padding(.bottom, 4)

                CalendarView(
                    completionDates: habitStore.selectedHabitCompletionDates,
                    accentColor: habitStore.selectedHabitColor,
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
            .transition(.opacity.combined(with: .move(edge: .top)))
        } else {
            VStack(spacing: 10) {
                Image(systemName: "calendar")
                    .font(.system(size: 28))
                    .foregroundStyle(.quaternary)
                Text("Tap a habit to view its history")
                    .font(.subheadline)
                    .foregroundStyle(.tertiary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 28)
            .transition(.opacity)
        }
    }

    // MARK: - Today Section

    private var todaySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Today")
                    .font(.title3)
                    .fontWeight(.bold)

                Spacer()

                if !habitStore.habits.isEmpty {
                    let completed = habitStore.habits.filter { habitStore.isCompletedToday($0.id) }.count
                    Text("\(completed) of \(habitStore.habits.count)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal)

            if habitStore.habits.isEmpty {
                emptyState
            } else {
                ForEach(habitStore.habits) { habit in
                    HabitItemView(
                        habit: habit,
                        isSelected: habitStore.selectedHabitId == habit.id,
                        isCompletedToday: habitStore.isCompletedToday(habit.id),
                        streak: habitStore.currentStreak(for: habit.id),
                        totalCompletions: habitStore.totalCompletions(for: habit.id),
                        onTap: {
                            habitStore.selectHabit(habit.id)
                            detailHabit = habit
                        },
                        onToggleCompletion: { habitStore.toggleTodayCompletion(for: habit.id) },
                        onDelete: {
                            withAnimation { habitStore.deleteHabit(id: habit.id) }
                        }
                    )
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "plus.circle")
                .font(.system(size: 36))
                .foregroundStyle(.tertiary)
            Text("No habits yet")
                .font(.headline)
                .foregroundStyle(.secondary)
            Text("Tap + to create your first habit")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
