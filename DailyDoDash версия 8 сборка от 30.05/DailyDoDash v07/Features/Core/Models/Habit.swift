// Core/Models/Habit.swift
import Foundation
import SwiftData

@Model
final class Habit {
    @Attribute(.unique) var id: UUID
    var name: String
    var iconName: String
    var colorHex: String
    var creationDate: Date
    var isArchived: Bool
    var order: Int
    
    private var _scheduleDaysData: Data?
    
    var scheduleDays: [Int]? {
        get {
            guard let data = _scheduleDaysData else { return nil }
            return try? JSONDecoder().decode([Int].self, from: data)
        }
        set {
            if let newSchedule = newValue {
                _scheduleDaysData = try? JSONEncoder().encode(newSchedule)
            } else {
                _scheduleDaysData = nil
            }
        }
    }
    
    @Relationship(deleteRule: .cascade, inverse: \HabitCompletionLog.habit)
    var completionLogs: [HabitCompletionLog]? = []

    var showInWidget: Bool

    init(id: UUID = UUID(),
         name: String = "",
         iconName: String = "questionmark.circle",
         colorHex: String = "#FFFFFF",
         creationDate: Date = Date(),
         isArchived: Bool = false,
         order: Int = 0,
         scheduleDays: [Int]? = nil,
         showInWidget: Bool = true) {
        self.id = id
        self.name = name
        self.iconName = iconName
        self.colorHex = colorHex
        self.creationDate = creationDate
        self.isArchived = isArchived
        self.order = order
        self.showInWidget = showInWidget // <--- ИНИЦИАЛИЗИРУЕМ showInWidget РАНЬШЕ
        
        // Теперь, когда все хранимые свойства инициализированы,
        // можно безопасно вызывать сеттер для scheduleDays.
        // _scheduleDaysData будет инициализировано через этот сеттер.
        if let schedule = scheduleDays { // Присваиваем _scheduleDaysData напрямую, если это возможно
            self._scheduleDaysData = try? JSONEncoder().encode(schedule)
        } else {
            self._scheduleDaysData = nil
        }
        // Или, если хотим использовать сеттер:
        // self.scheduleDays = scheduleDays // Это должно быть безопасно сейчас
    }
}
