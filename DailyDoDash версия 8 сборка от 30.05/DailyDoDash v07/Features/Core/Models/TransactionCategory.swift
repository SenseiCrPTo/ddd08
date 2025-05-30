// Core/Models/TransactionCategory.swift
import Foundation
import SwiftData

@Model
final class TransactionCategory {
    @Attribute(.unique) var id: UUID // Уникальный ID
    var name: String
    var typeRawValue: String // Храним rawValue как String
    var iconName: String?
    var colorHex: String?

    // Вычисляемое свойство для удобства
    var type: TransactionType {
        get { TransactionType(rawValue: typeRawValue) ?? .expense }
        set { typeRawValue = newValue.rawValue }
    }

    init(id: UUID = UUID(),
         name: String,
         type: TransactionType,
         iconName: String? = nil,
         colorHex: String? = nil) {
        self.id = id
        self.name = name
        self.typeRawValue = type.rawValue // Сохраняем rawValue
        self.iconName = iconName
        self.colorHex = colorHex
    }
}
