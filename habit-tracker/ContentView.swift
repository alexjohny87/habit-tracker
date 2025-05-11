//
//  ContentView.swift
//  habit-tracker
//
//  Created by Alex Johny on 5/11/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var habits: [Habit]
    @State private var showingAddHabit = false
    @State private var selectedTab = 0
    
    // Color mapping
    let colorMap: [String: Color] = [
        "blue": .blue,
        "green": .green,
        "red": .red,
        "purple": .purple,
        "orange": .orange,
        "pink": .pink,
        "teal": .teal
    ]
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Today View
            NavigationStack {
                ZStack {
                    Color(.systemGroupedBackground)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 0) {
                        // Header
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("My Habits")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                
                                Text("Track your daily progress")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                showingAddHabit = true
                            }) {
                                Image(systemName: "plus")
                                    .font(.system(size: 22, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(width: 44, height: 44)
                                    .background(Color.blue)
                                    .clipShape(Circle())
                            }
                        }
                        .padding([.horizontal, .top])
                        .padding(.bottom, 8)
                        
                        if habits.isEmpty {
                            Spacer()
                            VStack(spacing: 20) {
                                Image(systemName: "checkmark.circle")
                                    .font(.system(size: 80))
                                    .foregroundColor(.blue.opacity(0.7))
                                
                                Text("No habits yet")
                                    .font(.title2)
                                    .fontWeight(.medium)
                                
                                Text("Tap + to create your first habit")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Button(action: {
                                    showingAddHabit = true
                                }) {
                                    Text("Add Habit")
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 10)
                                        .background(Color.blue)
                                        .cornerRadius(10)
                                }
                                .padding(.top, 10)
                            }
                            Spacer()
                        } else {
                            ScrollView {
                                VStack(spacing: 16) {
                                    ForEach(habits) { habit in
                                        HabitCardView(habit: habit, colorMap: colorMap)
                                            .onTapGesture {
                                                // Navigate to detail view (to be implemented)
                                            }
                                            .contextMenu {
                                                Button(action: {
                                                    toggleHabitCompletion(habit)
                                                }) {
                                                    Label(habit.isCompletedToday ? "Mark as Incomplete" : "Mark as Complete", 
                                                          systemImage: habit.isCompletedToday ? "xmark.circle" : "checkmark.circle")
                                                }
                                                
                                                Button(role: .destructive, action: {
                                                    deleteHabit(habit)
                                                }) {
                                                    Label("Delete", systemImage: "trash")
                                                }
                                            }
                                    }
                                }
                                .padding()
                            }
                        }
                    }
                }
                .sheet(isPresented: $showingAddHabit) {
                    AddHabitView()
                }
                .onAppear {
                    setupNotificationObserver()
                }
                .onDisappear {
                    NotificationCenter.default.removeObserver(self)
                }
            }
            .tabItem {
                Label("Today", systemImage: "calendar")
            }
            .tag(0)
            
            // Stats View
            Text("Stats View - Coming Soon")
                .tabItem {
                    Label("Stats", systemImage: "chart.bar")
                }
                .tag(1)
            
            // Settings View
            Text("Settings - Coming Soon")
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
                .tag(2)
        }
    }
    
    private func setupNotificationObserver() {
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("ToggleHabitCompletion"),
            object: nil,
            queue: .main
        ) { notification in
            if let habit = notification.object as? Habit {
                toggleHabitCompletion(habit)
            }
        }
    }
    
    private func toggleHabitCompletion(_ habit: Habit) {
        withAnimation {
            if habit.isCompletedToday {
                // Remove the last completion if it was today
                if let lastIndex = habit.completedDates.indices.last {
                    habit.completedDates.remove(at: lastIndex)
                }
            } else {
                // Add today's date to completions
                habit.completedDates.append(Date())
                habit.updateStreak()
            }
        }
    }
    
    private func deleteHabit(_ habit: Habit) {
        withAnimation {
            modelContext.delete(habit)
        }
    }
}

// Habit Card View
struct HabitCardView: View {
    var habit: Habit
    var colorMap: [String: Color]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(habit.title)
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                // Completion button
                Button(action: {
                    // This will be handled by parent view through .onTapGesture on the completion button
                    NotificationCenter.default.post(name: NSNotification.Name("ToggleHabitCompletion"), object: habit)
                }) {
                    Image(systemName: habit.isCompletedToday ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 24))
                        .foregroundColor(habit.isCompletedToday ? .green : .gray)
                }
            }
            
            if !habit.habitDescription.isEmpty {
                Text(habit.habitDescription)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            HStack(spacing: 12) {
                Label("\(habit.streak) day streak", systemImage: "flame.fill")
                    .font(.caption)
                    .foregroundColor(.orange)
                
                Label(habit.category, systemImage: "tag.fill")
                    .font(.caption)
                    .foregroundColor(colorMap[habit.color, default: .blue])
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// Add Habit View
struct AddHabitView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var title = ""
    @State private var habitDescription = ""
    @State private var category = "General"
    @State private var targetDaysPerWeek = 7
    @State private var selectedColor = "blue"
    
    let categories = ["General", "Health", "Fitness", "Productivity", "Learning", "Mindfulness", "Other"]
    let colors = ["blue", "green", "red", "purple", "orange", "pink", "teal"]
    let colorMap: [String: Color] = [
        "blue": .blue,
        "green": .green,
        "red": .red,
        "purple": .purple,
        "orange": .orange,
        "pink": .pink,
        "teal": .teal
    ]
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("HABIT DETAILS")) {
                    TextField("Title", text: $title)
                    TextField("Description (optional)", text: $habitDescription)
                }
                
                Section(header: Text("CATEGORY")) {
                    Picker("Category", selection: $category) {
                        ForEach(categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                }
                
                Section(header: Text("FREQUENCY")) {
                    Picker("Days per week", selection: $targetDaysPerWeek) {
                        ForEach(1...7, id: \.self) { number in
                            Text("\(number) day\(number == 1 ? "" : "s")").tag(number)
                        }
                    }
                }
                
                Section(header: Text("COLOR")) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(colors, id: \.self) { color in
                                Circle()
                                    .fill(colorMap[color, default: .blue])
                                    .frame(width: 30, height: 30)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white, lineWidth: 2)
                                            .padding(-4)
                                            .opacity(selectedColor == color ? 1 : 0)
                                    )
                                    .onTapGesture {
                                        selectedColor = color
                                    }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .navigationTitle("New Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        addHabit()
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
    
    private func addHabit() {
        let newHabit = Habit(
            title: title,
            habitDescription: habitDescription,
            category: category,
            targetDaysPerWeek: targetDaysPerWeek,
            color: selectedColor
        )
        
        modelContext.insert(newHabit)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Habit.self, inMemory: true)
}
