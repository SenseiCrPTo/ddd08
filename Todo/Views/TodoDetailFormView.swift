// MARK: - TodoDetailFormView.swift
import SwiftUI

struct TodoDetailFormView: View {
    @ObservedObject var viewModel: TodoDetailViewModel
    @Binding var isProjectPickerPresented: Bool

    var body: some View {
        Form {
            Section(header: Text("Задача")) {
                TextField("Название задачи", text: $viewModel.title)
                Toggle("Важно", isOn: $viewModel.isImportant)
                Toggle("Завершено", isOn: $viewModel.isCompleted)
            }

            Section(header: Text("Детали")) {
                let dueDateBinding = Binding<Date>(
                    get: {
                        viewModel.dueDate ?? Date()
                    },
                    set: { newValue in
                        viewModel.dueDate = newValue
                    }
                )

                DatePicker(
                    "Дата",
                    selection: dueDateBinding,
                    displayedComponents: [.date, .hourAndMinute]
                )
            }

            Section(header: Text("Группа")) {
                Button {
                    isProjectPickerPresented = true
                } label: {
                    HStack {
                        Text(viewModel.selectedProject?.name ?? "Выбрать группу")
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                }
            }
        }
    }
}
