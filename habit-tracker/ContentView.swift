//
//  ContentView.swift
//  habit-tracker
//
//  Created by Alex Johny on 5/11/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @StateObject private var habitStore = HabitStore()
    @State private var showingAddHabit = false
    
    var body: some View {
        ZStack {
            Color.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        // Header
                        HStack {
                            Spacer(minLength: 48)
                            
                            Text("Habit Tracker")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.textPrimary)
                                .tracking(-0.3)
                                .frame(maxWidth: .infinity)
                            
                            Button(action: {
                                // Settings action
                            }) {
                                Image(systemName: "gearshape")
                                    .font(.system(size: 24))
                                    .foregroundColor(.textPrimary)
                            }
                            .frame(width: 48)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        
                        // Streak info
                        Text("Welcome back Alex!")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.textPrimary)
                            .padding(.horizontal)
                            .padding(.top, 24)
                            .padding(.bottom, 12)
                        
                        // Today's Habits Section
                        HStack {
                            Text("Today's Habits")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.textPrimary)
                                .tracking(-0.3)
                            
                            Spacer()
                            
                            Text("\(habitStore.habits.count) habits")
                                .foregroundColor(.textSecondary)
                                .font(.system(size: 14))
                        }
                        .padding(.horizontal)
                        .padding(.top, 24)
                        .padding(.bottom, 8)
                        
                        // Habit Items - Card Layout
                        VStack(spacing: 10) {
                            ForEach(habitStore.habits) { habit in
                                HabitItemView(
                                    habit: habit,
                                    onToggleCompleted: {
                                        habitStore.toggleCompleted(for: habit.id)
                                    },
                                    onToggleEnabled: {
                                        habitStore.toggleEnabled(for: habit.id)
                                    },
                                    onDelete: {
                                        habitStore.deleteHabit(id: habit.id)
                                    }
                                )
                            }
                        }
                        .padding(.vertical, 8)

                        // Calendar Section - Moved above habits for prominence
                        Text("Calendar")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.textPrimary)
                            .tracking(-0.3)
                            .padding(.horizontal)
                            .padding(.top, 16)
                            .padding(.bottom, 8)
                        
                        // Calendar Card
                        VStack {
                            CalendarView(completionData: habitStore.completionData)
                                .frame(minHeight: 320)
                        }
                        .padding()
                        .background(Color.cardBackground)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                        .padding(.horizontal)
                        
                        // Stats Card
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Statistics")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.textPrimary)
                            
                            Text("\(habitStore.habitCount)")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.textPrimary)
                            
                            HStack(spacing: 4) {
                                Text("Last 7 days")
                                    .font(.system(size: 16))
                                    .foregroundColor(.textSecondary)
                                
                                Text(habitStore.weeklyGrowth)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.success)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.cardBackground)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                        .padding(.horizontal)
                        .padding(.top, 16)
                        
                        Spacer(minLength: 60)
                    }
                }
                
                // Footer with Create button
                VStack(spacing: 0) {
                    Divider()
                        .opacity(0)
                    
                    HStack {
                        Button(action: {
                            showingAddHabit = true
                        }) {
                            HStack {
                                Image(systemName: "plus")
                                    .font(.system(size: 24))
                                Text("Create habit")
                                    .font(.system(size: 16, weight: .bold))
                                    .tracking(0.3)
                            }
                            .foregroundColor(.textPrimary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(Color.accent)
                            .cornerRadius(24)
                        }
                    }
                    .padding()
                    
                    Color.background
                        .frame(height: 20)
                }
            }
        }
        .font(.system(size: 16))
        .sheet(isPresented: $showingAddHabit) {
            AddHabitView(habitStore: habitStore)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
