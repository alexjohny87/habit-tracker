import SwiftUI

struct CalendarView: View {
    let completionData: [Date: Bool]
    
    @State private var currentMonth = Date()
    private let calendar = Calendar.current
    private let daysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    var body: some View {
        VStack(spacing: 20) {
            // Month selector
            HStack {
                Button(action: { changeMonth(by: -1) }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.textPrimary)
                }
                
                Spacer()
                
                Text(monthYearString(from: currentMonth))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Button(action: { changeMonth(by: 1) }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.textPrimary)
                }
            }
            .padding(.horizontal)
            
            // Days of week header
            HStack {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.textSecondary)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Calendar grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(days(), id: \.self) { date in
                    if let date = date {
                        DayCell(date: date, isCompleted: completionData[date, default: false])
                    } else {
                        Color.clear
                            .aspectRatio(1, contentMode: .fit)
                    }
                }
            }
        }
    }
    
    private func days() -> [Date?] {
        let start = startOfMonth(currentMonth)
        let firstWeekday = calendar.component(.weekday, from: start)
        let offsetDays = firstWeekday - 1
        
        let daysInMonth = calendar.range(of: .day, in: .month, for: currentMonth)?.count ?? 0
        
        var days = [Date?](repeating: nil, count: offsetDays)
        
        for day in 1...daysInMonth {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: start) {
                days.append(date)
            }
        }
        
        // Pad to complete the grid (for a total of up to 42 cells - 6 rows)
        let remainingCells = 42 - days.count
        days.append(contentsOf: [Date?](repeating: nil, count: remainingCells))
        
        return days
    }
    
    private func startOfMonth(_ date: Date) -> Date {
        let components = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: components) ?? date
    }
    
    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
    private func changeMonth(by value: Int) {
        if let newMonth = calendar.date(byAdding: .month, value: value, to: currentMonth) {
            currentMonth = newMonth
        }
    }
}

struct DayCell: View {
    let date: Date
    let isCompleted: Bool
    private let calendar = Calendar.current
    
    var body: some View {
        ZStack {
            Circle()
                .fill(isCompleted ? Color.accent : Color.clear)
                .aspectRatio(1, contentMode: .fit)
            
            Text("\(calendar.component(.day, from: date))")
                .font(.system(size: 14, weight: isToday ? .bold : .regular))
                .foregroundColor(textColor)
        }
    }
    
    private var isToday: Bool {
        calendar.isDateInToday(date)
    }
    
    private var textColor: Color {
        if isToday {
            return .textPrimary
        } else if isCompleted {
            return .white
        } else {
            return .textSecondary
        }
    }
} 