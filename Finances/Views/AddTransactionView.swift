// Features/Finances/Views/AddTransactionView.swift
import SwiftUI
import SwiftData

struct AddTransactionView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel: AddTransactionViewModel

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Детали транзакции")) {
                    TextField("Сумма", text: $viewModel.amountString)
                        .keyboardType(.decimalPad)

                    Picker("Тип операции", selection: $viewModel.selectedType) {
                        ForEach(TransactionType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .disabled(viewModel.isEditing || viewModel.isFixedSavingOperation)

                    TextField("Описание", text: $viewModel.descriptionText)
                    DatePicker("Дата", selection: $viewModel.selectedDate, displayedComponents: .date)

                    // --- ПИКЕРЫ С УТОЧНЕНИЯМИ ---
                    if viewModel.selectedType != .transfer {
                        Picker("Категория", selection: $viewModel.selectedCategory) {
                            Text("Не выбрана").tag(nil as TransactionCategory?) // Для nil значения
                            ForEach(viewModel.categoriesForPicker) { category in
                                Text(category.name).tag(category as TransactionCategory?)
                            }
                        }
                        .disabled(viewModel.isFixedSavingOperation)
                    }
                    
                    if viewModel.selectedType == .transfer {
                        Picker("Со счета", selection: $viewModel.selectedFromAccount) {
                            Text("Не выбран").tag(nil as Account?) // Для nil значения
                            ForEach(viewModel.accountsForPrimaryPicker) { account in
                                Text("\(account.name) (\(account.currencyCode))").tag(account as Account?)
                            }
                        }
                        
                        Picker("На счет", selection: $viewModel.selectedToAccount) {
                            Text("Не выбран").tag(nil as Account?) // Для nil значения
                            ForEach(viewModel.accountsForSecondaryPicker) { account in
                                Text("\(account.name) (\(account.currencyCode))").tag(account as Account?)
                            }
                        }

                        if viewModel.shouldShowConversionFields {
                            TextField("Сумма зачисления (\(viewModel.selectedToAccount?.currencyCode ?? ""))", text: $viewModel.amountToString)
                                .keyboardType(.decimalPad)
                            TextField("Обменный курс (1 \(viewModel.selectedFromAccount?.currencyCode ?? "") = ? \(viewModel.selectedToAccount?.currencyCode ?? ""))", text: $viewModel.exchangeRateString)
                                .keyboardType(.decimalPad)
                        }
                        
                    } else { // Для Доходов и Расходов
                        Picker("Счет", selection: $viewModel.selectedAccount) {
                            Text("Не выбран").tag(nil as Account?) // Для nil значения
                            ForEach(viewModel.accountsForPrimaryPicker) { account in
                                Text("\(account.name) (\(account.currencyCode))").tag(account as Account?)
                            }
                        }
                    }
                }

                Section {
                    Button {
                        viewModel.saveTransaction()
                        if viewModel.errorMessage == nil { dismiss() }
                    } label: {
                        Text(viewModel.saveButtonLabel).frame(maxWidth: .infinity, alignment: .center)
                    }
                    .disabled(viewModel.amountString.isEmpty ||
                              (viewModel.selectedType != .transfer && (viewModel.selectedCategory == nil || viewModel.selectedAccount == nil)) ||
                              (viewModel.selectedType == .transfer && (viewModel.selectedFromAccount == nil || viewModel.selectedToAccount == nil))
                             )
                }

                if let errorMessage = viewModel.errorMessage {
                    Section { Text(errorMessage).foregroundColor(.red).font(.caption) }
                }
            }
            .navigationTitle(viewModel.navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { Button("Отмена") { dismiss() } }
            }
        }
    }
}

// Previews остаются как в ответе #57
struct AddTransactionView_Previews: PreviewProvider {
    @MainActor
    static var previews: some View {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: FinancialTransaction.self, TransactionCategory.self, Account.self, Item.self, Todo.self)
        let modelContext = container.mainContext

        let categoryRepoPreview = TransactionCategoryRepositoryImpl(modelContext: modelContext)
        let accountRepoPreview = AccountRepositoryImpl(modelContext: modelContext)

        // Добавляем больше тестовых данных для пикеров
        let catSalary = TransactionCategory(name: "Зарплата", type: .income, iconName: "dollarsign.circle.fill")
        let catFood = TransactionCategory(name: "Еда", type: .expense, iconName: "fork.knife")
        modelContext.insert(catSalary)
        modelContext.insert(catFood)
        
        let accCardRUB = Account(name: "Карта RUB", accountUsageType: .expenseSource, currencyCode: "RUB", initialBalance: 10000)
        modelContext.insert(accCardRUB)
        
        let addIncomeVM = AddTransactionViewModel(
            modelContext: modelContext, // ViewModel все еще ожидает modelContext для сохранения транзакций
            categoryRepository: categoryRepoPreview,
            accountRepository: accountRepoPreview,
            initialType: .income,
            initialCategory: catSalary, // Передаем существующую категорию
            onSave: { print("Preview: Доход сохранен") }
        )
        
        return AddTransactionView(viewModel: addIncomeVM)
                .modelContainer(container)
    }
}
