// Features/Finances/Views/AddEditAccountView.swift
import SwiftUI
import SwiftData

struct AddEditAccountView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel: AddEditAccountViewModel

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Детали счета")) {
                    TextField("Название счета", text: $viewModel.accountName)
                    
                    Picker("Тип счета", selection: $viewModel.selectedAccountUsageType) {
                        ForEach(AccountUsageType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    
                    Picker("Валюта", selection: $viewModel.selectedCurrencyCode) {
                        ForEach(viewModel.availableCurrencies, id: \.self) { currency in
                            Text(currency).tag(currency)
                        }
                    }
                    
                    TextField("Начальный баланс", text: $viewModel.initialBalanceString)
                        .keyboardType(.decimalPad)
                    
                    TextField("Имя иконки (SF Symbol)", text: $viewModel.iconName)
                }
            }
            .navigationTitle(viewModel.navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(viewModel.saveButtonLabel) {
                        viewModel.saveAccount()
                        if viewModel.errorMessage == nil {
                            dismiss()
                        }
                    }
                    .disabled(viewModel.accountName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .alert("Ошибка", isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Button("OK") { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "Произошла неизвестная ошибка.")
            }
        }
    }
}

struct AddEditAccountView_Previews: PreviewProvider {
    @MainActor
    static var previews: some View {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: Account.self, FinancialTransaction.self, Item.self, TransactionCategory.self, Todo.self)
        let modelContext = container.mainContext
        let accountRepoPreview = AccountRepositoryImpl(modelContext: modelContext)

        let addNewVM = AddEditAccountViewModel(
            accountRepository: accountRepoPreview,
            initialUsageType: .expenseSource,
            initialCurrencyCode: "RUB",
            onSave: { print("Preview: Новый счет сохранен") }
        )
        
        // ИСПРАВЛЕН ПОРЯДОК АРГУМЕНТОВ: iconName ПЕРЕД initialBalance
        let sampleAccountToEdit = Account(name: "Старый Накопительный",
                                          accountUsageType: .savings,
                                          currencyCode: "USD",
                                          iconName: "star.fill", // <--- iconName
                                          initialBalance: 500    // <--- initialBalance
                                         )
        modelContext.insert(sampleAccountToEdit)

        let editExistingVM = AddEditAccountViewModel(
            accountRepository: accountRepoPreview,
            accountToEdit: sampleAccountToEdit,
            initialUsageType: sampleAccountToEdit.accountUsageType,
            initialCurrencyCode: sampleAccountToEdit.currencyCode,
            onSave: { print("Preview: Счет отредактирован") }
        )

        return Group {
            AddEditAccountView(viewModel: addNewVM)
                .previewDisplayName("Новый Счет")
                .modelContainer(container)

            AddEditAccountView(viewModel: editExistingVM)
                .previewDisplayName("Редактировать Счет")
                .modelContainer(container)
        }
    }
}
