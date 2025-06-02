import SwiftUI
import SwiftData

@MainActor
class DashboardCoordinator: ObservableObject {
    private var modelContext: ModelContext
    private weak var appCoordinator: AppCoordinator?

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
        appCoordinator?.showFinancesModule()
    }

    func navigateToTodos() {
        print("DashboardCoordinator: Переход в Todo")
        appCoordinator?.showTasksModule() // ✅ Прямой вызов, как у Финансов
    }

    func navigateToHabits() {
        appCoordinator?.showHabitsModule()
    }

    func navigateToDiary() {
        appCoordinator?.showDiaryModule()
    }

    func navigateToBody() {
        appCoordinator?.showBodyModule()
    }
}
