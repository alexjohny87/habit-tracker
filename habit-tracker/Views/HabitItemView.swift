import SwiftUI

struct HabitItemView: View {
    let habit: Habit
    let isSelected: Bool
    let isCompletedToday: Bool
    let streak: Int
    let totalCompletions: Int
    let onTap: () -> Void
    let onToggleCompletion: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            Text(habit.emoji)
                .font(.title2)
                .frame(width: 46, height: 46)
                .background(habit.color.opacity(0.12))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 3) {
                Text(habit.title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)

                HStack(spacing: 8) {
                    if streak > 0 {
                        Label("\(streak)d streak", systemImage: "flame.fill")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                    if totalCompletions > 0 {
                        Text("\(totalCompletions) total")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            Button(action: onToggleCompletion) {
                Image(systemName: isCompletedToday ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 28))
                    .foregroundStyle(isCompletedToday ? habit.color : Color(.tertiaryLabel))
                    .animation(.spring(response: 0.3), value: isCompletedToday)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(isSelected ? habit.color : .clear, lineWidth: 2.5)
        )
        .padding(.horizontal)
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
        .contextMenu {
            Button(role: .destructive, action: onDelete) {
                Label("Delete Habit", systemImage: "trash")
            }
        }
    }
}
