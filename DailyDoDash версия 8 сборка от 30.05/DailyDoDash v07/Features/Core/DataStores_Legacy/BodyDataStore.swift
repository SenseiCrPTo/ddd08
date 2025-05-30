// Core/DataStores_Legacy/BodyDataStore.swift
import SwiftUI

class BodyDataStore: ObservableObject {
    // Свойства для BodyWidgetView
    var currentWeightString: String { "N/A" }
    var totalTrainingDays: Int { 0 }
    var targetWorkoutsPerWeek: Int { 0 }
    var workoutsThisWeekCount: Int { 0 }
    // Добавьте другие @Published свойства или методы, если они используются

    static var preview: BodyDataStore {
        BodyDataStore()
    }
}
