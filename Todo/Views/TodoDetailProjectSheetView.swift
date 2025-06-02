import SwiftUI
import SwiftData

struct TodoDetailProjectSheetView: View {
    @ObservedObject var viewModel: TodoDetailViewModel
    @Binding var isCreatingNewProject: Bool
    let modelContext: ModelContext

    var body: some View {
        ProjectPickerView(
            selectedProject: Binding(
                get: {
                    viewModel.selectedProject
                },
                set: { newValue in
                    viewModel.selectedProject = newValue
                }
            ),
            showNewProjectSheet: $isCreatingNewProject,
            projects: ProjectRepository(modelContext: modelContext).fetchAllProjects()
        )
    }
}
