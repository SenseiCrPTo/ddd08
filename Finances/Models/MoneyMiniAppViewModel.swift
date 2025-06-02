// Features/Finances/ViewModels/MoneyMiniAppViewModel.swift
import SwiftUI
import SwiftData
import Combine

@MainActor
class MoneyMiniAppViewModel: ObservableObject {
    private var modelContext: ModelContext
    private weak var coordinator: FinancesCoordinator?

    @Published var transactions: [FinancialTransaction] = []
    @Published var totalBalanceString: String = "0.00 ₽"
    
    @Published var selectedAnalyticsPeriod: TimePeriodSelection = .month {
        didSet {
            Task { await updateAnalyticsData() }
        }
    }
    @Published var periodicalChartData: [MonthlyDataPoint] = []
    @Published var incomeForSelectedPeriodString: String = "0 ₽"
    @Published var expensesForSelectedPeriodString: String = "0 ₽"
    @Published var savingsForSelectedPeriodString: String = "0 ₽"
    @Published var showEmptyStateForChart: Bool = true
    @Published var sheetContext: TransactionSheetContext? = nil
    @Published var incomeCategories: [TransactionCategory] = []
    @Published var expenseCategories: [TransactionCategory] = []
    @Published var accounts: [Account] = []
    
    let savingCategoryName: String = "Накопления"
    private var currencyFormatterGeneral: NumberFormatter
    private var currencyFormatterWithCents: NumberFormatter

    init(modelContext: ModelContext, coordinator: FinancesCoordinator?) {
        self.modelContext = modelContext
        self.coordinator = coordinator

        currencyFormatterGeneral = NumberFormatter()
        currencyFormatterGeneral.numberStyle = .currency
        currencyFormatterGeneral.currencySymbol = "₽"
        currencyFormatterGeneral.maximumFractionDigits = 0

        currencyFormatterWithCents = NumberFormatter()
        currencyFormatterWithCents.numberStyle = .currency
        currencyFormatterWithCents.currencySymbol = "₽"
        currencyFormatterWithCents.maximumFractionDigits = 2
        currencyFormatterWithCents.minimumFractionDigits = 2
        
        Task {
            await fetchAllData()
        }
    }

    func fetchAllData() async {
        await fetchAccounts()
        await fetchTransactions()
        await fetchCategories()
        await updateAnalyticsData()
        await updateTotalBalance()
    }

    private func fetchTransactions() async {
        let descriptor = FetchDescriptor<FinancialTransaction>(sortBy: [SortDescriptor(\.timestamp, order: .reverse)])
        do {
            let fetchedTransactions = try modelContext.fetch(descriptor)
            self.transactions = fetchedTransactions
        } catch {
            print("Ошибка загрузки транзакций в MoneyMiniAppViewModel: \(error)")
            self.transactions = []
        }
    }
    
    private func fetchAccounts() async {
        let accountDescriptor = FetchDescriptor<Account>(sortBy: [SortDescriptor(\.name)])
        do {
            let fetchedAccounts = try modelContext.fetch(accountDescriptor)
            self.accounts = fetchedAccounts
        } catch {
            print("Ошибка загрузки счетов в MoneyMiniAppViewModel: \(error)")
            self.accounts = []
        }
    }

    private func fetchCategories() async {
        do {
            let incomeRawValue = TransactionType.income.rawValue
            let incomeCategoryDescriptor = FetchDescriptor<TransactionCategory>(
                predicate: #Predicate<TransactionCategory> { category in category.typeRawValue == incomeRawValue },
                sortBy: [SortDescriptor(\.name)]
            )
            self.incomeCategories = try modelContext.fetch(incomeCategoryDescriptor)

            let expenseRawValue = TransactionType.expense.rawValue
            let expenseCategoryDescriptor = FetchDescriptor<TransactionCategory>(
                predicate: #Predicate<TransactionCategory> { category in category.typeRawValue == expenseRawValue },
                sortBy: [SortDescriptor(\.name)]
            )
            self.expenseCategories = try modelContext.fetch(expenseCategoryDescriptor)
        } catch {
            print("Ошибка загрузки категорий в MoneyMiniAppViewModel: \(error)")
            self.incomeCategories = []
            self.expenseCategories = []
        }
    }
    
    // ИСПРАВЛЕННЫЙ МЕТОД updateTotalBalance
    private func updateTotalBalance() async {
        let totalInitialBalance = accounts.reduce(0.0) { currentTotal, account in
            switch account.accountUsageType {
            case .incomeSource, .savings: // Начальные балансы этих счетов прибавляются
                return currentTotal + account.initialBalance
            case .expenseSource:
                // Начальные балансы расходных счетов ВЫЧИТАЮТСЯ
                return currentTotal - account.initialBalance // <--- ИЗМЕНЕНИЕ ЗДЕСЬ
            }
        }
        
        let totalTransactionsAmount = transactions.reduce(0.0) { $0 + $1.signedAmount }
        let overallBalance = totalInitialBalance + totalTransactionsAmount
        
        self.totalBalanceString = currencyFormatterWithCents.string(from: NSNumber(value: overallBalance)) ?? "0.00 ₽"
    }

    private func updateAnalyticsData() async {
        guard let interval = getDateInterval(for: selectedAnalyticsPeriod) else {
            self.periodicalChartData = []
            self.incomeForSelectedPeriodString = formatCurrency(0)
            self.expensesForSelectedPeriodString = formatCurrency(0)
            self.savingsForSelectedPeriodString = formatCurrency(0)
            self.showEmptyStateForChart = true
            return
        }
        let filteredTransactions = transactions.filter { interval.contains($0.timestamp) }
        let currentIncome = filteredTransactions.filter { $0.type == .income }.reduce(0.0) { $0 + $1.amount }
        let currentExpensesRaw = filteredTransactions.filter { $0.type == .expense && $0.category?.name != self.savingCategoryName }.reduce(0.0) { $0 + $1.amount }
        let currentSavingsRaw = filteredTransactions.filter { $0.type == .expense && $0.category?.name == self.savingCategoryName }.reduce(0.0) { $0 + $1.amount }
        self.incomeForSelectedPeriodString = formatCurrency(currentIncome)
        self.expensesForSelectedPeriodString = formatCurrency(abs(currentExpensesRaw))
        self.savingsForSelectedPeriodString = formatCurrency(abs(currentSavingsRaw))
        
        var dataPoints: [MonthlyDataPoint] = []
        let calendar = Calendar.current
        let (groupingComponent, labelFormat, _, incrementUnit): (Calendar.Component, String, String, Calendar.Component) = {
            switch selectedAnalyticsPeriod {
            case .week: return (.day, "EE", "yyyyMMdd", .day); case .month: return (.day, "d", "yyyyMMdd", .day)
            case .year: return (.month, "MMM", "yyyyMM", .month); case .allTime: return (.month, "MMM yy", "yyyyMM", .month)
            }
        }()
        let dateFormatter = DateFormatter(); dateFormatter.locale = Locale(identifier: "ru_RU"); dateFormatter.dateFormat = labelFormat
        var allPossibleLabels = [String: Date](); var currentDate = interval.start
        while currentDate < interval.end {
            let labelKey = dateFormatter.string(from: currentDate)
            if allPossibleLabels[labelKey] == nil { allPossibleLabels[labelKey] = currentDate }
            guard let nextDate = calendar.date(byAdding: incrementUnit, value: 1, to: currentDate), nextDate > currentDate else { break }
            currentDate = nextDate
        }
        let groupedTransactions = Dictionary(grouping: filteredTransactions) { transaction -> DateComponents in
            calendar.dateComponents([groupingComponent, (groupingComponent == .day ? .month : .year), .year], from: transaction.timestamp)
        }
        for (label, dateForLabel) in allPossibleLabels.sorted(by: { $0.value < $1.value }) {
            let componentsForLabel = calendar.dateComponents([groupingComponent, (groupingComponent == .day ? .month : .year), .year], from: dateForLabel)
            let transactionsInGroup = groupedTransactions[componentsForLabel] ?? []
            let income = transactionsInGroup.filter { $0.type == .income }.reduce(0.0) { $0 + $1.amount }
            let expenses = abs(transactionsInGroup.filter { $0.type == .expense && $0.category?.name != self.savingCategoryName }.reduce(0.0) { $0 + $1.amount })
            let savings = abs(transactionsInGroup.filter { $0.type == .expense && $0.category?.name == self.savingCategoryName }.reduce(0.0) { $0 + $1.amount })
            dataPoints.append(MonthlyDataPoint(month: label, date: dateForLabel, value: income, type: "Доход"))
            dataPoints.append(MonthlyDataPoint(month: label, date: dateForLabel, value: expenses, type: "Расход"))
            dataPoints.append(MonthlyDataPoint(month: label, date: dateForLabel, value: savings, type: "Накопления"))
        }
        self.periodicalChartData = dataPoints
        self.showEmptyStateForChart = periodicalChartData.filter({ $0.value > 0 }).isEmpty && selectedAnalyticsPeriod != .allTime
    }

    private func getDateInterval(for period: TimePeriodSelection, relativeTo date: Date = Date()) -> DateInterval? {
        let calendar = Calendar.current; let now = calendar.startOfDay(for: date); var startDate = now; var endDate = now
        switch period {
        case .week: guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: now) else { return nil }; startDate = weekInterval.start; endDate = calendar.date(byAdding: .day, value: 6, to: startDate)!
        case .month: guard let monthInterval = calendar.dateInterval(of: .month, for: now) else { return nil }; startDate = monthInterval.start; if let actualEndDate = calendar.date(byAdding: .day, value: -1, to: monthInterval.end) {endDate = actualEndDate} else { return nil }
        case .year: guard let yearInterval = calendar.dateInterval(of: .year, for: now) else { return nil }; startDate = yearInterval.start; if let actualEndDate = calendar.date(byAdding: .day, value: -1, to: yearInterval.end) {endDate = actualEndDate} else { return nil }
        case .allTime: if transactions.isEmpty { return DateInterval(start: now, end: calendar.date(byAdding: .day, value: 1, to: now) ?? now.addingTimeInterval(24*60*60-1)) }; guard let firstTransactionDate = transactions.min(by: { $0.timestamp < $1.timestamp })?.timestamp else { return DateInterval(start: now, end: calendar.date(byAdding: .day, value: 1, to: now) ?? now.addingTimeInterval(24*60*60-1)) }; startDate = calendar.startOfDay(for: firstTransactionDate); endDate = Date()
        }
        let endOfDayForEndDate = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: calendar.startOfDay(for: endDate)) ?? endDate
        return DateInterval(start: calendar.startOfDay(for: startDate), end: endOfDayForEndDate)
    }

    private func formatCurrency(_ amount: Double) -> String { return currencyFormatterGeneral.string(from: NSNumber(value: amount)) ?? "\(String(format: "%.0f", amount)) ₽" }
    
    func addTransaction(_ transaction: FinancialTransaction) { modelContext.insert(transaction); Task { await saveAndRefresh() } }
    func updateTransaction(_ transaction: FinancialTransaction) { Task { await saveAndRefresh() } }
    func deleteTransaction(transaction: FinancialTransaction) { modelContext.delete(transaction); Task { await saveAndRefresh() } }
    func deleteTransactions(at offsets: IndexSet, from sortedTransactions: [FinancialTransaction]) { offsets.forEach { modelContext.delete(sortedTransactions[$0]) }; Task { await saveAndRefresh() } }
    private func saveAndRefresh() async { do { try modelContext.save(); await fetchAllData() } catch { print("Ошибка сохранения: \(error)") } }
    func presentAddTransactionSheet(type: TransactionType, category: TransactionCategory? = nil) { sheetContext = TransactionSheetContext(type: type, category: category) }
    func presentEditTransactionSheet(transaction: FinancialTransaction) { sheetContext = TransactionSheetContext(transactionToEdit: transaction) }
    func navigateToAccounts() { coordinator?.navigateToAccounts() }
    func navigateToCategories() { coordinator?.navigateToCategories() }
    func dismissModule() { coordinator?.dismissFinancesModule() }
}
