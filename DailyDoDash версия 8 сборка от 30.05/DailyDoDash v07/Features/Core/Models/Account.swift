// Core/Models/Account.swift
import Foundation
import SwiftData

@Model
final class Account {
    @Attribute(.unique) var id: UUID
    var name: String
    var accountUsageTypeRawValue: String
    var currencyCode: String = "RUB" // Значение по умолчанию ВАЖНО
    var iconName: String?
    var initialBalance: Double
    var creationDate: Date

    var accountUsageType: AccountUsageType {
        get { AccountUsageType(rawValue: accountUsageTypeRawValue) ?? .expenseSource }
        set { accountUsageTypeRawValue = newValue.rawValue }
    }

    @Relationship(deleteRule: .nullify, inverse: \FinancialTransaction.account)
    var transactions: [FinancialTransaction]? = []

    init(id: UUID = UUID(),
         name: String = "",
         accountUsageType: AccountUsageType = .expenseSource,
         currencyCode: String = "RUB", // Параметр для установки
         iconName: String? = nil,
         initialBalance: Double = 0.0,
         creationDate: Date = Date()) {
        self.id = id
        self.name = name
        self.accountUsageTypeRawValue = accountUsageType.rawValue
        self.currencyCode = currencyCode // Присваиваем переданное значение
        self.iconName = iconName
        self.initialBalance = initialBalance
        self.creationDate = creationDate
    }
}
