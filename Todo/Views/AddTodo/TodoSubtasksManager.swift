// MARK: - TodoSubtasksManager.swift

import Foundation
import SwiftUI

@MainActor
final class TodoSubtasksManager: ObservableObject {
    @Published var subtasks: [Subtask] = []

    func addSubtask() {
        subtasks.append(Subtask(id: UUID(), title: "", isCompleted: false))
    }

    func removeSubtask(_ index: Int) {
        guard subtasks.indices.contains(index) else { return }
        subtasks.remove(at: index)
    }

    func moveSubtask(from source: IndexSet, to destination: Int) {
        subtasks.move(fromOffsets: source, toOffset: destination)
    }
}
