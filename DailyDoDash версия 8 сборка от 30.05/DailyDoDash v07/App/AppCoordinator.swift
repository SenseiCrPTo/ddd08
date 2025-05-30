// App/AppCoordinator.swift
import SwiftUI
import SwiftData

@MainActor
class AppCoordinator: ObservableObject {
    @Published var currentRootViewWrapper: AnyView?
    private var modelContainer: ModelContainer
    
    // Храним активные дочерние координаторы
    private var dashboardCoordinator: DashboardCoordinator?
    @Published var financesCoordinator: FinancesCoordinator? // Сделаем @Published, чтобы View могло на него подписаться
    // ... другие координаторы ...

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }

    func start() {
        showDashboard()
    }

    func showDashboard() {
        let coordinator = DashboardCoordinator(modelContext: modelContainer.mainContext, appCoordinator: self)
        self.dashboardCoordinator = coordinator
        self.currentRootViewWrapper = AnyView(coordinator.start())
        self.financesCoordinator = nil
    }

    func showFinancesModule() {
        print("AppCoordinator: Показываем модуль Финансов")
        let coordinator = FinancesCoordinator(modelContext: modelContainer.mainContext, parentCoordinator: self)
        self.financesCoordinator = coordinator // Сохраняем и публикуем ссылку
        
        // Теперь AppCoordinator создает NavigationStack для модуля Финансы
        self.currentRootViewWrapper = AnyView(
            NavigationStack(path: Binding(
                get: { coordinator.path }, // Получаем path из координатора
                set: { coordinator.path = $0 } // Устанавливаем path в координаторе
            )) {
                coordinator.start() // start() теперь возвращает View без NavigationStack
            }
        )
    }
    
    // ... заглушки для других модулей ...
    func showTasksModule() {
        currentRootViewWrapper = AnyView(Text("Модуль Задач (в разработке)"))
    }
    func showHabitsModule() {
        currentRootViewWrapper = AnyView(Text("Модуль Привычек (в разработке)"))
    }
    func showDiaryModule() {
        currentRootViewWrapper = AnyView(Text("Модуль Дневника (в разработке)"))
    }
    func showBodyModule() {
        currentRootViewWrapper = AnyView(Text("Модуль Тела (в разработке)"))
    }
}
