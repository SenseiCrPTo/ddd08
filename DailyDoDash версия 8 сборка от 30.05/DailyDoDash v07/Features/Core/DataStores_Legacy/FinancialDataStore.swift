// Core/DataStores_Legacy/FinancialDataStore.swift
import SwiftUI

class FinancialDataStore: ObservableObject {
    // Свойства, которые вы использовали в MoneyWidgetView
    @Published var selectedAnalyticsPeriod: TimePeriodSelection = .week // Убедитесь, что TimePeriodSelection определен
    var periodicalChartData: [(label: String, value: Double)] { [] } // Заглушка
    var incomeForSelectedPeriodString: String { "0 $" }
    var expensesForSelectedPeriodString: String { "0 $" }
    var savingsForSelectedPeriodString: String { "0 $" }
    var totalBalanceString: String { "0 $" }
    // Добавьте другие @Published свойства или методы, если они используются

    static var preview: FinancialDataStore {
        FinancialDataStore()
    }
}
