// MARK: - AppCoordinator.swift
import SwiftUI
import SwiftData

@MainActor
class AppCoordinator: ObservableObject {
    @Published var currentRootViewWrapper: AnyView?
    private var modelContainer: ModelContainer

    private var dashboardCoordinator: DashboardCoordinator?
    @Published var financesCoordinator: FinancesCoordinator?
    private var todoCoordinator: TodoCoordinator?

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }

    func start() {
        showDashboard()
    }

    func showDashboard() {
        let coordinator = DashboardCoordinator(
            modelContext: modelContainer.mainContext,
            appCoordinator: self
        )
        self.dashboardCoordinator = coordinator

        self.currentRootViewWrapper = AnyView(
            NavigationStack {
                coordinator.start()
            }
        )

        self.financesCoordinator = nil
        self.todoCoordinator = nil
    }

    func showFinancesModule() {
        let coordinator = FinancesCoordinator(
            modelContext: modelContainer.mainContext,
            parentCoordinator: self
        )
        self.financesCoordinator = coordinator

        self.currentRootViewWrapper = AnyView(
            NavigationStack(path: Binding(
                get: { coordinator.path },
                set: { coordinator.path = $0 }
            )) {
                coordinator.start()
            }
        )

        self.dashboardCoordinator = nil
        self.todoCoordinator = nil
    }

    func showTasksModule() {
        let coordinator = TodoCoordinator(
            modelContext: modelContainer.mainContext
        )
        self.todoCoordinator = coordinator

        // ✅ NavigationStack теперь здесь
        self.currentRootViewWrapper = AnyView(
            NavigationStack(path: Binding(
                get: { coordinator.navigationPath },
                set: { coordinator.navigationPath = $0 }
            )) {
                coordinator.rootView()
                    .navigationDestination(for: TodoNavigationRoute.self) { route in
                        coordinator.destinationView(for: route)
                    }
            }
        )

        self.dashboardCoordinator = nil
        self.financesCoordinator = nil
    }

    func showHabitsModule() {
        self.currentRootViewWrapper = AnyView(Text("Модуль Привычек (в разработке)"))
        self.todoCoordinator = nil
    }

    func showDiaryModule() {
        self.currentRootViewWrapper = AnyView(Text("Модуль Дневника (в разработке)"))
        self.todoCoordinator = nil
    }

    func showBodyModule() {
        self.currentRootViewWrapper = AnyView(Text("Модуль Тела (в разработке)"))
        self.todoCoordinator = nil
    }
}
