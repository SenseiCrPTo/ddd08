// Core/Models/FinancialTransaction.swift
import Foundation
import SwiftData

@Model
final class FinancialTransaction {
    @Attribute(.unique) var id: UUID
    var timestamp: Date
    var amount: Double
    var transactionDescription: String
    var type: TransactionType
    var currencyCode: String = "RUB" // <--- ВАЖНО: Значение по умолчанию при объявлении

    var category: TransactionCategory?
    var account: Account?
    
    var toAccount: Account?
    var amountTo: Double?
    var currencyToCode: String?
    var exchangeRate: Double?

    init(id: UUID = UUID(),
         timestamp: Date = Date(),
         amount: Double = 0.0,
         transactionDescription: String = "",
         type: TransactionType,
         currencyCode: String = "RUB", // <--- Значение по умолчанию в init
         category: TransactionCategory? = nil,
         account: Account? = nil,
         toAccount: Account? = nil,
         amountTo: Double? = nil,
         currencyToCode: String? = nil,
         exchangeRate: Double? = nil) {
        self.id = id
        self.timestamp = timestamp
        self.amount = abs(amount)
        self.transactionDescription = transactionDescription
        self.type = type
        self.currencyCode = currencyCode // <--- Присваиваем
        self.category = category
        self.account = account
        
        if type == .transfer {
            self.toAccount = toAccount
            self.amountTo = amountTo != nil ? abs(amountTo!) : nil
            self.currencyToCode = currencyToCode
            self.exchangeRate = exchangeRate
            self.category = nil
        } else {
            self.toAccount = nil
            self.amountTo = nil
            self.currencyToCode = nil
            self.exchangeRate = nil
        }
    }

    var isExpense: Bool {
        return type == .expense
    }

    var signedAmount: Double {
        switch type {
        case .income:
            return abs(amount)
        case .expense:
            return -abs(amount)
        case .transfer:
            return -abs(amount)
        }
    }
    
    var effectiveAmountForDisplay: Double {
        return abs(amount)
    }
}
