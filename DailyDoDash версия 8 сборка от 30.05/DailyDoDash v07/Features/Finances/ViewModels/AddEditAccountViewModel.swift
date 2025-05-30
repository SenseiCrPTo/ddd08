// Features/Finances/ViewModels/AddEditAccountViewModel.swift
import SwiftUI
import SwiftData

@MainActor
class AddEditAccountViewModel: ObservableObject {
    private var accountRepository: AccountRepositoryProtocol
    var accountToEdit: Account?

    @Published var accountName: String = ""
    @Published var selectedAccountUsageType: AccountUsageType
    @Published var selectedCurrencyCode: String
    @Published var initialBalanceString: String = "0.00"
    @Published var iconName: String = "creditcard.fill"

    @Published var errorMessage: String? = nil
    @Published var isLoading: Bool = false

    var isEditing: Bool { accountToEdit != nil }
    var navigationTitle: String { isEditing ? "Редактировать счет" : "Новый счет" }
    var saveButtonLabel: String { isEditing ? "Сохранить" : "Добавить" }

    var onSave: () -> Void = {}
    let availableCurrencies = ["RUB", "USD", "EUR", "USDT"]

    init(accountRepository: AccountRepositoryProtocol,
         accountToEdit: Account? = nil,
         initialUsageType: AccountUsageType = .expenseSource,
         initialCurrencyCode: String = "RUB",
         onSave: @escaping () -> Void) {
        self.accountRepository = accountRepository
        self.accountToEdit = accountToEdit
        self.onSave = onSave

        if let acc = accountToEdit {
            self.accountName = acc.name
            self.selectedAccountUsageType = acc.accountUsageType
            self.selectedCurrencyCode = acc.currencyCode
            self.initialBalanceString = String(format: "%.2f", acc.initialBalance).replacingOccurrences(of: ",", with: ".")
            self.iconName = acc.iconName ?? "creditcard.fill"
            print("DEBUG AddEditAccountVM (Init - Editing): Name: \(self.accountName), Currency: \(self.selectedCurrencyCode)")
        } else {
            self.selectedAccountUsageType = initialUsageType
            self.selectedCurrencyCode = initialCurrencyCode
            self.initialBalanceString = "0.00"
            print("DEBUG AddEditAccountVM (Init - New): Default Currency: \(self.selectedCurrencyCode)")
        }
    }

    func saveAccount() {
        let trimmedName = accountName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            errorMessage = "Имя счета не может быть пустым."; return
        }
        let balanceValue = Double(initialBalanceString.replacingOccurrences(of: ",", with: ".")) ?? 0.0

        isLoading = true; errorMessage = nil
        
        // --- DEBUG PRINT ПЕРЕД СОХРАНЕНИЕМ ---
        print("DEBUG AddEditAccountVM (saveAccount - Before Repo Call):")
        print("  Account Name: \(trimmedName)")
        print("  Selected Usage Type: \(selectedAccountUsageType.rawValue)")
        print("  Selected Currency Code: \(selectedCurrencyCode)") // <--- ВАЖНОЕ ЗНАЧЕНИЕ
        print("  Initial Balance: \(balanceValue)")
        print("  Icon Name: \(iconName)")
        // --- КОНЕЦ DEBUG PRINT ---

        Task<Void, Never> {
            do {
                if try await accountRepository.accountExists(name: trimmedName,
                                                             usageType: self.selectedAccountUsageType,
                                                             excludingId: self.accountToEdit?.id) {
                    self.errorMessage = "Счет с таким именем уже существует."; self.isLoading = false; return
                }

                if let accToUpdate = self.accountToEdit {
                    try await accountRepository.updateAccount(accToUpdate,
                                                             newName: trimmedName,
                                                             newUsageType: self.selectedAccountUsageType,
                                                             newInitialBalance: balanceValue,
                                                             newIconName: self.iconName,
                                                             newCurrencyCode: self.selectedCurrencyCode) // Передаем выбранную валюту
                } else {
                    _ = try await accountRepository.addAccount(name: trimmedName,
                                                             usageType: self.selectedAccountUsageType,
                                                             initialBalance: balanceValue,
                                                             iconName: self.iconName,
                                                             currencyCode: self.selectedCurrencyCode) // Передаем выбранную валюту
                }
                self.isLoading = false; self.onSave()
            } catch let repoError as RepositoryError {
                 switch repoError {
                 case .alreadyExists: self.errorMessage = "Счет с таким именем уже существует."
                 default: self.errorMessage = "Ошибка сохранения счета: \(repoError.localizedDescription)"
                 }
                 self.isLoading = false
                 print("DEBUG AddEditAccountVM: RepositoryError during save: \(repoError)")
            } catch {
                self.errorMessage = "Неизвестная ошибка сохранения: \(error.localizedDescription)"; self.isLoading = false
                print("DEBUG AddEditAccountVM: Unknown error during save: \(error)")
            }
        }
    }
}
