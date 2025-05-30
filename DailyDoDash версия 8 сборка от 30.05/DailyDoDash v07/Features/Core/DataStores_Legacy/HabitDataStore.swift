// Core/DataStores_Legacy/HabitDataStore.swift
import SwiftUI // Для @Published и ObservableObject, если он используется напрямую в View

class HabitDataStore: ObservableObject {
    @Published var habits: [Habit] = [] // Habit - это ваша SwiftData модель
    // Добавьте другие @Published свойства, если они используются в превью или старом коде виджетов
    
    // Методы, которые могут вызываться в превью или старом коде
    func dailyCompletionPercentage() -> Double { return 50.0 } // Пример
    var habitsForWidget: [Habit] { Array(habits.prefix(4)) } // Пример

    // Статическое свойство для превью
    static var preview: HabitDataStore {
        let store = HabitDataStore()
        // Здесь можно добавить несколько моковых привычек, если нужно для превью
        // store.habits = [Habit(name: "Превью Привычка 1"), Habit(name: "Превью Привычка 2")]
        return store
    }

    // Добавьте другие заглушки методов, если на них ругается компилятор
}
