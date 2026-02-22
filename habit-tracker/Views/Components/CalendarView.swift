import SwiftUI

struct CalendarView: View {
    let completionDates: Set<String>
    let accentColor: Color
    var onToggleDate: ((Date) -> Void)? = nil

    @State private var currentMonth = Date()
    private let calendar = Calendar.current
    private let dayLabels = ["S", "M", "T", "W", "T", "F", "S"]

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.timeZone = .current
        return f
    }()

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Button { changeMonth(by: -1) } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .frame(width: 32, height: 32)
                }

                Spacer()

                Text(monthYearString(from: currentMonth))
                    .font(.headline)

                Spacer()

                Button { changeMonth(by: 1) } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .frame(width: 32, height: 32)
                }
            }

            HStack(spacing: 0) {
                ForEach(Array(dayLabels.enumerated()), id: \.offset) { _, day in
                    Text(day)
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundStyle(.tertiary)
                        .frame(maxWidth: .infinity)
                }
            }

            let days = daysInMonth()
            let leadingSpaces = firstWeekdayOfMonth() - 1

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: 7), spacing: 6) {
                ForEach(0..<leadingSpaces, id: \.self) { _ in
                    Color.clear.aspectRatio(1, contentMode: .fit)
                }

                ForEach(days, id: \.self) { date in
                    let day = calendar.component(.day, from: date)
                    let dateString = Self.dateFormatter.string(from: date)
                    let isCompleted = completionDates.contains(dateString)
                    let isToday = calendar.isDateInToday(date)
                    let isFuture = date > Date()

                    ZStack {
                        if isCompleted {
                            Circle()
                                .fill(accentColor)
                        } else if isToday {
                            Circle()
                                .strokeBorder(accentColor, lineWidth: 2)
                        }

                        Text("\(day)")
                            .font(.system(size: 14, weight: isToday || isCompleted ? .semibold : .regular))
                            .foregroundStyle(
                                isCompleted ? .white :
                                isFuture ? Color(.quaternaryLabel) :
                                isToday ? .primary : .secondary
                            )
                    }
                    .aspectRatio(1, contentMode: .fit)
                    .contentShape(Circle())
                    .onTapGesture {
                        guard !isFuture, onToggleDate != nil else { return }
                        withAnimation(.spring(response: 0.25)) {
                            onToggleDate?(date)
                        }
                    }
                }
            }
        }
        .padding()
    }

    private func daysInMonth() -> [Date] {
        guard let range = calendar.range(of: .day, in: .month, for: currentMonth),
              let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))
        else { return [] }

        return (0..<range.count).compactMap { day in
            calendar.date(byAdding: .day, value: day, to: firstDay)
        }
    }

    private func firstWeekdayOfMonth() -> Int {
        guard let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))
        else { return 1 }
        return calendar.component(.weekday, from: firstDay)
    }

    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }

    private func changeMonth(by value: Int) {
        withAnimation(.easeInOut(duration: 0.2)) {
            if let newMonth = calendar.date(byAdding: .month, value: value, to: currentMonth) {
                currentMonth = newMonth
            }
        }
    }
}
