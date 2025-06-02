// Features/Dashboard/Views/Widgets/MoneyWidgetView.swift
import SwiftUI
import SwiftData

struct MoneyWidgetView: View {
    @StateObject var viewModel: MoneyWidgetViewModel

    var body: some View {
        Button(action: {
            viewModel.navigateToMoneyApp()
        }) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Финансы")
                        .font(.system(.headline, design: .rounded).bold())
                        .minimumScaleFactor(0.9)
                        .lineLimit(1)
                    Spacer()
                    Picker("Период", selection: $viewModel.selectedAnalyticsPeriod) {
                        ForEach(TimePeriodSelection.allCases) { period in
                            Text(period.shortLabel).tag(period)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding(.trailing, -8)
                }

                if viewModel.showEmptyStateForChart && viewModel.selectedAnalyticsPeriod != .allTime {
                     Text("Нет данных за выбранный период.")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .frame(height: 100, alignment: .center)
                        .frame(maxWidth: .infinity)
                } else {
                    let xAxisLabel: String = {
                        switch viewModel.selectedAnalyticsPeriod {
                        case .week, .month: return "День"
                        case .year, .allTime: return "Месяц"
                        }
                    }()
                    ClearChartView(data: viewModel.periodicalChartData, xAxisLabel: xAxisLabel)
                        .frame(height: 100).padding(.bottom, 2)
                }
                MetricRow(label: "Доход (\(viewModel.selectedAnalyticsPeriod.shortLabel)):", value: viewModel.incomeString, valueColor: .green)
                MetricRow(label: "Расход (\(viewModel.selectedAnalyticsPeriod.shortLabel)):", value: viewModel.expensesString, valueColor: .red)
                MetricRow(label: "Разница (\(viewModel.selectedAnalyticsPeriod.shortLabel)):", value: viewModel.savingsString, valueColor: (Double(viewModel.savingsString.replacingOccurrences(of: " ₽", with: "").replacingOccurrences(of: ",", with: ".")) ?? 0) < 0 ? .red : .blue)
                MetricRow(label: "Общий баланс:", value: viewModel.totalBalanceString, valueColor: .primary)
            }
            .padding(10)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .contentShape(Rectangle())
            .background(Material.thin)
            .cornerRadius(16)
            .foregroundColor(.primary)
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            Task {
               await viewModel.fetchFinancialData()
            }
        }
    }
}

struct MoneyWidgetView_Previews: PreviewProvider {
    @MainActor
    static var previews: some View {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: FinancialTransaction.self, Item.self, TransactionCategory.self, Account.self, Todo.self)

        let modelContext = container.mainContext // Используем modelContext
        
        let categorySalaryPreview = TransactionCategory(name: "Зарплата", type: .income)
        let categoryFoodPreview = TransactionCategory(name: "Еда", type: .expense)
        modelContext.insert(categorySalaryPreview) // ИСПРАВЛЕНО
        modelContext.insert(categoryFoodPreview)  // ИСПРАВЛЕНО

        let accountCardPreview = Account(name: "Карта Preview", currencyCode: "RUB")
        modelContext.insert(accountCardPreview) // ИСПРАВЛЕНО

        modelContext.insert(FinancialTransaction(timestamp: Date(),        // ИСПРАВЛЕНО
                                             amount: 100,
                                             transactionDescription: "Доход 1 Preview",
                                             type: .income,
                                             currencyCode: accountCardPreview.currencyCode,
                                             category: categorySalaryPreview,
                                             account: accountCardPreview))
                                             
        modelContext.insert(FinancialTransaction(timestamp: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, // ИСПРАВЛЕНО
                                             amount: 50,
                                             transactionDescription: "Расход 1 Preview",
                                             type: .expense,
                                             currencyCode: accountCardPreview.currencyCode,
                                             category: categoryFoodPreview,
                                             account: accountCardPreview))
        
        let viewModel = MoneyWidgetViewModel(modelContext: modelContext, coordinator: nil)

        return MoneyWidgetView(viewModel: viewModel)
            .padding()
            .frame(width: 200, height: 230)
            .modelContainer(container)
    }
}
