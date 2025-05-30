// Features/Dashboard/Views/Widgets/TaskWidgetRow.swift
import SwiftUI
import SwiftData

struct TaskWidgetRow: View {
    let todo: Todo // <--- ИЗМЕНЕНО НА todo: Todo

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                .foregroundColor(todo.isCompleted ? .green : (todo.isImportant ? .orange : .secondary))
            Text(todo.title)
                .font(.caption)
                .foregroundColor(todo.isCompleted ? .gray : .primary)
                .strikethrough(todo.isCompleted, color: .gray)
                .lineLimit(1)
            Spacer()
            if todo.isImportant && !todo.isCompleted {
                Image(systemName: "star.fill").foregroundColor(.yellow).font(.caption2)
            }
        }
    }
}

struct TaskWidgetRow_Previews: PreviewProvider {
    @MainActor
    static var previews: some View {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        // Используем Todo.self для ModelContainer
        let container = try! ModelContainer(for: Todo.self)
        
        // Создаем тестовые Todo объекты
        let sampleTaskCompleted = Todo(title: "Выполненная задача", isCompleted: true, isImportant: true)
        let sampleTaskPending = Todo(title: "Обычная задача", isImportant: false)
        let sampleTaskImportant = Todo(title: "Важная задача", isImportant: true)
        
        // Можно вставить их в контекст, если это нужно для превью
        // container.mainContext.insert(sampleTaskCompleted)
        // container.mainContext.insert(sampleTaskPending)
        // container.mainContext.insert(sampleTaskImportant)

        return VStack(alignment: .leading, spacing: 10) {
            TaskWidgetRow(todo: sampleTaskCompleted) // <--- ИЗМЕНЕНО НА todo
            TaskWidgetRow(todo: sampleTaskPending)   // <--- ИЗМЕНЕНО НА todo
            TaskWidgetRow(todo: sampleTaskImportant) // <--- ИЗМЕНЕНО НА todo
        }
        .padding()
        .modelContainer(container)
    }
}
