import SwiftUI
import SwiftData

@MainActor
final class TodoCoordinator: ObservableObject {
    @Published var navigationPath = NavigationPath()
    let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func rootView() -> some View {
        let pathBinding = Binding(
            get: { self.navigationPath },
            set: { self.navigationPath = $0 }
        )

        return NavigationStack(path: pathBinding) {
            MainTabView(modelContext: modelContext, coordinator: self)
                .navigationDestination(for: TodoNavigationRoute.self) { route in
                    self.destinationView(for: route)
                }
        }
    }

    @ViewBuilder
    func destinationView(for route: TodoNavigationRoute) -> some View {
        let _ = logRoute(route) // ✅ безопасный вызов

        switch route {
        case .detail(let todo):
            TodoDetailView(viewModel: TodoDetailViewModel(todo: todo))
        case .todoAdd:
            TodoAddView(viewModel: TodoAddViewModel())
        }
    }

    private func logRoute(_ route: TodoNavigationRoute) {
        print("🧭 Переход на экран: \(route)")
    }

    func showDetail(for todo: Todo) {
        print("🔗 showDetail called")
        navigationPath.append(TodoNavigationRoute.detail(todo))
    }

    func showAdd() {
        print("➕ showAdd called")
        navigationPath.append(TodoNavigationRoute.todoAdd)
    }
}

enum TodoNavigationRoute: Hashable, CustomStringConvertible {
    case detail(Todo)
    case todoAdd

    var description: String {
        switch self {
        case .detail:
            return "detail(todo)"
        case .todoAdd:
            return "todoAdd"
        }
    }
}
