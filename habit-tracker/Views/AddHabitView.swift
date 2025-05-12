import SwiftUI

struct AddHabitView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var habitStore: HabitStore
    
    @State private var title = ""
    @State private var time = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.background
                    .ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 20) {
                    Text("Create New Habit")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.textPrimary)
                        .padding(.top)
                    
                    // Habit name field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Habit name")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.textPrimary)
                        
                        TextField("", text: $title)
                            .padding()
                            .background(Color.toggleBackground)
                            .cornerRadius(12)
                            .foregroundColor(.textPrimary)
                            .accentColor(.accent)
                    }
                    
                    // Time field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Time")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.textPrimary)
                        
                        TextField("", text: $time)
                            .padding()
                            .background(Color.toggleBackground)
                            .cornerRadius(12)
                            .foregroundColor(.textPrimary)
                            .accentColor(.accent)
                    }
                    
                    Spacer()
                    
                    // Create button
                    Button(action: {
                        if !title.isEmpty {
                            habitStore.addHabit(title: title, time: time.isEmpty ? "Anytime" : time)
                            dismiss()
                        }
                    }) {
                        Text("Create Habit")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.textPrimary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(title.isEmpty ? Color.toggleBackground : Color.accent)
                            .cornerRadius(24)
                    }
                    .disabled(title.isEmpty)
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.textPrimary)
                    }
                }
            }
        }
    }
} 