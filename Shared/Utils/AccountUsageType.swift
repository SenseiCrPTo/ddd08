// Shared/Utils/AccountUsageType.swift (или Core/Models/Enums/)
import Foundation

enum AccountUsageType: String, Codable, CaseIterable, Identifiable {
    case incomeSource = "Источник Дохода" // Счета, на которые в основном поступают деньги
    case expenseSource = "Источник Расходов"// Счета, с которых в основном тратятся деньги
    case savings = "Накопительный"      // Счета для сбережений

    var id: String { self.rawValue }
}
