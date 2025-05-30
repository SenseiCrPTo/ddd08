// Features/Dashboard/ViewModels/WidgetViewModels/TasksWidgetViewModel.swift
import SwiftUI
import SwiftData
import Combine

@MainActor
class TasksWidgetViewModel: ObservableObject {
    private var modelContext: ModelContext
    private weak var coordinator: DashboardCoordinator?

    @Published var monthlyGoalStatsText: String = "Загрузка..."
    @Published var monthlyGoalProgress: Double = 0.0
    @Published var monthlyGoalProgressColor: Color = .orange
    @Published var topMonthlyGoals: [Todo] = []    // <--- ИЗМЕНЕНО НА Todo
    @Published var tasksDueToday: [Todo] = []      // <--- ИЗМЕНЕНО НА Todo
    @Published var showEmptyState: Bool = true

    init(modelContext: ModelContext, coordinator: DashboardCoordinator?) {
        self.modelContext = modelContext
        self.coordinator = coordinator
        // fetchTasksData() // Вызывается в onAppear View
    }

    func fetchTasksData() {
        // Используем Todo вместо Task
        let descriptor = FetchDescriptor<Todo>( // <--- ИЗМЕНЕНО НА Todo
            sortBy: [SortDescriptor(\Todo.dueDate, order: .forward), SortDescriptor(\Todo.creationDate, order: .reverse)] // <--- ИЗМЕНЕНО НА \Todo.
        )
        
        do {
            let allTasks = try modelContext.fetch(descriptor)

            let monthlyGoals = allTasks.filter { $0.isMonthlyGoal && !$0.isArchived }
            let completedMonthlyGoals = monthlyGoals.filter { $0.isCompleted }.count
            if !monthlyGoals.isEmpty {
                monthlyGoalStatsText = "Цели на месяц: \(completedMonthlyGoals)/\(monthlyGoals.count)"
                monthlyGoalProgress = Double(completedMonthlyGoals) / Double(monthlyGoals.count)
                monthlyGoalProgressColor = (completedMonthlyGoals == monthlyGoals.count && !monthlyGoals.isEmpty) ? .green : .orange
            } else {
                monthlyGoalStatsText = "Нет целей на этот месяц."
                monthlyGoalProgress = 0.0
                monthlyGoalProgressColor = .gray
            }

            self.topMonthlyGoals = Array(monthlyGoals.filter { !$0.isCompleted && $0.isImportant }.prefix(1))

            let todayStart = Calendar.current.startOfDay(for: Date())
            let todayEnd = Calendar.current.date(byAdding: .day, value: 1, to: todayStart)!
            
            self.tasksDueToday = Array(allTasks.filter { todo in // <--- переменная переименована в todo для ясности
                guard !todo.isCompleted, !todo.isArchived else { return false }
                if let dueDate = todo.dueDate {
                    return dueDate >= todayStart && dueDate < todayEnd
                }
                return false
            }.prefix(2))
            
            showEmptyState = monthlyGoals.isEmpty && self.topMonthlyGoals.isEmpty && self.tasksDueToday.isEmpty

        } catch {
            print("Ошибка загрузки задач (Todo) в TasksWidgetViewModel: \(error)")
            monthlyGoalStatsText = "Ошибка загрузки"
            topMonthlyGoals = []
            tasksDueToday = []
            showEmptyState = true
        }
    }

    func navigateToTasksApp() {
        coordinator?.navigateToTasks() // Этот метод в DashboardCoordinator вызовет AppCoordinator.showTasksModule()
    }

    // func toggleCompletion(for todo: Todo) { // <--- ИЗМЕНЕНО НА Todo
    //     todo.isCompleted.toggle()
    //     fetchTasksData()
    // }
}
