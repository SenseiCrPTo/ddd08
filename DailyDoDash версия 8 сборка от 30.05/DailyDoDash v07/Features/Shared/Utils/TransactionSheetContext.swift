// Shared/Utils/TransactionSheetContext.swift
import Foundation
import SwiftData // Для FinancialTransaction

// Использует FinancialTransaction (@Model) и TransactionType (enum)
struct TransactionSheetContext: Identifiable {
    let id = UUID()
    var type: TransactionType
    var category: TransactionCategory? // Теперь это опциональная SwiftData модель TransactionCategory
    var transactionToEdit: FinancialTransaction? // Теперь это опциональная SwiftData модель

    // Инициализатор для новой транзакции
    init(type: TransactionType, category: TransactionCategory? = nil) {
        self.type = type
        self.category = category
        self.transactionToEdit = nil
    }

    // Инициализатор для редактирования существующей транзакции
    init(transactionToEdit: FinancialTransaction) {
        self.type = transactionToEdit.type
        self.category = transactionToEdit.category
        self.transactionToEdit = transactionToEdit
    }
}
