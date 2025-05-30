// Core/Repositories/TransactionCategoryRepositoryProtocol.swift
import Foundation
import SwiftData

// Определение enum RepositoryError теперь находится в отдельном файле RepositoryError.swift
// и должно быть доступно здесь, если RepositoryError.swift добавлен в таргет.

protocol TransactionCategoryRepositoryProtocol {
    func fetchCategories(ofType type: TransactionType?) async throws -> [TransactionCategory]
    func categoryExists(name: String, type: TransactionType, excludingId: UUID?) async throws -> Bool
    func addCategory(name: String, type: TransactionType, iconName: String?, colorHex: String?) async throws -> TransactionCategory
    func updateCategory(_ category: TransactionCategory, newName: String, newType: TransactionType, newIconName: String?, newColorHex: String?) async throws
    func deleteCategory(_ category: TransactionCategory) async throws
    func isCategoryUsed(_ category: TransactionCategory) async throws -> Bool
}
