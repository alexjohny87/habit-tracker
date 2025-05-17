//
//  HabitItemView.swift
//  habit-tracker
//

import SwiftUI

// Temporary replacement for SessionData access
extension UUID {
    var stringValue: String {
        return self.uuidString
    }
}

struct HabitItemView: View {
    let habit: Habit
    let onToggleCompleted: () -> Void
    let onToggleEnabled: () -> Void
    let onDelete: () -> Void
    
    // Track selected habit locally for now
    @State private var isSelected: Bool = false
    
    var body: some View {
        VStack {
            HStack {
                // Title and time
                VStack(alignment: .leading, spacing: 4) {
                    Text(habit.title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(habit.isCompleted ? .white : .white)
                        .lineLimit(1)
                    
                    Text(habit.time)
                        .font(.system(size: 14))
                        .foregroundColor(habit.isCompleted ? .white.opacity(0.8) : .gray)
                        .lineLimit(1)
                }
                
                Spacer()
                
                // Delete button
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.system(size: 16))
                        .foregroundColor(habit.isCompleted ? .white.opacity(0.8) : .red.opacity(0.8))
                }
                .padding(8)
                .background(habit.isCompleted ? Color.clear : Color.gray.opacity(0.2))
                .cornerRadius(8)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(habit.isCompleted ? Color.blue : Color.gray.opacity(0.2))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        .contentShape(Rectangle())
        .padding(.horizontal)
        .padding(.vertical, 5)
        .onTapGesture {
            // Toggle completed state
            onToggleCompleted()
            
            // Toggle selected state locally
            isSelected.toggle()
        }
    }
}
