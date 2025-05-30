// Core/Models/Item.swift
import Foundation
import SwiftData

@Model
final class Item {
    var id: UUID
    var timestamp: Date
    var name: String // Добавил для примера

    init(id: UUID = UUID(), timestamp: Date = Date(), name: String = "Default Item") {
        self.id = id
        self.timestamp = timestamp
        self.name = name
    }
}
