// ✅ SubTodo.swift
import Foundation
import SwiftData

@Model
final class SubTodo: Identifiable, Hashable {
    @Attribute(.unique) var id: UUID
    var title: String
    var isCompleted: Bool
    
    var parentID: UUID?

    init(id: UUID = UUID(), title: String, isCompleted: Bool = false, parentID: UUID? = nil) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.parentID = parentID
    }

    static func == (lhs: SubTodo, rhs: SubTodo) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
