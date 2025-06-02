import Foundation
import SwiftData
import SwiftUI

@MainActor
final class TodoWidgetViewModel: ObservableObject {
    @Published var todayTodos: [Todo] = []
    @Published var topMonthlyGoals: [Todo] = []
    @Published var monthlyStats: (completed: Int, total: Int) = (0, 0)

    private var context: ModelContext
    weak var coordinator: DashboardCoordinator?

    init(context: ModelContext, coordinator: DashboardCoordinator?) {
        self.context = context
        self.coordinator = coordinator
        fetchTodos()
    }

    func fetchTodos() {
        do {
            let allTodos = try context.fetch(FetchDescriptor<Todo>())
            let calendar = Calendar.current
            let now = Date()

            todayTodos = allTodos.filter {
                guard let due = $0.dueDate else { return false }
                return calendar.isDate(due, inSameDayAs: now)
            }

            topMonthlyGoals = allTodos.filter {
                $0.goalHorizon == .month
            }

            let thisMonthTodos = allTodos.filter {
                guard let due = $0.dueDate else { return false }
                return calendar.isDate(due, equalTo: now, toGranularity: .month)
            }

            let completedCount = thisMonthTodos.filter { $0.isCompleted }.count
            monthlyStats = (completed: completedCount, total: thisMonthTodos.count)
        } catch {
            print("❌ Ошибка загрузки Todo из SwiftData: \(error)")
        }
    }
}
