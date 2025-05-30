// Core/DataStores_Legacy/DiaryDataStore.swift
import SwiftUI

class DiaryDataStore: ObservableObject {
    // Свойства для DiaryWidgetView
    var mainMoodDisplay: (icon: String?, name: String, color: Color?) { (nil, "Нет данных", nil) }
    var latestEntryExcerpt: String { "Нет записей." }
    var reminderText: String { "Добавьте запись." }
    // Добавьте другие @Published свойства или методы, если они используются

    static var preview: DiaryDataStore {
        DiaryDataStore()
    }
}
