// Features/Dashboard/ViewModels/WidgetViewModels/HabitWidgetViewModel.swift
import SwiftUI
import SwiftData
import Combine

@MainActor
class HabitWidgetViewModel: ObservableObject {
    private var modelContext: ModelContext
    private weak var coordinator: DashboardCoordinator?

    @Published var habitsForWidget: [Habit] = []
    @Published var totalActiveHabits: Int = 0
    @Published var dailyCompletionPercentage: Double = 0.0
    @Published var showEmptyState: Bool = true
    
    init(modelContext: ModelContext, coordinator: DashboardCoordinator?) {
        self.modelContext = modelContext
        self.coordinator = coordinator
        // fetchHabitData() // Вызывается в onAppear View
    }

    func fetchHabitData() {
        let sortDescriptor = SortDescriptor(\Habit.order)
        let predicate = #Predicate<Habit> { habit in
            !habit.isArchived && habit.showInWidget
        }
        var fetchDescriptor = FetchDescriptor<Habit>(predicate: predicate, sortBy: [sortDescriptor])
        fetchDescriptor.fetchLimit = 4

        do {
            let allActiveHabitsDescriptor = FetchDescriptor<Habit>(predicate: #Predicate<Habit> { !$0.isArchived })
            let allActive = try modelContext.fetch(allActiveHabitsDescriptor)
            self.totalActiveHabits = allActive.count
            
            self.habitsForWidget = try modelContext.fetch(fetchDescriptor)
            
            updateDailyCompletionPercentage(allActiveHabits: allActive)
            
            showEmptyState = self.habitsForWidget.isEmpty && self.totalActiveHabits == 0

        } catch {
            print("Ошибка загрузки данных для HabitWidgetViewModel: \(error)")
            habitsForWidget = []
            totalActiveHabits = 0
            dailyCompletionPercentage = 0
            showEmptyState = true
        }
    }

    private func updateDailyCompletionPercentage(allActiveHabits: [Habit]) {
        let today = Calendar.current.startOfDay(for: Date())
        var dueTodayCount = 0
        var completedTodayCount = 0

        for habit in allActiveHabits {
            if isHabitDueOn(habit: habit, date: today) {
                dueTodayCount += 1
                if isHabitCompletedOn(habitID: habit.id, date: today) {
                    completedTodayCount += 1
                }
            }
        }
        
        if dueTodayCount > 0 {
            self.dailyCompletionPercentage = (Double(completedTodayCount) / Double(dueTodayCount)) * 100.0
        } else {
            self.dailyCompletionPercentage = 0
        }
    }

    func isHabitCompletedOn(habitID: UUID, date: Date) -> Bool {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let optionalHabitID: UUID? = habitID // <--- Создаем опциональную версию для сравнения

        let predicate = #Predicate<HabitCompletionLog> { log in
            log.habit?.id == optionalHabitID && // Сравниваем UUID? == UUID?
            log.date == startOfDay &&
            log.isCompleted
        }
        var descriptor = FetchDescriptor(predicate: predicate)
        descriptor.fetchLimit = 1
        
        do {
            return try modelContext.fetchCount(descriptor) > 0
        } catch {
            print("Ошибка проверки выполнения привычки: \(error)")
            return false
        }
    }

    func isHabitDueOn(habit: Habit, date: Date) -> Bool {
        guard !habit.isArchived else { return false }
        guard let schedule = habit.scheduleDays, !schedule.isEmpty else { return true }
        
        let weekday = Calendar.current.component(.weekday, from: date)
        return schedule.contains(weekday)
    }

    func toggleHabitCompletion(habit: Habit, date: Date = Date()) {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let optionalHabitID: UUID? = habit.id // <--- Создаем опциональную версию для сравнения
        
        let predicate = #Predicate<HabitCompletionLog> { log in
            log.habit?.id == optionalHabitID && // Сравниваем UUID? == UUID?
            log.date == startOfDay
        }
        var descriptor = FetchDescriptor(predicate: predicate)
        descriptor.fetchLimit = 1

        do {
            if let existingLog = try modelContext.fetch(descriptor).first {
                existingLog.isCompleted.toggle()
                if !existingLog.isCompleted {
                    modelContext.delete(existingLog)
                }
            } else {
                let newLog = HabitCompletionLog(date: startOfDay, isCompleted: true)
                newLog.habit = habit
                modelContext.insert(newLog)
            }
            try? modelContext.save()
        } catch {
            print("Ошибка при обновлении статуса привычки: \(error)")
        }
        fetchHabitData()
    }
    
    func completionColor(_ percentage: Double) -> Color {
        if percentage >= 75 { return .green }
        if percentage >= 40 { return .orange }
        return .red
    }

    func navigateToHabitsApp() {
        coordinator?.navigateToHabits()
    }
}
