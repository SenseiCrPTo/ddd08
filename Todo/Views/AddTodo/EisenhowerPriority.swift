// MARK: - EisenhowerPriority.swift
import Foundation

enum EisenhowerPriority: String, CaseIterable, Identifiable {
    case urgentImportant = "Срочно и важно"
    case notUrgentImportant = "Не срочно, но важно"
    case urgentNotImportant = "Срочно, но не важно"
    case notUrgentNotImportant = "Не срочно и не важно"

    var id: String { self.rawValue }
}
