// MARK: - TodoListViewModel.swift
import Foundation
import SwiftData

@MainActor
final class TodoListViewModel: ObservableObject {
    @Published var todos: [Todo] = []
    @Published var searchQuery: String = ""
    @Published var selectedFilter: TodoFilter = .all

    private var context: ModelContext
    weak var coordinator: TodoCoordinator?

    init(context: ModelContext, coordinator: TodoCoordinator? = nil) {
        self.context = context
        self.coordinator = coordinator
        fetchTodos()
    }

    func fetchTodos() {
        var descriptor = FetchDescriptor<Todo>()

        // Применение фильтра
        switch selectedFilter {
        case .all:
            break
        case .completed:
            descriptor.predicate = #Predicate { $0.isCompleted == true }
        case .important:
            descriptor.predicate = #Predicate { $0.isImportant == true }
        case .upcoming:
            descriptor.predicate = #Predicate { $0.dueDate != nil && $0.isCompleted == false }
        }

        do {
            var result = try context.fetch(descriptor)

            // Применение поиска
            if !searchQuery.isEmpty {
                result = result.filter { $0.title.localizedCaseInsensitiveContains(searchQuery) }
            }

            self.todos = result
        } catch {
            print("\u{274C} Ошибка загрузки Todo в списке задач: \(error)")
        }
    }

    func toggleCompletion(for todo: Todo) {
        guard let index = todos.firstIndex(where: { $0.id == todo.id }) else { return }
        todos[index].isCompleted.toggle()
        try? context.save()
    }

    func showDetail(todo: Todo) {
        coordinator?.showDetail(for: todo)
    }

    func setFilter(_ filter: TodoFilter) {
        selectedFilter = filter
        fetchTodos()
    }

    func setSearch(_ query: String) {
        searchQuery = query
        fetchTodos()
    }
}

enum TodoFilter: String, CaseIterable, Identifiable {
    case all = "Все"
    case completed = "Завершённые"
    case important = "Важные"
    case upcoming = "Сроки"

    var id: String { rawValue }
}
