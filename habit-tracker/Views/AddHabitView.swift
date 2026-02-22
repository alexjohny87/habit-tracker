import SwiftUI

struct AddHabitView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var habitStore: HabitStore

    @State private var title = ""
    @State private var selectedEmoji = "🏃"
    @State private var selectedColorIndex = 0

    private let emojis = [
        "🏃", "📖", "🧘", "💪", "🧠", "💤", "💧", "🥗",
        "✍️", "🎵", "🧹", "💊", "🚶", "🎯", "📱", "🏋️",
    ]

    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Habit name", text: $title)
                }

                Section("Icon") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 8), spacing: 14) {
                        ForEach(emojis, id: \.self) { emoji in
                            Text(emoji)
                                .font(.title2)
                                .frame(width: 42, height: 42)
                                .background(
                                    Circle()
                                        .fill(selectedEmoji == emoji ? Color.accentColor.opacity(0.15) : Color.clear)
                                )
                                .overlay(
                                    Circle()
                                        .strokeBorder(selectedEmoji == emoji ? Color.accentColor : .clear, lineWidth: 2)
                                )
                                .onTapGesture { selectedEmoji = emoji }
                        }
                    }
                    .padding(.vertical, 6)
                }

                Section("Color") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 8), spacing: 14) {
                        ForEach(HabitStore.habitColors.indices, id: \.self) { index in
                            Circle()
                                .fill(Color(hex: HabitStore.habitColors[index]))
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Circle()
                                        .strokeBorder(.white, lineWidth: selectedColorIndex == index ? 3 : 0)
                                )
                                .shadow(
                                    color: selectedColorIndex == index
                                        ? Color(hex: HabitStore.habitColors[index]).opacity(0.5)
                                        : .clear,
                                    radius: 4
                                )
                                .scaleEffect(selectedColorIndex == index ? 1.15 : 1.0)
                                .animation(.spring(response: 0.25), value: selectedColorIndex)
                                .onTapGesture { selectedColorIndex = index }
                        }
                    }
                    .padding(.vertical, 6)
                }

                Section {
                    HStack(spacing: 14) {
                        Text(selectedEmoji)
                            .font(.title)
                            .frame(width: 48, height: 48)
                            .background(Color(hex: HabitStore.habitColors[selectedColorIndex]).opacity(0.12))
                            .clipShape(Circle())

                        VStack(alignment: .leading, spacing: 2) {
                            Text(title.isEmpty ? "Habit name" : title)
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundStyle(title.isEmpty ? .tertiary : .primary)
                            Text("Preview")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Preview")
                }
            }
            .navigationTitle("New Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        habitStore.addHabit(
                            title: title.trimmingCharacters(in: .whitespaces),
                            emoji: selectedEmoji,
                            colorHex: HabitStore.habitColors[selectedColorIndex]
                        )
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(!canSave)
                }
            }
        }
    }
}
