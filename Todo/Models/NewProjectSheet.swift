import SwiftUI
import SwiftData

struct NewProjectSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var name = ""
    @State private var colorHex = "#4287f5"

    var onCreated: () -> Void

    var body: some View {
        NavigationView {
            Form {
                TextField("Название группы", text: $name)
                TextField("Цвет (Hex)", text: $colorHex)
            }
            .navigationTitle("Новая группа")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") {
                        let repo = ProjectRepository(modelContext: modelContext) // ← Исправлено
                        repo.addProject(name: name, colorHex: colorHex)
                        onCreated()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
            }
        }
    }
}
