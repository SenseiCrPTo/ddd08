// Core/Repositories/AccountRepository.swift
import Foundation
import SwiftData

actor AccountRepositoryImpl: AccountRepositoryProtocol {
    private var modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // --- ПОЛНАЯ РЕАЛИЗАЦИЯ fetchAccounts ---
    func fetchAccounts(ofType usageType: AccountUsageType? = nil) async throws -> [Account] {
        var descriptor: FetchDescriptor<Account>
        if let targetType = usageType {
            let targetTypeRawValue = targetType.rawValue
            let predicate = #Predicate<Account> { account in
                account.accountUsageTypeRawValue == targetTypeRawValue
            }
            descriptor = FetchDescriptor<Account>(predicate: predicate, sortBy: [SortDescriptor(\.name)])
        } else {
            descriptor = FetchDescriptor<Account>(sortBy: [SortDescriptor(\.name)])
        }
        
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("Ошибка загрузки счетов в AccountRepository: \(error)")
            throw RepositoryError.fetchFailed("Не удалось загрузить счета: \(error.localizedDescription)")
        }
    }

    // --- ПОЛНАЯ РЕАЛИЗАЦИЯ accountExists ---
    func accountExists(name: String, usageType: AccountUsageType, excludingId: UUID? = nil) async throws -> Bool {
        let targetName = name
        // Пока не будем проверять по usageType в предикате, чтобы имя было уникальным глобально.
        // Если нужна уникальность в рамках типа, можно добавить и сравнение account.accountUsageTypeRawValue.
        
        let predicate: Predicate<Account>
        if let idToExclude = excludingId {
            predicate = #Predicate<Account> { account in
                account.name == targetName &&
                account.id != idToExclude
            }
        } else {
            predicate = #Predicate<Account> { account in
                account.name == targetName
            }
        }
        var descriptor = FetchDescriptor<Account>(predicate: predicate)
        descriptor.fetchLimit = 1
        
        do {
            let count = try modelContext.fetchCount(descriptor)
            return count > 0
        } catch {
            print("Ошибка проверки существования счета: \(error)")
            throw RepositoryError.fetchFailed("Не удалось проверить существование счета: \(error.localizedDescription)")
        }
    }

    // --- ПОЛНАЯ РЕАЛИЗАЦИЯ isAccountUsed ---
    func isAccountUsed(_ account: Account) async throws -> Bool {
        let accountId = account.id
        let predicate = #Predicate<FinancialTransaction> { transaction in
            // Проверяем, используется ли счет как основной или как счет-получатель в переводе
            transaction.account?.id == accountId || transaction.toAccount?.id == accountId
        }
        var descriptor = FetchDescriptor<FinancialTransaction>(predicate: predicate)
        descriptor.fetchLimit = 1
        
        do {
            let count = try modelContext.fetchCount(descriptor)
            return count > 0
        } catch {
            print("Ошибка проверки использования счета: \(error)")
            throw RepositoryError.fetchFailed("Не удалось проверить использование счета: \(error.localizedDescription)")
        }
    }
    
    func addAccount(name: String,
                    usageType: AccountUsageType,
                    initialBalance: Double,
                    iconName: String?,
                    currencyCode: String) async throws -> Account { // Убрал colorHex
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            throw RepositoryError.unknown("Имя счета не может быть пустым.")
        }
        
        if try await accountExists(name: trimmedName, usageType: usageType, excludingId: nil) {
            throw RepositoryError.alreadyExists
        }

        print("DEBUG AccountRepo (addAccount): Name: \(trimmedName), UsageType: \(usageType.rawValue), CurrencyCode to save: \(currencyCode), InitialBalance: \(initialBalance)")

        let newAccount = Account(name: trimmedName,
                                 accountUsageType: usageType,
                                 currencyCode: currencyCode,
                                 iconName: iconName,
                                 initialBalance: initialBalance,
                                 creationDate: Date())
        modelContext.insert(newAccount)
        
        do {
            try modelContext.save()
            print("DEBUG AccountRepo (addAccount): Saved successfully. Account currency: \(newAccount.currencyCode)")
            return newAccount
        } catch {
            modelContext.rollback()
            print("DEBUG AccountRepo (addAccount): Save FAILED. Error: \(error)")
            throw RepositoryError.saveFailed("Не удалось сохранить новый счет: \(error.localizedDescription)")
        }
    }

    func updateAccount(_ account: Account,
                       newName: String,
                       newUsageType: AccountUsageType,
                       newInitialBalance: Double?,
                       newIconName: String?,
                       newCurrencyCode: String) async throws { // Убрал newColorHex
        let trimmedNewName = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedNewName.isEmpty else {
            throw RepositoryError.unknown("Новое имя счета не может быть пустым.")
        }

        print("DEBUG AccountRepo (updateAccount): Updating '\(account.name)'. New Name: \(trimmedNewName), New UsageType: \(newUsageType.rawValue), New CurrencyCode: \(newCurrencyCode)")

        if account.name != trimmedNewName || account.accountUsageType != newUsageType || account.currencyCode != newCurrencyCode {
            if try await accountExists(name: trimmedNewName, usageType: newUsageType, excludingId: account.id) {
                throw RepositoryError.alreadyExists
            }
        }

        account.name = trimmedNewName
        account.accountUsageType = newUsageType
        account.currencyCode = newCurrencyCode
        account.iconName = newIconName ?? account.iconName
        if let balance = newInitialBalance {
            account.initialBalance = balance
        }
        
        do {
            try modelContext.save()
            print("DEBUG AccountRepo (updateAccount): Updated successfully. Account currency: \(account.currencyCode)")
        } catch {
            modelContext.rollback()
            print("DEBUG AccountRepo (updateAccount): Update FAILED. Error: \(error)")
            throw RepositoryError.saveFailed("Не удалось обновить счет: \(error.localizedDescription)")
        }
    }

    func deleteAccount(_ account: Account) async throws {
        if try await isAccountUsed(account) {
            throw RepositoryError.entityInUse(message: "Счет '\(account.name)' используется в транзакциях и не может быть удален. Сначала перенесите или удалите связанные транзакции.")
        }
        
        modelContext.delete(account)
        do {
            try modelContext.save()
        } catch {
            modelContext.rollback()
            throw RepositoryError.deleteFailed("Не удалось удалить счет: \(error.localizedDescription)")
        }
    }
}
