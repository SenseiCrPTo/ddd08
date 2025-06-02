// MARK: - TodoTypes.swift

import Foundation

struct Subtask: Identifiable, Hashable {
    let id: UUID
    var title: String
    var isCompleted: Bool
}

enum RepeatOption: String, CaseIterable, Identifiable {
    case none = "Не повторять"
    case daily = "Каждый день"
    case weekly = "Каждую неделю"
    case monthly = "Каждый месяц"
    case custom = "Настроить..."

    var id: String { rawValue }
}
