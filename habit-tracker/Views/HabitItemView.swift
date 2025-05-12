import SwiftUI

struct HabitItemView: View {
    let habit: Habit
    let onToggleCompleted: () -> Void
    let onToggleEnabled: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            HStack(spacing: 16) {
                // Custom checkbox
                Button(action: onToggleCompleted) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.borderGray, lineWidth: 2)
                            .background(habit.isCompleted ? Color.accent : Color.clear)
                            .cornerRadius(4)
                            .frame(width: 20, height: 20)
                        
                        if habit.isCompleted {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                }
                .frame(width: 28, height: 28)
                
                // Title and time
                VStack(alignment: .leading, spacing: 2) {
                    Text(habit.title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.textPrimary)
                        .lineLimit(1)
                    
                    Text(habit.time)
                        .font(.system(size: 14))
                        .foregroundColor(.textSecondary)
                        .lineLimit(2)
                }
            }
            
            Spacer()
            
            // Modern toggle
            Toggle("", isOn: Binding(
                get: { habit.isEnabled },
                set: { _ in onToggleEnabled() }
            ))
            .toggleStyle(ModernToggleStyle())
            .labelsHidden()
            
            // Delete button
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.system(size: 16))
                    .foregroundColor(.red.opacity(0.8))
            }
            .padding(.leading, 12)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .frame(minHeight: 72)
    }
}

// Modern toggle style
struct ModernToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(configuration.isOn ? Color.accent : Color.gray.opacity(0.3))
                .frame(width: 50, height: 30)
                .animation(.spring(response: 0.2), value: configuration.isOn)
            
            HStack {
                if configuration.isOn {
                    Spacer()
                }
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 24, height: 24)
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                    .padding(3)
                
                if !configuration.isOn {
                    Spacer()
                }
            }
            .animation(.spring(response: 0.2), value: configuration.isOn)
        }
        .onTapGesture {
            configuration.isOn.toggle()
        }
    }
} 