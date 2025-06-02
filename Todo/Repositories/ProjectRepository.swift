import Foundation
import SwiftData

@MainActor
final class ProjectRepository {
    private var modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchAllProjects() -> [ProjectModel] {
        let descriptor = FetchDescriptor<ProjectModel>(sortBy: [SortDescriptor(\ProjectModel.createdAt)])
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func addProject(name: String, colorHex: String = "#4287f5") {
        let project = ProjectModel(name: name, colorHex: colorHex)
        modelContext.insert(project)
    }

    func deleteProject(_ project: ProjectModel) {
        modelContext.delete(project)
    }
}
