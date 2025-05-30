// Core/Models/BodyMeasurement.swift
import Foundation
import SwiftData

@Model
final class BodyMeasurement {
    @Attribute(.unique) var id: UUID
    var timestamp: Date
    var weightInKg: Double?       // Вес в кг
    var bodyFatPercentage: Double? // Процент жира
    var waistCircumferenceCm: Double? // Обхват талии в см
    var chestCircumferenceCm: Double?
    var neckCircumferenceCm: Double?
    var hipCircumferenceCm: Double?
    var isWorkoutDay: Bool        // Была ли тренировка в этот день (если это релевантно для виджета)
    var notes: String?

    init(id: UUID = UUID(),
         timestamp: Date = Date(),
         weightInKg: Double? = nil,
         bodyFatPercentage: Double? = nil,
         waistCircumferenceCm: Double? = nil,
         chestCircumferenceCm: Double? = nil,
         neckCircumferenceCm: Double? = nil,
         hipCircumferenceCm: Double? = nil,
         isWorkoutDay: Bool = false, // Добавлено
         notes: String? = nil) {
        self.id = id
        self.timestamp = timestamp
        self.weightInKg = weightInKg
        self.bodyFatPercentage = bodyFatPercentage
        self.waistCircumferenceCm = waistCircumferenceCm
        self.chestCircumferenceCm = chestCircumferenceCm
        self.neckCircumferenceCm = neckCircumferenceCm
        self.hipCircumferenceCm = hipCircumferenceCm
        self.isWorkoutDay = isWorkoutDay
        self.notes = notes
    }
}
