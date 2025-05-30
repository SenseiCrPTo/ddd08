// Features/Finances/Utils/EditCategorySheetContext.swift
import Foundation
import SwiftData // Для TransactionCategory

struct EditCategorySheetContext: Identifiable {
    let id = UUID()
    var categoryToEdit: TransactionCategory?
    var initialTypeForNew: TransactionType // Тип, если создается новая категория

    // Инициализатор для новой категории
    init(categoryToEdit: TransactionCategory? = nil, initialTypeForNew: TransactionType = .expense) { // По умолчанию расход
        self.categoryToEdit = categoryToEdit
        // Если редактируем, тип берется из категории, иначе из initialTypeForNew
        self.initialTypeForNew = categoryToEdit?.type ?? initialTypeForNew
    }
}
