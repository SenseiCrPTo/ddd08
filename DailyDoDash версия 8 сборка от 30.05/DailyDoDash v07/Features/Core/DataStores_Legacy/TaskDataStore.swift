// Core/DataStores_Legacy/TaskDataStore.swift
import SwiftUI
import SwiftData // Может понадобиться, если Todo используется в preview данных

// Убедитесь, что ваша SwiftData модель Todo.swift определена и добавлена в таргет
// @Model final class Todo { ... }

class TaskDataStore: ObservableObject {
    // Свойства для TasksWidgetView
    var monthlyTaskStatsForWidget: (completed: Int, total: Int) { (2, 5) } // Пример данных
    
    // ИСПОЛЬЗУЕМ Todo вместо Task
    var topMonthlyGoalsForWidget: [Todo] { // <--- ИЗМЕНЕНО НА Todo
        // Для превью можно возвращать пустой массив или создать моковые Todo,
        // но создание @Model объектов вне ModelContext может быть сложным для заглушки.
        // Если Todo.swift определен, можно попробовать так:
        // [Todo(title: "Превью: Главная цель месяца", isImportant: true, isMonthlyGoal: true)]
        return []
    }
    
    var tasksDueTodayForWidget: [Todo] { // <--- ИЗМЕНЕНО НА Todo
        // Аналогично, для превью
        // [Todo(title: "Превью: Задача на сегодня", dueDate: Date())]
        return []
    }
    // Добавьте другие @Published свойства или методы, если они используются

    static func previewWithWidgetData() -> TaskDataStore {
        let store = TaskDataStore()
        // Если нужны моковые данные для Todo, их нужно создать.
        // Это может потребовать ModelContext, если вы создаете реальные @Model объекты.
        // Для простой заглушки DataStore, которая не работает с реальной базой,
        // можно оставить массивы пустыми или создать простые структуры, имитирующие Todo,
        // но тогда тип свойств должен быть изменен.
        // Поскольку мы используем [Todo], то для корректного превью,
        // TasksWidgetView_Previews должен будет создавать ModelContainer и передавать
        // TasksWidgetViewModel, который уже работает с SwiftData.
        // Эта заглушка TaskDataStore становится все менее актуальной.
        return store
    }
    
    // Если у вас был массив tasks для хранения всех задач:
    // @Published var tasks: [Todo] = [] // <--- ИЗМЕНЕНО НА Todo
}
