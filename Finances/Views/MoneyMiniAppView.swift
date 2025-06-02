// Features/Finances/Views/MoneyMiniAppView.swift
import SwiftUI
import Charts
import SwiftData

struct MoneyMiniAppView: View {
    @StateObject var viewModel: MoneyMiniAppViewModel
    @Environment(\.modelContext) private var modelContext

    private var currencyFormatterListItem: NumberFormatter {
        let formatter = NumberFormatter(); formatter.numberStyle = .currency; formatter.currencySymbol = "₽"; formatter.maximumFractionDigits = 2; formatter.minimumFractionDigits = 2; return formatter
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                HStack { Spacer(); VStack { Text("ОБЩИЙ БАЛАНС").font(.caption).foregroundColor(.gray); Text(viewModel.totalBalanceString).font(.largeTitle.bold())}; Spacer() }.padding()
                
                Grid { GridRow {
                    actionButton(label: "Доход", systemImage: "arrow.up.circle.fill", color: .green,
                                 action: { viewModel.presentAddTransactionSheet(type: .income) })
                    actionButton(label: "Расход", systemImage: "arrow.down.circle.fill", color: .red,
                                 action: { viewModel.presentAddTransactionSheet(type: .expense) })
                    
                    let savingsCategory = viewModel.expenseCategories.first(where: { $0.name == viewModel.savingCategoryName })
                    actionButton(label: "Накопить", systemImage: "arrow.down.to.line.compact", color: .blue,
                                 action: { viewModel.presentAddTransactionSheet(type: .expense, category: savingsCategory) }) // Для "Накопить" пока оставляем тип .expense
                }}.padding(.horizontal).padding(.bottom)
                
                Divider().padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Аналитика").font(.title2.bold())
                        Spacer()
                        Picker("Период", selection: $viewModel.selectedAnalyticsPeriod) {
                            ForEach(TimePeriodSelection.allCases) { period in
                                Text(period.shortLabel).tag(period)
                            }
                        }.pickerStyle(.menu)
                    }.padding(.horizontal)
                    
                    Group {
                        if viewModel.showEmptyStateForChart {
                            Text("Нет данных за выбранный период.")
                                .font(.caption).foregroundColor(.gray).frame(height: 150, alignment: .center)
                                .frame(maxWidth: .infinity).padding(.horizontal)
                        } else {
                            let xAxisLabel: String = {
                                switch viewModel.selectedAnalyticsPeriod {
                                case .week, .month: return "День"
                                case .year, .allTime: return "Месяц"
                                }
                            }()
                            ClearChartView(data: viewModel.periodicalChartData, xAxisLabel: xAxisLabel)
                                .padding(.horizontal).padding(.bottom, 2).frame(height: 150)
                        }
                    }
                    
                    VStack(spacing: 4) {
                        MetricRow(label: "Доход (\(viewModel.selectedAnalyticsPeriod.shortLabel)):", value: viewModel.incomeForSelectedPeriodString, valueColor: .green)
                        MetricRow(label: "Расход (\(viewModel.selectedAnalyticsPeriod.shortLabel)):", value: viewModel.expensesForSelectedPeriodString, valueColor: .red)
                        MetricRow(label: "Накопления (\(viewModel.selectedAnalyticsPeriod.shortLabel)):", value: viewModel.savingsForSelectedPeriodString, valueColor: .blue)
                    }.padding(.horizontal)
                }.padding(.vertical)

                Text("Последние транзакции").font(.title2.bold()).padding([.top, .leading])
                
                if viewModel.transactions.isEmpty {
                    Text("Нет транзакций для отображения.")
                        .font(.caption).foregroundColor(.gray).padding()
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    List {
                        ForEach(viewModel.transactions) { transaction in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(transaction.transactionDescription).fontWeight(.medium)
                                    HStack(spacing: 4) {
                                        Text(transaction.category?.name ?? "Без категории")
                                        Text("•")
                                        Text(transaction.account?.name ?? "Без счета")
                                    }.font(.caption).foregroundColor(.gray)
                                }
                                Spacer()
                                // Отображаем сумму с учетом валюты транзакции
                                Text(currencyFormatterListItem.string(for: transaction.amount, currencyCode: transaction.currencyCode) ?? "")
                                    .fontWeight(.semibold)
                                    .foregroundColor(transaction.type == .income ? .green : .primary)
                            }
                            .padding(.vertical, 4).contentShape(Rectangle())
                            .onTapGesture { viewModel.presentEditTransactionSheet(transaction: transaction) }
                        }
                        .onDelete(perform: { indexSet in
                            Task {
                                await viewModel.deleteTransactions(at: indexSet, from: viewModel.transactions)
                            }
                        })
                    }
                    .listStyle(PlainListStyle()).frame(minHeight: 200, idealHeight: 300 ,maxHeight: .infinity)
                }
            }
        }
        .navigationTitle("Финансы")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    viewModel.dismissModule()
                } label: {
                    Image(systemName: "chevron.backward")
                    Text("Дашборд")
                }
            }
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button { viewModel.navigateToAccounts() } label: { Image(systemName: "creditcard.fill") }
                Button { viewModel.navigateToCategories() } label: { Image(systemName: "tag.fill") }
            }
        }
        .sheet(item: $viewModel.sheetContext) { contextInfo in
            // ИСПРАВЛЕНО: Создаем и передаем репозитории
            let categoryRepo = TransactionCategoryRepositoryImpl(modelContext: self.modelContext)
            let accountRepo = AccountRepositoryImpl(modelContext: self.modelContext)
            // FinancialTransactionRepository пока не создан, поэтому AddTransactionViewModel
            // все еще может ожидать modelContext для сохранения транзакций, ИЛИ его нужно обновить.
            // Пока оставляем modelContext для AddTransactionViewModel.

            let addViewModel = AddTransactionViewModel(
                modelContext: self.modelContext, // <--- ОСТАВЛЯЕМ, пока AddTransactionViewModel не переведен на репозиторий
                categoryRepository: categoryRepo,
                accountRepository: accountRepo,
                transactionToEdit: contextInfo.transactionToEdit,
                initialType: contextInfo.type,
                initialCategory: contextInfo.category,
                onSave: {
                    Task {
                        await viewModel.fetchAllData()
                    }
                }
            )
            AddTransactionView(viewModel: addViewModel)
                .environment(\.modelContext, self.modelContext)
        }
        .onAppear {
            Task {
                await viewModel.fetchAllData()
            }
        }
    }

    func actionButton(label: String, systemImage: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack {
                Image(systemName: systemImage).font(.title2); Text(label)
            }.font(.headline).padding(.vertical, 10).padding(.horizontal, 5)
            .frame(maxWidth: .infinity).background(color.opacity(0.15))
            .foregroundColor(color).cornerRadius(10)
        }
    }
}

// Расширение для форматирования с учетом валюты (можно вынести в отдельный файл)
extension NumberFormatter {
    func string(for value: Double, currencyCode: String) -> String? {
        let currentSymbol = self.currencySymbol
        let currentCode = self.currencyCode
        self.currencyCode = currencyCode // Устанавливаем нужный код валюты
        self.currencySymbol = CurrencyUtils.symbol(forCurrencyCode: currencyCode) // Получаем символ
        let formattedString = self.string(from: NSNumber(value: value))
        self.currencySymbol = currentSymbol // Возвращаем исходный символ
        self.currencyCode = currentCode   // Возвращаем исходный код
        return formattedString
    }
}

// Утилита для получения символа валюты (можно вынести в отдельный файл)
struct CurrencyUtils {
    static func symbol(forCurrencyCode currencyCode: String) -> String {
        let locale = NSLocale(localeIdentifier: currencyCode) // Не совсем корректно, нужен locale с этой валютой
        // Более надежный способ - маппинг или использование компонентов Locale
        if let symbol = Locale.current.localizedString(forCurrencyCode: currencyCode) {
            // Locale.current.localizedString(forCurrencyCode: currencyCode) может вернуть сам код, если символ не найден
            // Для известных валют можно сделать маппинг
            switch currencyCode.uppercased() {
                case "RUB": return "₽"
                case "USD": return "$"
                case "EUR": return "€"
                case "USDT": return "₮" // Или "USDT"
                default: return currencyCode // Возвращаем код, если символ не известен
            }
        }
        return currencyCode
    }
}


struct MoneyMiniAppView_Previews: PreviewProvider {
    @MainActor
    static var previews: some View {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: FinancialTransaction.self, TransactionCategory.self, Account.self, Item.self, Todo.self)

        let modelContext = container.mainContext
        
        let catSalary = TransactionCategory(name: "Зарплата", type: .income)
        let catFood = TransactionCategory(name: "Еда", type: .expense)
        modelContext.insert(catSalary)
        modelContext.insert(catFood)
        
        let accCardRUB = Account(name: "Карта RUB Preview", accountUsageType: .expenseSource, currencyCode: "RUB")
        modelContext.insert(accCardRUB)

        // ИСПРАВЛЕНО: Добавляем currencyCode
        modelContext.insert(FinancialTransaction(timestamp: Date(),
                                                 amount: 100,
                                                 transactionDescription: "Доход Preview",
                                                 type: .income,
                                                 currencyCode: accCardRUB.currencyCode, // <--- ИСПОЛЬЗУЕМ ВАЛЮТУ СЧЕТА
                                                 category: catSalary,
                                                 account: accCardRUB))
        modelContext.insert(FinancialTransaction(timestamp: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
                                                 amount: 50,
                                                 transactionDescription: "Расход Preview",
                                                 type: .expense,
                                                 currencyCode: accCardRUB.currencyCode, // <--- ИСПОЛЬЗУЕМ ВАЛЮТУ СЧЕТА
                                                 category: catFood,
                                                 account: accCardRUB))
        
        let viewModel = MoneyMiniAppViewModel(modelContext: modelContext, coordinator: nil)

        return NavigationView {
            MoneyMiniAppView(viewModel: viewModel)
                .modelContainer(container)
        }
    }
}
