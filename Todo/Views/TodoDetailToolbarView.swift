// MARK: - TodoDetailToolbarView.swift
import SwiftUI
import SwiftData

struct TodoDetailToolbarView: ToolbarContent {
    @ObservedObject var viewModel: TodoDetailViewModel
    var dismiss: DismissAction
    var modelContext: ModelContext

    var body: some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            Button("Сохранить") {
                viewModel.save(modelContext: modelContext)
                dismiss()
            }
            .disabled(viewModel.title.trimmingCharacters(in: .whitespaces).isEmpty)
        }

        ToolbarItem(placement: .cancellationAction) {
            Button("Отмена") {
                dismiss()
            }
        }
    }
}
