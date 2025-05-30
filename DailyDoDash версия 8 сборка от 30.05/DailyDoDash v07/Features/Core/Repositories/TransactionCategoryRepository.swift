// Core/Repositories/TransactionCategoryRepository.swift
import Foundation
import SwiftData

// Убедитесь, что TransactionCategoryRepositoryProtocol.swift и RepositoryError.swift существуют и в таргете

actor TransactionCategoryRepositoryImpl: TransactionCategoryRepositoryProtocol {
    private var modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchCategories(ofType type: TransactionType? = nil) async throws -> [TransactionCategory] {
        var descriptor: FetchDescriptor<TransactionCategory>
        if let targetType = type {
            let targetTypeRawValue = targetType.rawValue
            let predicate = #Predicate<TransactionCategory> { categoryEntity in
                categoryEntity.typeRawValue == targetTypeRawValue
            }
            descriptor = FetchDescriptor<TransactionCategory>(predicate: predicate, sortBy: [SortDescriptor(\.name)])
        } else {
            descriptor = FetchDescriptor<TransactionCategory>(sortBy: [SortDescriptor(\.name)])
        }
        
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("Ошибка загрузки категорий: \(error)")
            throw RepositoryError.fetchFailed(error.localizedDescription)
        }
    }

    func categoryExists(name: String, type: TransactionType, excludingId: UUID? = nil) async throws -> Bool {
        let targetName = name
        let targetTypeRawValue = type.rawValue
        
        let predicate: Predicate<TransactionCategory>
        if let idToExclude = excludingId {
            predicate = #Predicate<TransactionCategory> { categoryEntity in
                categoryEntity.name == targetName &&
                categoryEntity.typeRawValue == targetTypeRawValue &&
                categoryEntity.id != idToExclude
            }
        } else {
            predicate = #Predicate<TransactionCategory> { categoryEntity in
                categoryEntity.name == targetName &&
                categoryEntity.typeRawValue == targetTypeRawValue
            }
        }
        var descriptor = FetchDescriptor<TransactionCategory>(predicate: predicate)
        descriptor.fetchLimit = 1
        
        do {
            let count = try modelContext.fetchCount(descriptor)
            return count > 0
        } catch {
            print("Ошибка проверки существования категории: \(error)")
            throw RepositoryError.fetchFailed(error.localizedDescription)
        }
    }

    func isCategoryUsed(_ category: TransactionCategory) async throws -> Bool {
        let categoryId = category.id
        // Убедитесь, что FinancialTransaction.category.id доступно для предиката
        // Если category в FinancialTransaction опционально, то и доступ к id должен быть опциональным
        let predicate = #Predicate<FinancialTransaction> { transaction in
            transaction.category?.id == categoryId
        }
        var descriptor = FetchDescriptor<FinancialTransaction>(predicate: predicate)
        descriptor.fetchLimit = 1
        
        do {
            let count = try modelContext.fetchCount(descriptor)
            return count > 0
        } catch {
            print("Ошибка проверки использования категории: \(error)")
            throw RepositoryError.fetchFailed("Не удалось проверить использование категории: \(error.localizedDescription)")
        }
    }

    func addCategory(name: String, type: TransactionType, iconName: String?, colorHex: String?) async throws -> TransactionCategory {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            throw RepositoryError.unknown("Имя категории не может быть пустым.")
        }
        if try await categoryExists(name: trimmedName, type: type, excludingId: nil) {
            throw RepositoryError.alreadyExists
        }
        
        let newCategory = TransactionCategory(name: trimmedName, type: type, iconName: iconName, colorHex: colorHex)
        modelContext.insert(newCategory)
        
        do {
            try modelContext.save()
            return newCategory
        } catch {
            modelContext.rollback()
            throw RepositoryError.saveFailed(error.localizedDescription)
        }
    }

    func updateCategory(_ category: TransactionCategory, newName: String, newType: TransactionType, newIconName: String?, newColorHex: String?) async throws {
        let trimmedNewName = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedNewName.isEmpty else {
            throw RepositoryError.unknown("Новое имя категории не может быть пустым.")
        }

        if category.name != trimmedNewName || category.type != newType {
            if try await categoryExists(name: trimmedNewName, type: newType, excludingId: category.id) {
                throw RepositoryError.alreadyExists
            }
        }
        
        let savingCategoryNameGlobal = "Накопления"
        if category.name.lowercased() == savingCategoryNameGlobal.lowercased() &&
           (trimmedNewName.lowercased() != savingCategoryNameGlobal.lowercased() || newType != .expense) {
            throw RepositoryError.unknown("Категорию 'Накопления' нельзя переименовать или изменить ее тип.")
        }

        category.name = trimmedNewName
        category.type = newType
        category.iconName = newIconName
        category.colorHex = newColorHex
        
        do {
            try modelContext.save()
        } catch {
            modelContext.rollback()
            throw RepositoryError.saveFailed(error.localizedDescription)
        }
    }

    func deleteCategory(_ category: TransactionCategory) async throws {
        let savingCategoryNameGlobal = "Накопления"
        if category.name.lowercased() == savingCategoryNameGlobal.lowercased() {
            throw RepositoryError.unknown("Категорию 'Накопления' нельзя удалить.")
        }

        // Проверка использования категории перед удалением
        if try await isCategoryUsed(category) {
            // ИСПОЛЬЗУЕМ ВАШЕ СООБЩЕНИЕ
            throw RepositoryError.entityInUse(message: "Ошибка. Перед удалением категории перенесите все транзакции, связанные с ней, в другую категорию.")
        }

        modelContext.delete(category)
        do {
            try modelContext.save()
        } catch {
            modelContext.rollback()
            throw RepositoryError.deleteFailed(error.localizedDescription)
        }
    }
}
