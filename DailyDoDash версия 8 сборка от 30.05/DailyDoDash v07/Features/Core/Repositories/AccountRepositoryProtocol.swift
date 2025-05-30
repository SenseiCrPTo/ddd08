// Core/Repositories/AccountRepositoryProtocol.swift
import Foundation
import SwiftData

protocol AccountRepositoryProtocol {
    func fetchAccounts(ofType usageType: AccountUsageType?) async throws -> [Account]
    func accountExists(name: String, usageType: AccountUsageType, excludingId: UUID?) async throws -> Bool
    
    // Убираем colorHex
    func addAccount(name: String,
                    usageType: AccountUsageType,
                    initialBalance: Double,
                    iconName: String?,
                    /*colorHex: String?,*/ // <--- УБРАНО
                    currencyCode: String) async throws -> Account
    
    // Убираем newColorHex
    func updateAccount(_ account: Account,
                       newName: String,
                       newUsageType: AccountUsageType,
                       newInitialBalance: Double?,
                       newIconName: String?,
                       /*newColorHex: String?,*/ // <--- УБРАНО
                       newCurrencyCode: String) async throws
                       
    func deleteAccount(_ account: Account) async throws
    func isAccountUsed(_ account: Account) async throws -> Bool
}
