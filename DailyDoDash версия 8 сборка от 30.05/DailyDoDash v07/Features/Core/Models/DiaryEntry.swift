// Core/Models/DiaryEntry.swift
import Foundation
import SwiftData

@Model
final class DiaryEntry {
    @Attribute(.unique) var id: UUID
    var timestamp: Date          // Дата и время записи
    var textContent: String      // Основной текст записи
    var moodRating: Int?         // Оценка настроения, например 1-5 (или строка, или enum)
    var moodIconName: String?    // Имя системной иконки для настроения (например, "face.smiling")
    var moodColorHex: String?    // Цвет для настроения в HEX
    var photoData: Data?         // Для хранения изображения (если нужно)
    // Можно добавить теги, местоположение и т.д.

    init(id: UUID = UUID(),
         timestamp: Date = Date(),
         textContent: String = "",
         moodRating: Int? = nil,
         moodIconName: String? = nil,
         moodColorHex: String? = nil,
         photoData: Data? = nil) {
        self.id = id
        self.timestamp = timestamp
        self.textContent = textContent
        self.moodRating = moodRating
        self.moodIconName = moodIconName
        self.moodColorHex = moodColorHex
        self.photoData = photoData
    }
}
