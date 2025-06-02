import Foundation
import SwiftData

@Model
final class ProjectModel: Identifiable, Hashable {
    @Attribute(.unique)
    var id: UUID

    var name: String
    var colorHex: String?
    var createdAt: Date

    // Убрали Relationship, теперь просто список task UUIDs
    var todoIDs: [UUID]

    init(
        id: UUID = UUID(),
        name: String,
        colorHex: String? = nil,
        createdAt: Date = .now,
        todoIDs: [UUID] = []
    ) {
        self.id = id
        self.name = name
        self.colorHex = colorHex
        self.createdAt = createdAt
        self.todoIDs = todoIDs
    }

    // MARK: - Hashable & Equatable

    static func == (lhs: ProjectModel, rhs: ProjectModel) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
