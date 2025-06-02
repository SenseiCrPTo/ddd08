// MARK: - TodoDetailView.swift
import SwiftUI
import SwiftData

struct TodoDetailView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext

    @StateObject var viewModel: TodoDetailViewModel

    @State private var isProjectPickerPresented = false
    @State private var isCreatingNewProject = false
    @State private var newProjectName: String = ""

    var body: some View {
        NavigationStack {
            TodoDetailFormView(
                viewModel: viewModel,
                isProjectPickerPresented: $isProjectPickerPresented
            )
            .navigationTitle(viewModel.isNewTodo ? "Новая задача" : "Редактировать")
            .toolbar {
                TodoDetailToolbarView(
                    viewModel: viewModel,
                    dismiss: dismiss,
                    modelContext: modelContext
                )
            }
            .sheet(isPresented: $isProjectPickerPresented) {
                TodoDetailProjectSheetView(
                    viewModel: viewModel,
                    isCreatingNewProject: $isCreatingNewProject,
                    modelContext: modelContext
                )
            }
            .sheet(isPresented: $isCreatingNewProject) {
                TodoDetailNewProjectSheetView(
                    viewModel: viewModel,
                    newProjectName: $newProjectName,
                    isCreatingNewProject: $isCreatingNewProject,
                    isProjectPickerPresented: $isProjectPickerPresented,
                    modelContext: modelContext
                )
            }
        }
    }
}
