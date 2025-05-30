// Features/Dashboard/Coordinators/DashboardCoordinator.swift
import SwiftUI
import SwiftData

@MainActor
class DashboardCoordinator {
    private var modelContext: ModelContext
    private weak var appCoordinator: AppCoordinator? // Ссылка на AppCoordinator

    init(modelContext: ModelContext, appCoordinator: AppCoordinator) {
        self.modelContext = modelContext
        self.appCoordinator = appCoordinator
    }

    @ViewBuilder
    func start() -> some View {
        let viewModel = MainDashboardViewModel(modelContext: modelContext, coordinator: self)
        MainDashboardView(viewModel: viewModel)
    }

    func navigateToFinances() {
        print("DashboardCoordinator: Запрос навигации к Финансам")
        // Передаем управление AppCoordinator'у, чтобы он показал модуль Финансов
        // AppCoordinator будет создавать и запускать FinancesCoordinator
        appCoordinator?.showFinancesModule()
    }

    func navigateToTasks() {
        print("DashboardCoordinator: Навигация к Задачам")
        appCoordinator?.showTasksModule() // Аналогично для других модулей
    }
    
    func navigateToHabits() {
        print("DashboardCoordinator: Навигация к Привычкам")
        appCoordinator?.showHabitsModule()
    }
    
    func navigateToDiary() {
        print("DashboardCoordinator: Навигация к Дневнику")
        appCoordinator?.showDiaryModule()
    }
    
    func navigateToBody() {
        print("DashboardCoordinator: Навигация к Телу")
        appCoordinator?.showBodyModule()
    }
}
