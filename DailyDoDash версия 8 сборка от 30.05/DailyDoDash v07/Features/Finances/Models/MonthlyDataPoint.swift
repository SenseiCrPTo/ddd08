// Features/Finances/Models/MonthlyDataPoint.swift
import Foundation

struct MonthlyDataPoint: Identifiable {
    let id: UUID // Объявляем как константу, значение будет присвоено в init
    let month: String
    let date: Date
    let value: Double
    var type: String // "Доход", "Расход", "Накопления"

    // Инициализатор
    init(id: UUID = UUID(), // Параметр id имеет значение по умолчанию
         month: String,
         date: Date,
         value: Double,
         type: String) {
        self.id = id // Теперь это корректная инициализация константы id
        self.month = month
        self.date = date
        self.value = value
        self.type = type
    }
}
