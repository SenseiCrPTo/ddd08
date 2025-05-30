// Features/Finances/ViewModels/AccountsViewModel.swift
import SwiftUI
import SwiftData
import Combine

@MainActor
class AccountsViewModel: ObservableObject {
    var modelContext: ModelContext
    private var accountRepository: AccountRepositoryProtocol
    private weak var coordinator: FinancesCoordinator?

    @Published var incomeSourceAccounts: [Account] = []
    @Published var expenseSourceAccounts: [Account] = []
    @Published var savingsAccounts: [Account] = []
    
    @Published var sheetContext: EditAccountSheetContext? = nil
    @Published var isLoading: Bool = false
    @Published var accountToDeleteAlert: Account? = nil
    @Published var errorMessage: String? = nil

    init(accountRepository: AccountRepositoryProtocol, modelContext: ModelContext, coordinator: FinancesCoordinator?) {
        self.accountRepository = accountRepository
        self.modelContext = modelContext
        self.coordinator = coordinator
        fetchAccounts()
    }

    func fetchAccounts() {
        Task {
            isLoading = true
            errorMessage = nil
            do {
                let fetchedIncome = try await accountRepository.fetchAccounts(ofType: .incomeSource)
                self.incomeSourceAccounts = fetchedIncome
                // --- DEBUG PRINT ---
                print("DEBUG AccountsVM: Fetched Income Accounts:")
                fetchedIncome.forEach { print("  Name: \($0.name), Currency: \($0.currencyCode)") }
                // --- END DEBUG PRINT ---

                let fetchedExpense = try await accountRepository.fetchAccounts(ofType: .expenseSource)
                self.expenseSourceAccounts = fetchedExpense
                // --- DEBUG PRINT ---
                print("DEBUG AccountsVM: Fetched Expense Accounts:")
                fetchedExpense.forEach { print("  Name: \($0.name), Currency: \($0.currencyCode)") }
                // --- END DEBUG PRINT ---

                let fetchedSavings = try await accountRepository.fetchAccounts(ofType: .savings)
                self.savingsAccounts = fetchedSavings
                // --- DEBUG PRINT ---
                print("DEBUG AccountsVM: Fetched Savings Accounts:")
                fetchedSavings.forEach { print("  Name: \($0.name), Currency: \($0.currencyCode)") }
                // --- END DEBUG PRINT ---
                
            } catch let repoError as RepositoryError {
                 print("Ошибка загрузки счетов в AccountsViewModel: \(repoError)")
                 self.errorMessage = "Не удалось загрузить счета: \(repoError.localizedDescription)"
            } catch {
                print("Неизвестная ошибка загрузки счетов: \(error)")
                self.errorMessage = "Произошла неизвестная ошибка при загрузке счетов."
            }
            isLoading = false
        }
    }

    // ... (остальные методы: prepareForDelete, confirmDeleteAccount, cancelDelete, presentAddAccountSheet, presentEditAccountSheet) ...
    func prepareForDelete(_ account: Account) { self.accountToDeleteAlert = account }
    func confirmDeleteAccount() {
        guard let account = accountToDeleteAlert else { return }
        isLoading = true; errorMessage = nil
        Task {
            do {
                try await accountRepository.deleteAccount(account)
                self.accountToDeleteAlert = nil; fetchAccounts()
            } catch let repoError as RepositoryError {
                switch repoError {
                case .entityInUse(let message): self.errorMessage = message
                default: self.errorMessage = "Ошибка удаления счета: \(repoError.localizedDescription)"
                }
                print("Ошибка удаления счета (репозиторий): \(repoError)")
            } catch { self.errorMessage = "Неизвестная ошибка удаления счета: \(error.localizedDescription)"; print("Неизвестная ошибка удаления счета: \(error)") }
            self.isLoading = false
        }
    }
    func cancelDelete() { self.accountToDeleteAlert = nil }
    func presentAddAccountSheet(defaultType: AccountUsageType) { sheetContext = EditAccountSheetContext(initialUsageType: defaultType) }
    func presentEditAccountSheet(account: Account) { sheetContext = EditAccountSheetContext(accountToEdit: account) }
}
