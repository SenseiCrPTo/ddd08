import SwiftUI
import SwiftData

struct TodoWidgetRow: View {
    let todo: Todo

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
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .font(.caption2)
            }
        }
    }
}

struct TodoWidgetRow_Previews: PreviewProvider {
    @MainActor
    static var previews: some View {
        let container = try! ModelContainer(for: Todo.self)
        let context = container.mainContext

        let sampleTaskCompleted = Todo(title: "✅ Выполнено", isImportant: true, isCompleted: true)
        let sampleTaskPending = Todo(title: "📌 Не выполнено", isImportant: false)
        let sampleTaskImportant = Todo(title: "🔥 Важная задача", isImportant: true)

        return VStack(alignment: .leading, spacing: 10) {
            TodoWidgetRow(todo: sampleTaskCompleted)
            TodoWidgetRow(todo: sampleTaskPending)
            TodoWidgetRow(todo: sampleTaskImportant)
        }
        .padding()
        .modelContainer(container)
    }
}
