import SwiftUI

struct TodoAddView: View {
    @ObservedObject var viewModel: TodoAddViewModel

    var body: some View {
        Form {
            Section(header: Text("Заголовок")) {
                TextField("Новая задача", text: $viewModel.title)
            }

            SubtaskListView(
                subtasks: $viewModel.subtasksManager.subtasks,
                addSubtask: viewModel.subtasksManager.addSubtask,
                removeSubtask: viewModel.subtasksManager.removeSubtask,
                moveSubtask: viewModel.subtasksManager.moveSubtask
            )

            Section(header: Text("Дата и время")) {
                DatePicker("Дата", selection: $viewModel.dueDate, displayedComponents: [.date, .hourAndMinute])
            }

            Section(header: Text("Приоритет")) {
                PriorityPickerView(priority: $viewModel.priority)
            }

            Section(header: Text("Дедлайн")) {
                DatePicker("Конечный срок", selection: $viewModel.deadline)
            }

            Section(header: Text("Оценка времени")) {
                Stepper(value: $viewModel.estimatedMinutes, in: 5...240, step: 5) {
                    Text("Примерно: \(viewModel.estimatedMinutes) мин.")
                }
            }

            ReminderPickerView(viewModel: viewModel)
            TagSelectorView(viewModel: viewModel)
            RepeatingTaskView(viewModel: viewModel)
            AttachmentPickerView(viewModel: viewModel)
            NoteEditorView(text: $viewModel.notes)
        }
        .navigationTitle("Добавить задачу")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Сохранить") {
                    viewModel.save()
                }
            }
        }
    }
}
