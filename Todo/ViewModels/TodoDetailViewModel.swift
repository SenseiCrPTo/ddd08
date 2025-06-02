// MARK: - TodoDetailViewModel.swift
import Foundation
import SwiftData
import Combine

@MainActor
final class TodoDetailViewModel: ObservableObject {
    @Published var title: String
    @Published var isImportant: Bool
    @Published var isCompleted: Bool
    @Published var dueDate: Date
    @Published var selectedProject: ProjectModel?

    private var todo: Todo?

    var isNewTodo: Bool {
        todo == nil
    }

    init(todo: Todo? = nil, project: ProjectModel? = nil) {
        self.todo = todo
        self.title = todo?.title ?? ""
        self.isImportant = todo?.isImportant ?? false
        self.isCompleted = todo?.isCompleted ?? false
        self.dueDate = todo?.dueDate ?? .now
        self.selectedProject = project
    }

    func save(modelContext: ModelContext) {
        if let todo {
            todo.title = title
            todo.isImportant = isImportant
            todo.isCompleted = isCompleted
            todo.dueDate = dueDate
            todo.projectID = selectedProject?.id
            todo.projectName = selectedProject?.name
        } else {
            let newTodo = Todo(
                title: title,
                isImportant: isImportant,
                isCompleted: isCompleted,
                dueDate: dueDate,
                projectID: selectedProject?.id,
                projectName: selectedProject?.name
            )
            modelContext.insert(newTodo)
        }

        try? modelContext.save()
    }
}
