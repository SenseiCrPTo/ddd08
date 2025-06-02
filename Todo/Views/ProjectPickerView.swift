import SwiftUI

struct ProjectPickerView: View {
    @Binding var selectedProject: ProjectModel?
    @Binding var showNewProjectSheet: Bool

    let projects: [ProjectModel]

    var body: some View {
        NavigationView {
            List {
                ForEach(projects, id: \.id) { project in
                    Button(action: {
                        selectedProject = project
                    }) {
                        HStack {
                            Text(project.name)
                            if selectedProject?.id == project.id {
                                Spacer()
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }

                Button("Создать новую группу") {
                    showNewProjectSheet = true
                }
                .foregroundColor(.blue)
            }
            .navigationTitle("Выбор группы")
        }
    }
}
