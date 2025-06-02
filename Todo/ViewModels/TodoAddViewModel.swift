// MARK: - TodoAddViewModel.swift

import SwiftUI
import Foundation

@MainActor
final class TodoAddViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var dueDate: Date = Date()
    @Published var deadline: Date = Date().addingTimeInterval(3600 * 24)
    @Published var priority: EisenhowerPriority = .notUrgentNotImportant
    @Published var estimatedMinutes: Int = 30
    @Published var reminderEnabled: Bool = false
    @Published var tags: [String] = []
    @Published var repeatOption: RepeatOption = .none
    @Published var notes: String = ""
    @Published var attachments: [URL] = []

    @Published var subtasksManager = TodoSubtasksManager()

    func save() {
        print("✅ Сохранена задача: \(title) с \(subtasksManager.subtasks.count) подзадачами")
        // TODO: Внедри сохранение через TaskRepository
    }
}
