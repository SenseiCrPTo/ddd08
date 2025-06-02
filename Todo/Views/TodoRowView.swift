import SwiftUI
import SwiftData

struct TodoRowView: View {
    let todo: Todo
    @ObservedObject var viewModel: TodoListViewModel

    var body: some View {
        HStack(spacing: 12) {
            Button(action: {
                viewModel.toggleCompletion(for: todo)
            }) {
                Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(todo.isCompleted ? .green : (todo.isImportant ? .orange : .secondary))
                    .imageScale(.large)
            }
            .buttonStyle(PlainButtonStyle())

            VStack(alignment: .leading, spacing: 4) {
                Text(todo.title)
                    .font(.body)
                    .foregroundColor(todo.isCompleted ? .gray : .primary)
                    .strikethrough(todo.isCompleted)
                    .lineLimit(1)

                if let due = todo.dueDate {
                    Text(due.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            if todo.isImportant && !todo.isCompleted {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
            }
        }
        .padding(.vertical, 6)
        .contentShape(Rectangle())
        .onTapGesture {
            viewModel.showDetail(todo: todo)
        }
    }
}
