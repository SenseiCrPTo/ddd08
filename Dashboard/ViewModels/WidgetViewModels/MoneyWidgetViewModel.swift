// Features/Dashboard/ViewModels/WidgetViewModels/MoneyWidgetViewModel.swift
import SwiftUI
import SwiftData
import Combine

@MainActor
class MoneyWidgetViewModel: ObservableObject {
    private var modelContext: ModelContext
    private weak var coordinator: DashboardCoordinator?

    @Published var selectedAnalyticsPeriod: TimePeriodSelection = .month {
        didSet {
            Task {
                await fetchFinancialData()
            }
        }
    }
    @Published var periodicalChartData: [MonthlyDataPoint] = []
    @Published var incomeString: String = "0 ₽"
    @Published var expensesString: String = "0 ₽"
    @Published var savingsString: String = "0 ₽"
    @Published var totalBalanceString: String = "0.00 ₽"
    @Published var showEmptyStateForChart: Bool = true

    private var transactions: [FinancialTransaction] = []
    private var accounts: [Account] = []

    private var currencyFormatterGeneral: NumberFormatter
    private var currencyFormatterWithCents: NumberFormatter
    let savingCategoryName: String = "Накопления"

    init(modelContext: ModelContext, coordinator: DashboardCoordinator?) {
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
            await fetchFinancialData()
        }
    }

    func fetchFinancialData() async {
        print("MoneyWidgetViewModel: fetchFinancialData called")
        let accountDescriptor = FetchDescriptor<Account>(sortBy: [SortDescriptor(\.name)])
        do {
            self.accounts = try modelContext.fetch(accountDescriptor)
            print("MoneyWidgetViewModel: Fetched \(self.accounts.count) accounts")
        } catch {
            print("Ошибка загрузки счетов в MoneyWidgetViewModel: \(error)")
            self.accounts = []
        }

        let transactionDescriptor = FetchDescriptor<FinancialTransaction>(sortBy: [SortDescriptor(\.timestamp, order: .reverse)])
        do {
            self.transactions = try modelContext.fetch(transactionDescriptor)
            print("MoneyWidgetViewModel: Fetched \(self.transactions.count) transactions")
        } catch {
            print("Ошибка загрузки транзакций в MoneyWidgetViewModel: \(error)")
            self.transactions = []
        }
        
        await updateSummaryForPeriod()
        await updateChartDataForPeriod()
        await updateTotalBalance()
        
        self.showEmptyStateForChart = periodicalChartData.filter({ $0.value > 0 }).isEmpty && selectedAnalyticsPeriod != .allTime
    }

    private func updateSummaryForPeriod() async {
        guard let interval = getDateInterval(for: selectedAnalyticsPeriod) else {
            incomeString = formatCurrency(0, forWidget: true)
            expensesString = formatCurrency(0, forWidget: true)
            savingsString = formatCurrency(0, forWidget: true)
            return
        }
        let filteredTransactions = transactions.filter { interval.contains($0.timestamp) }
        let currentIncome = filteredTransactions.filter { $0.type == .income }.reduce(0.0) { $0 + $1.amount }
        let currentExpenses = filteredTransactions.filter { $0.type == .expense && $0.category?.name.lowercased() != savingCategoryName.lowercased() }.reduce(0.0) { $0 + $1.amount }
        let difference = currentIncome - abs(currentExpenses)
        incomeString = formatCurrency(currentIncome, forWidget: true)
        expensesString = formatCurrency(abs(currentExpenses), forWidget: true)
        savingsString = formatCurrency(difference, forWidget: true)
    }
    
    private func updateTotalBalance() async {
        let totalInitialBalance = accounts.reduce(0.0) { currentTotal, account in
            switch account.accountUsageType {
            case .incomeSource, .savings:
                return currentTotal + account.initialBalance
            case .expenseSource:
                 // Если начальный баланс расходных счетов должен вычитаться:
                 return currentTotal - account.initialBalance
                 // Если должен прибавляться (как обычные активы):
                 // return currentTotal + account.initialBalance
            }
        }
        let totalTransactionsAmount = transactions.reduce(0.0) { $0 + $1.signedAmount }
        let overallBalance = totalInitialBalance + totalTransactionsAmount
        self.totalBalanceString = currencyFormatterWithCents.string(from: NSNumber(value: overallBalance)) ?? "0.00 ₽"
        print("MoneyWidgetViewModel: Общий баланс обновлен: \(self.totalBalanceString)")
    }

    private func updateChartDataForPeriod() async {
        guard let interval = getDateInterval(for: selectedAnalyticsPeriod) else {
            self.periodicalChartData = []; return
        }
        let filteredTransactions = transactions.filter { interval.contains($0.timestamp) }
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
        let groupedTransactions = Dictionary(grouping: filteredTransactions) { calendar.dateComponents([groupingComponent, (groupingComponent == .day ? .month : .year), .year], from: $0.timestamp) }
        for (label, dateForLabel) in allPossibleLabels.sorted(by: { $0.value < $1.value }) {
            let componentsForLabel = calendar.dateComponents([groupingComponent, (groupingComponent == .day ? .month : .year), .year], from: dateForLabel)
            let transactionsInGroup = groupedTransactions[componentsForLabel] ?? []
            let income = transactionsInGroup.filter { $0.type == .income }.reduce(0.0) { $0 + $1.amount }
            let expenses = abs(transactionsInGroup.filter { $0.type == .expense && $0.category?.name.lowercased() != savingCategoryName.lowercased() }.reduce(0.0) { $0 + $1.amount })
            dataPoints.append(MonthlyDataPoint(month: label, date: dateForLabel, value: income, type: "Доход"))
            dataPoints.append(MonthlyDataPoint(month: label, date: dateForLabel, value: expenses, type: "Расход"))
        }
        self.periodicalChartData = dataPoints
    }

    // --- ПОЛНАЯ РЕАЛИЗАЦИЯ getDateInterval ---
    private func getDateInterval(for period: TimePeriodSelection, relativeTo date: Date = Date()) -> DateInterval? {
        let calendar = Calendar.current
        let now = calendar.startOfDay(for: date)
        var startDate = now
        var endDate = now

        switch period {
        case .week:
            guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: now) else { return nil }
            startDate = weekInterval.start
            endDate = calendar.date(byAdding: .day, value: 6, to: startDate)!
        case .month:
            guard let monthInterval = calendar.dateInterval(of: .month, for: now) else { return nil }
            startDate = monthInterval.start
            if let endOfMonth = calendar.date(byAdding: .day, value: -1, to: monthInterval.end) {
                 endDate = endOfMonth
            } else { return nil }
        case .year:
            guard let yearInterval = calendar.dateInterval(of: .year, for: now) else { return nil }
            startDate = yearInterval.start
            if let endOfYear = calendar.date(byAdding: .day, value: -1, to: yearInterval.end) {
                 endDate = endOfYear
            } else { return nil }
        case .allTime:
            if transactions.isEmpty {
                let endOfToday = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: now) ?? now
                return DateInterval(start: now, end: endOfToday)
            }
            guard let firstTransactionDate = transactions.min(by: { $0.timestamp < $1.timestamp })?.timestamp else {
                let endOfToday = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: now) ?? now
                return DateInterval(start: now, end: endOfToday)
            }
            startDate = calendar.startOfDay(for: firstTransactionDate)
            endDate = Date()
        }
        
        let endOfDayForEndDate = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: calendar.startOfDay(for: endDate)) ?? endDate
        return DateInterval(start: calendar.startOfDay(for: startDate), end: endOfDayForEndDate)
    }
    
    // --- ПОЛНАЯ РЕАЛИЗАЦИЯ formatCurrency ---
    private func formatCurrency(_ amount: Double, forWidget: Bool = false) -> String {
        let formatter = forWidget ? currencyFormatterGeneral : currencyFormatterWithCents
        // Убедимся, что для виджета мы используем правильный символ валюты, если он не всегда "₽"
        // Пока оставляем "₽" как основной для простоты
        return formatter.string(from: NSNumber(value: amount)) ?? "\(String(format: "%.0f", amount)) ₽"
    }

    func navigateToMoneyApp() {
        coordinator?.navigateToFinances()
    }
}
