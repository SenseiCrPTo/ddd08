import Foundation
import SwiftData

@Model
final class Todo: Identifiable, Hashable {
    @Attribute(.unique)
    var id: UUID

    var title: String
    var isImportant: Bool
    var isCompleted: Bool
    var dueDate: Date?
    var createdAt: Date
    var goalHorizon: GoalHorizon?

    // Временная связь с ProjectModel без использования @Relationship
    var projectID: UUID?
    var projectName: String?

    init(
        id: UUID = UUID(),
        title: String,
        isImportant: Bool = false,
        isCompleted: Bool = false,
        dueDate: Date? = nil,
        createdAt: Date = .now,
        goalHorizon: GoalHorizon? = nil,
        projectID: UUID? = nil,
        projectName: String? = nil
    ) {
        self.id = id
        self.title = title
        self.isImportant = isImportant
        self.isCompleted = isCompleted
        self.dueDate = dueDate
        self.createdAt = createdAt
        self.goalHorizon = goalHorizon
        self.projectID = projectID
        self.projectName = projectName
    }

    // MARK: - Hashable & Equatable

    static func == (lhs: Todo, rhs: Todo) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
