// Core/Models/HabitCompletionLog.swift
import Foundation
import SwiftData

@Model
final class HabitCompletionLog {
    var id: UUID                  // <--- ДОБАВЛЕНО
    var date: Date
    var isCompleted: Bool
    
    var habit: Habit?

    init(id: UUID = UUID(), // <--- ДОБАВЛЕНО
         date: Date = Calendar.current.startOfDay(for: Date()),
         isCompleted: Bool = true) {
        self.id = id // <--- ДОБАВЛЕНО
        self.date = date
        self.isCompleted = isCompleted
    }
}
