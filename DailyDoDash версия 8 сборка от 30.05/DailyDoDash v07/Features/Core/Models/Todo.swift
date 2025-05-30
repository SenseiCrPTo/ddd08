// Core/Models/Todo.swift
import Foundation
import SwiftData

@Model
final class Todo { // <--- ИМЯ КЛАССА ИЗМЕНЕНО НА Todo
    @Attribute(.unique) var id: UUID
    var title: String
    var isCompleted: Bool
    var dueDate: Date?          // Срок выполнения (опционально)
    var creationDate: Date    // Дата создания
    var isImportant: Bool       // Флаг важности
    var isMonthlyGoal: Bool     // Является ли задачей-целью на месяц
    var isArchived: Bool        // В архиве ли задача
    var priority: Int           // Приоритет (например, 0 - нет, 1 - низкий, ..., 3 - высокий)
    var notes: String?          // Дополнительные заметки
    
    // Опциональная связь с проектом (если у вас будет модель Project)
    // var project: Project?

    init(id: UUID = UUID(),
         title: String = "",
         isCompleted: Bool = false,
         dueDate: Date? = nil,
         creationDate: Date = Date(),
         isImportant: Bool = false,
         isMonthlyGoal: Bool = false,
         isArchived: Bool = false, // <--- Добавлено в init
         priority: Int = 0,
         notes: String? = nil
         /* project: Project? = nil */ ) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.dueDate = dueDate
        self.creationDate = creationDate
        self.isImportant = isImportant
        self.isMonthlyGoal = isMonthlyGoal
        self.isArchived = isArchived // <--- Добавлено в init
        self.priority = priority
        self.notes = notes
        // self.project = project
    }
}
