import SwiftUI
import SwiftData

struct TodoDetailNewProjectSheetView: View {
    @ObservedObject var viewModel: TodoDetailViewModel
    @Binding var newProjectName: String
    @Binding var isCreatingNewProject: Bool
    @Binding var isProjectPickerPresented: Bool
    let modelContext: ModelContext

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Название новой группы")) {
                    TextField("Новая группа", text: $newProjectName)
                }
            }
            .navigationTitle("Новая группа")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Создать") {
                        let newProject = ProjectModel(name: newProjectName)
                        modelContext.insert(newProject)
                        try? modelContext.save()
                        viewModel.selectedProject = newProject
                        newProjectName = ""
                        isCreatingNewProject = false
                        isProjectPickerPresented = false
                    }
                    .disabled(newProjectName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") {
                        isCreatingNewProject = false
                    }
                }
            }
        }
    }
}
