// Features/Finances/Views/AccountsView.swift
import SwiftUI
import SwiftData

struct AccountsView: View {
    @StateObject var viewModel: AccountsViewModel
    @Environment(\.modelContext) private var modelContext

    // Локальное @State для управления тем, КАКОЙ счет выбран для удаления,
    // и для показа/скрытия алерта подтверждения.
    @State private var accountForAlert: Account? = nil
    
    @State private var showUsageAlert: Bool = false
    @State private var usageAlertMessage: String = ""

    var body: some View {
        List {
            // Секция для счетов-источников доходов
            Section("Счета для доходов") {
                if viewModel.incomeSourceAccounts.isEmpty && !viewModel.isLoading {
                    Text("Нет счетов для доходов").foregroundColor(.gray)
                }
                ForEach(viewModel.incomeSourceAccounts) { account in
                    accountRow(account: account)
                }
                .onDelete(perform: deleteIncomeSourceAccount)
            }

            // Секция для счетов-источников расходов
            Section("Счета для расходов") {
                if viewModel.expenseSourceAccounts.isEmpty && !viewModel.isLoading {
                    Text("Нет счетов для расходов").foregroundColor(.gray)
                }
                ForEach(viewModel.expenseSourceAccounts) { account in
                    accountRow(account: account)
                }
                .onDelete(perform: deleteExpenseSourceAccount)
            }
            
            Section("Накопительные счета") {
                if viewModel.savingsAccounts.isEmpty && !viewModel.isLoading {
                    Text("Нет накопительных счетов").foregroundColor(.gray)
                }
                ForEach(viewModel.savingsAccounts) { account in
                    accountRow(account: account)
                }
                .onDelete(perform: deleteSavingsAccount)
            }
        }
        .navigationTitle("Счета")
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Menu {
                    Button("Новый счет для доходов") { viewModel.presentAddAccountSheet(defaultType: .incomeSource) }
                    Button("Новый счет для расходов") { viewModel.presentAddAccountSheet(defaultType: .expenseSource) }
                    Button("Новый накопительный счет") { viewModel.presentAddAccountSheet(defaultType: .savings) }
                } label: {
                    Image(systemName: "plus.circle.fill")
                }
            }
        }
        .sheet(item: $viewModel.sheetContext) { contextInfo in
            // Убедитесь, что AccountRepositoryImpl и AddEditAccountViewModel существуют и в таргете
            let accountRepo = AccountRepositoryImpl(modelContext: self.modelContext)
            let addEditVM = AddEditAccountViewModel(
                accountRepository: accountRepo,
                accountToEdit: contextInfo.accountToEdit,
                initialUsageType: contextInfo.initialUsageType,
                initialCurrencyCode: contextInfo.accountToEdit?.currencyCode ?? "RUB", // Передаем currencyCode
                onSave: {
                    viewModel.fetchAccounts()
                }
            )
            // Убедитесь, что AddEditAccountView существует и в таргете
            AddEditAccountView(viewModel: addEditVM)
                 .environment(\.modelContext, self.modelContext)
        }
        .alert("Удалить счет?",
               isPresented: Binding<Bool>(
                    get: { accountForAlert != nil && viewModel.errorMessage == nil },
                    set: { if !$0 { accountForAlert = nil } }
               ),
               presenting: accountForAlert) { account in
            Button("Удалить", role: .destructive) {
                viewModel.confirmDeleteAccount()
            }
            Button("Отмена", role: .cancel) {
                 viewModel.cancelDelete()
                 self.accountForAlert = nil
            }
        } message: { account in
            Text("Вы уверены, что хотите удалить счет '\(account.name)'?")
        }
        .alert("Сообщение", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "Произошла неизвестная ошибка.")
        }
        .onAppear {
            viewModel.fetchAccounts()
        }
    }

    @ViewBuilder
    private func accountRow(account: Account) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(account.name)
                    .font(.headline)
                // Отображаем начальный баланс и валюту
                Text("Баланс: \(account.initialBalance, specifier: "%.2f") \(account.currencyCode)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
            // Отображаем иконку в зависимости от account.accountUsageType
            switch account.accountUsageType {
            case .incomeSource:
                Image(systemName: "arrow.down.circle.fill").foregroundColor(.green)
            case .expenseSource:
                Image(systemName: "creditcard.fill").foregroundColor(.orange)
            case .savings:
                Image(systemName: "banknote.fill").foregroundColor(.blue) // Используем banknote.fill
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            viewModel.presentEditAccountSheet(account: account)
        }
    }
    
    private func deleteIncomeSourceAccount(at offsets: IndexSet) {
        for index in offsets {
            let account = viewModel.incomeSourceAccounts[index]
            viewModel.prepareForDelete(account)
            self.accountForAlert = account
        }
    }
    private func deleteExpenseSourceAccount(at offsets: IndexSet) {
        for index in offsets {
            let account = viewModel.expenseSourceAccounts[index]
            viewModel.prepareForDelete(account)
            self.accountForAlert = account
        }
    }
    private func deleteSavingsAccount(at offsets: IndexSet) {
        for index in offsets {
            let account = viewModel.savingsAccounts[index]
            viewModel.prepareForDelete(account)
            self.accountForAlert = account
        }
    }
}

struct AccountsView_Previews: PreviewProvider {
    @MainActor
    static var previews: some View {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        // Убедитесь, что все модели, включая AccountUsageType, здесь
        let container = try! ModelContainer(for: Account.self, FinancialTransaction.self, TransactionCategory.self, Item.self, Todo.self)
        let context = container.mainContext

        // Добавляем тестовые счета с валютой
        context.insert(Account(name: "Зарплатная карта", accountUsageType: .incomeSource, currencyCode: "RUB", initialBalance: 10000))
        context.insert(Account(name: "Карта для трат", accountUsageType: .expenseSource, currencyCode: "USD", initialBalance: 500))
        context.insert(Account(name: "Копилка Важная", accountUsageType: .savings, currencyCode: "USDT", initialBalance: 20000))
        
        // Убедитесь, что AccountRepositoryImpl и AccountsViewModel существуют и в таргете
        let accountRepo = AccountRepositoryImpl(modelContext: context)
        // Убедитесь, что AccountsViewModel.init принимает modelContext
        let viewModel = AccountsViewModel(accountRepository: accountRepo, modelContext: context, coordinator: nil)

        return NavigationView {
            AccountsView(viewModel: viewModel)
                .modelContainer(container)
        }
    }
}
