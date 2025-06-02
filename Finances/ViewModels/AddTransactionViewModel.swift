// Features/Finances/ViewModels/AddTransactionViewModel.swift
import SwiftUI
import SwiftData
import Combine

@MainActor
class AddTransactionViewModel: ObservableObject {
    private var modelContext: ModelContext
    private var categoryRepository: TransactionCategoryRepositoryProtocol
    private var accountRepository: AccountRepositoryProtocol

    var transactionToEdit: FinancialTransaction?
    
    @Published var amountString: String = "" { didSet { if oldValue != amountString { calculateExchangeRateIfNeeded(basedOn: .amountFrom) } } }
    @Published var descriptionText: String = ""
    @Published var selectedType: TransactionType
    @Published var selectedDate: Date = Date()
    @Published var selectedCategory: TransactionCategory?
    @Published var selectedAccount: Account?
    @Published var selectedFromAccount: Account? { didSet { if oldValue?.id != selectedFromAccount?.id { updateCurrenciesForTransfer(); calculateExchangeRateIfNeeded(basedOn: .amountFrom) } } }
    @Published var selectedToAccount: Account? {   didSet { if oldValue?.id != selectedToAccount?.id { updateCurrenciesForTransfer(); calculateExchangeRateIfNeeded(basedOn: .amountFrom) } } }
    @Published var amountToString: String = "" {    didSet { if oldValue != amountToString && !isCalculatingRateInternally { calculateExchangeRateIfNeeded(basedOn: .amountTo) } } }
    @Published var exchangeRateString: String = "" { didSet { if oldValue != exchangeRateString && !isCalculatingRateInternally { calculateExchangeRateIfNeeded(basedOn: .rate) } } }
    
    private var isCalculatingRateInternally = false

    @Published var availableCategories: [TransactionCategory] = []
    @Published var availableAccounts: [Account] = []
    @Published var errorMessage: String? = nil
    @Published var isLoading: Bool = false

    let isEditing: Bool
    
    // --- ПОЛНАЯ ЛОГИКА navigationTitle ---
    var navigationTitle: String {
        if isEditing {
            guard let type = transactionToEdit?.type else { return "Редактирование" }
            switch type {
            case .income: return "Редакт. доход"
            case .expense:
                if transactionToEdit?.category?.name.lowercased() == savingCategoryName.lowercased() {
                    return "Редакт. накопление"
                }
                return "Редакт. расход"
            case .transfer: return "Редакт. перевод"
            }
        } else {
            switch selectedType {
            case .income: return "Новый доход"
            case .expense:
                if initialCategoryFromContext?.name.lowercased() == savingCategoryName.lowercased() && initialTypeFromContext == .expense && selectedType != .transfer {
                    return "Новое накопление"
                }
                return "Новый расход"
            case .transfer: return "Новый перевод"
            }
        }
    }
    
    var saveButtonLabel: String { isEditing ? "Сохранить изменения" : "Добавить" }
    let savingCategoryName = "Накопления"
    
    // --- ПОЛНАЯ ЛОГИКА isFixedSavingOperation ---
    var isFixedSavingOperation: Bool {
        if isEditing {
            return transactionToEdit?.category?.name.lowercased() == savingCategoryName.lowercased() && transactionToEdit?.type == .expense
        } else {
            return (selectedType == .expense && selectedCategory?.name.lowercased() == savingCategoryName.lowercased()) ||
                   (initialTypeFromContext == .expense && initialCategoryFromContext?.name.lowercased() == savingCategoryName.lowercased() && selectedType != .transfer)
        }
    }
    
    @Published var categoriesForPicker: [TransactionCategory] = []
    var accountsForPrimaryPicker: [Account] { availableAccounts.sorted { $0.name < $1.name } }
    var accountsForSecondaryPicker: [Account] {
        if let fromAcc = selectedFromAccount { return availableAccounts.filter { $0.id != fromAcc.id }.sorted { $0.name < $1.name } }
        return availableAccounts.sorted { $0.name < $1.name }
    }

    // --- ПОЛНАЯ ЛОГИКА shouldShowConversionFields ---
    var shouldShowConversionFields: Bool {
        guard selectedType == .transfer,
              let fromCurrency = selectedFromAccount?.currencyCode,
              let toCurrency = selectedToAccount?.currencyCode else { return false }
        return fromCurrency != toCurrency
    }

    private enum RateCalculationBasis { case amountFrom, amountTo, rate }
    var onSave: () -> Void
    private var initialTypeFromContext: TransactionType
    private var initialCategoryFromContext: TransactionCategory?

    init(modelContext: ModelContext,
         categoryRepository: TransactionCategoryRepositoryProtocol,
         accountRepository: AccountRepositoryProtocol,
         transactionToEdit: FinancialTransaction? = nil,
         initialType: TransactionType,
         initialCategory: TransactionCategory? = nil,
         onSave: @escaping () -> Void) {
        
        self.modelContext = modelContext
        self.categoryRepository = categoryRepository
        self.accountRepository = accountRepository
        self.transactionToEdit = transactionToEdit
        self.isEditing = transactionToEdit != nil
        self.initialTypeFromContext = initialType
        self.initialCategoryFromContext = initialCategory
        self.onSave = onSave
        
        var typeToSet = self.isEditing ? (transactionToEdit?.type ?? initialType) : initialType
        
        if !self.isEditing && initialType == .expense && initialCategory?.name.lowercased() == savingCategoryName.lowercased() {
            typeToSet = .transfer
        }
        self.selectedType = typeToSet
        
        if let t = transactionToEdit {
            self.amountString = String(format: "%.2f", abs(t.amount)).replacingOccurrences(of: ",", with: ".");
            self.descriptionText = t.transactionDescription;
            self.selectedDate = t.timestamp
            if t.type == .transfer {
                self.selectedFromAccount = t.account; self.selectedToAccount = t.toAccount;
                self.amountToString = t.amountTo != nil ? String(format: "%.2f", abs(t.amountTo!)).replacingOccurrences(of: ",", with: ".") : "";
                self.exchangeRateString = t.exchangeRate != nil ? String(format: "%.4f", t.exchangeRate!) : ""
            } else {
                self.selectedCategory = t.category; self.selectedAccount = t.account
            }
        } else {
            if typeToSet == .transfer {
                self.selectedCategory = nil
            } else {
                self.selectedCategory = initialCategoryFromContext
            }
        }
        
        loadPickerData()
        
        // Явный вызов методов после loadPickerData для установки начального состояния
        // Это может быть избыточным, если didSet у selectedType и счетов уже все делают,
        // но для надежности можно оставить.
        updateCategoriesForPicker()
        calculateExchangeRateIfNeeded()
    }
    
    // --- ПОЛНАЯ РЕАЛИЗАЦИЯ loadPickerData ---
    private func loadPickerData() {
        Task {
            isLoading = true
            do {
                self.availableCategories = try await categoryRepository.fetchCategories(ofType: nil)
                self.availableAccounts = try await accountRepository.fetchAccounts(ofType: nil)
                updateCategoriesForPicker()

                if !isEditing {
                    if selectedType == .transfer {
                        self.selectedFromAccount = self.accountsForPrimaryPicker.first
                        self.selectedToAccount = self.accountsForSecondaryPicker.first
                        if initialCategoryFromContext?.name.lowercased() == savingCategoryName.lowercased() && initialTypeFromContext == .expense {
                           self.selectedToAccount = self.availableAccounts.first(where: {$0.accountUsageType == .savings }) ?? self.accountsForSecondaryPicker.first
                        }
                    } else {
                        self.selectedAccount = self.accountsForPrimaryPicker.first
                        if self.selectedCategory == nil { self.selectedCategory = self.categoriesForPicker.first }
                    }
                } else {
                    if let currentFromAccId = transactionToEdit?.account?.id { self.selectedFromAccount = availableAccounts.first { $0.id == currentFromAccId } }
                    if let currentToAccId = transactionToEdit?.toAccount?.id { self.selectedToAccount = availableAccounts.first { $0.id == currentToAccId } }
                    if let currentCatId = transactionToEdit?.category?.id, selectedType != .transfer { self.selectedCategory = availableCategories.first { $0.id == currentCatId } }
                    if let currentAccId = transactionToEdit?.account?.id, selectedType != .transfer { self.selectedAccount = availableAccounts.first { $0.id == currentAccId } }
                }
                updateCurrenciesForTransfer()
            } catch { errorMessage = "Ошибка загрузки данных: \(error.localizedDescription)" }
            isLoading = false
        }
    }
    
    // --- ПОЛНАЯ РЕАЛИЗАЦИЯ updateCategoriesForPicker ---
    private func updateCategoriesForPicker() {
        if selectedType == .transfer {
            categoriesForPicker = []
        } else if selectedType == .income {
            categoriesForPicker = availableCategories.filter { $0.type == .income }.sorted { $0.name < $1.name }
        } else { // .expense
            if isFixedSavingOperation {
                 categoriesForPicker = availableCategories.filter { $0.name.lowercased() == savingCategoryName.lowercased() && $0.type == .expense }
            } else {
                 categoriesForPicker = availableCategories.filter { $0.type == .expense && $0.name.lowercased() != savingCategoryName.lowercased() }.sorted { $0.name < $1.name }
            }
        }
    }

    // --- ПОЛНАЯ РЕАЛИЗАЦИЯ updateCurrenciesForTransfer ---
    private func updateCurrenciesForTransfer() {
        if selectedType == .transfer {
            calculateExchangeRateIfNeeded()
        }
    }

    // --- ПОЛНАЯ РЕАЛИЗАЦИЯ calculateExchangeRateIfNeeded ---
    private func calculateExchangeRateIfNeeded(basedOn: RateCalculationBasis? = nil) {
        guard selectedType == .transfer, let fromAccount = selectedFromAccount, let toAccount = selectedToAccount else {
            if selectedType != .transfer || self.selectedFromAccount == nil || self.selectedToAccount == nil {
                self.isCalculatingRateInternally = true; exchangeRateString = ""; amountToString = ""; self.isCalculatingRateInternally = false
            }
            return
        }
        if fromAccount.currencyCode == toAccount.currencyCode {
            self.isCalculatingRateInternally = true; exchangeRateString = "1.0000"
            if basedOn != .amountTo { amountToString = amountString }
            else if basedOn == .amountTo { amountString = amountToString }
            self.isCalculatingRateInternally = false; return
        }
        let amountFromValue = Double(amountString.replacingOccurrences(of: ",", with: "."))
        let amountToValue = Double(amountToString.replacingOccurrences(of: ",", with: "."))
        let exchangeRateValue = Double(exchangeRateString.replacingOccurrences(of: ",", with: "."))
        self.isCalculatingRateInternally = true
        if basedOn == .amountTo {
            if let af = amountFromValue, af > 0, let at = amountToValue, at > 0 { exchangeRateString = String(format: "%.4f", at / af) }
            else if amountFromValue == 0 && amountToValue != 0 { exchangeRateString = "" }
        } else if basedOn == .rate {
            if let af = amountFromValue, af > 0, let rate = exchangeRateValue, rate > 0 { amountToString = String(format: "%.2f", af * rate) }
        } else {
            if let af = amountFromValue, af > 0, let rate = exchangeRateValue, rate > 0 { amountToString = String(format: "%.2f", af * rate) }
            else if let af = amountFromValue, af > 0, let at = amountToValue, at > 0 { exchangeRateString = String(format: "%.4f", at / af) }
        }
        self.isCalculatingRateInternally = false
    }

    // --- ПОЛНАЯ РЕАЛИЗАЦИЯ saveTransaction ---
    func saveTransaction() {
        guard let amountFromValue = Double(amountString.replacingOccurrences(of: ",", with: ".")), amountFromValue > 0 else {
            errorMessage = "Сумма списания должна быть > 0."; isLoading = false; return
        }
        let finalDescription = descriptionText.trimmingCharacters(in: .whitespacesAndNewlines)
        var effectiveDescription = finalDescription

        isLoading = true; errorMessage = nil
        
        Task<Void, Never> {
            do {
                if let existingTransaction = self.transactionToEdit {
                    existingTransaction.timestamp = self.selectedDate
                    existingTransaction.amount = amountFromValue
                    if self.selectedType == .transfer {
                        guard let fromAccount = self.selectedFromAccount, let toAccount = self.selectedToAccount else {
                            self.errorMessage = "Выберите оба счета для перевода."; self.isLoading = false; return
                        }
                        existingTransaction.transactionDescription = effectiveDescription.isEmpty ? "Перевод: \(fromAccount.name) → \(toAccount.name)" : effectiveDescription
                        existingTransaction.type = .transfer; existingTransaction.account = fromAccount; existingTransaction.toAccount = toAccount; existingTransaction.category = nil; existingTransaction.currencyCode = fromAccount.currencyCode
                        if fromAccount.currencyCode == toAccount.currencyCode {
                            existingTransaction.amountTo = amountFromValue; existingTransaction.currencyToCode = fromAccount.currencyCode; existingTransaction.exchangeRate = nil
                        } else {
                            guard let amountToVal = Double(amountToString.replacingOccurrences(of: ",", with: ".")), amountToVal >= 0 else {
                                self.errorMessage = "Укажите корректную сумму зачисления."; self.isLoading = false; return
                            }
                            existingTransaction.amountTo = amountToVal; existingTransaction.currencyToCode = toAccount.currencyCode
                            if let rate = Double(exchangeRateString.replacingOccurrences(of: ",", with: ".")), rate > 0 { existingTransaction.exchangeRate = rate }
                            else if amountFromValue > 0 && amountToVal >= 0 { existingTransaction.exchangeRate = amountToVal / amountFromValue }
                            else { existingTransaction.exchangeRate = nil }
                        }
                    } else {
                        guard let account = self.selectedAccount, let category = self.selectedCategory else {
                            self.errorMessage = "Выберите категорию и счет."; self.isLoading = false; return
                        }
                        existingTransaction.transactionDescription = effectiveDescription.isEmpty ? category.name : effectiveDescription
                        existingTransaction.type = self.selectedType; existingTransaction.category = category; existingTransaction.account = account; existingTransaction.currencyCode = account.currencyCode
                        existingTransaction.toAccount = nil; existingTransaction.amountTo = nil; existingTransaction.currencyToCode = nil; existingTransaction.exchangeRate = nil;
                    }
                } else {
                    let newTransaction: FinancialTransaction
                    if self.selectedType == .transfer {
                        guard let fromAccount = self.selectedFromAccount, let toAccount = self.selectedToAccount else {
                            self.errorMessage = "Выберите оба счета для перевода."; self.isLoading = false; return
                        }
                        effectiveDescription = finalDescription.isEmpty ? "Перевод: \(fromAccount.name) → \(toAccount.name)" : finalDescription
                        var finalAmountTo: Double? = amountFromValue; var finalCurrencyToCode: String? = fromAccount.currencyCode; var finalExchangeRate: Double? = nil
                        if fromAccount.currencyCode != toAccount.currencyCode {
                            guard let amountToVal = Double(amountToString.replacingOccurrences(of: ",", with: ".")), amountToVal >= 0 else {
                                self.errorMessage = "Укажите сумму зачисления."; self.isLoading = false; return
                            }
                            finalAmountTo = amountToVal; finalCurrencyToCode = toAccount.currencyCode
                            if let rate = Double(exchangeRateString.replacingOccurrences(of: ",", with: ".")), rate > 0 { finalExchangeRate = rate }
                            else if amountFromValue > 0 && amountToVal >= 0 { finalExchangeRate = amountToVal / amountFromValue }
                        }
                        newTransaction = FinancialTransaction(timestamp: self.selectedDate, amount: amountFromValue, transactionDescription: effectiveDescription, type: .transfer, currencyCode: fromAccount.currencyCode, category: nil, account: fromAccount, toAccount: toAccount, amountTo: finalAmountTo, currencyToCode: finalCurrencyToCode, exchangeRate: finalExchangeRate)
                    } else {
                        guard let account = self.selectedAccount, let category = self.selectedCategory else {
                            self.errorMessage = "Выберите категорию и счет."; self.isLoading = false; return
                        }
                        effectiveDescription = finalDescription.isEmpty ? category.name : finalDescription
                        newTransaction = FinancialTransaction(timestamp: self.selectedDate, amount: amountFromValue, transactionDescription: effectiveDescription, type: self.selectedType, currencyCode: account.currencyCode, category: category, account: account)
                    }
                    self.modelContext.insert(newTransaction)
                }
                try self.modelContext.save()
                self.isLoading = false; self.onSave()
            } catch {
                self.errorMessage = "Ошибка сохранения транзакции: \(error.localizedDescription)"; self.isLoading = false
                print("DEBUG AddTransactionVM: Save failed. Error: \(error)")
            }
        }
    }
}
