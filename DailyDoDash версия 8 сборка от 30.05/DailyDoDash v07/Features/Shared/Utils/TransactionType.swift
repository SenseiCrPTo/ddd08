// Shared/Utils/TransactionType.swift (или где он у вас)
import Foundation

enum TransactionType: String, Codable, CaseIterable, Identifiable {
    case income = "Доход"
    case expense = "Расход"
    case transfer = "Перевод" // <--- НОВЫЙ КЕЙС

    var id: String { self.rawValue }
}
