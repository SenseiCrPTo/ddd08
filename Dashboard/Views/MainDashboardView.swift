import SwiftUI
import SwiftData

struct MainDashboardView: View {
    @StateObject var viewModel: MainDashboardViewModel

    let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HeaderView(appTitle: viewModel.dashboardTitle)
                    .padding(.bottom, 4)

                LazyVGrid(columns: columns, spacing: 16) {
                    MoneyWidgetView(viewModel: viewModel.moneyWidgetViewModel)
                    TodoWidgetView(viewModel: viewModel.todoWidgetViewModel)
                    BodyWidgetView(viewModel: viewModel.bodyWidgetViewModel)
                    DiaryWidgetView(viewModel: viewModel.diaryWidgetViewModel)
                }

                HabitWidgetView(viewModel: viewModel.habitWidgetViewModel)
                    .padding(.top, 8)

                Spacer()
            }
            .padding(.horizontal)
        }
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        .navigationBarHidden(true)
    }
}

struct MainDashboardView_Previews: PreviewProvider {
    @MainActor
    static var previews: some View {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container: ModelContainer

        do {
            let schema = Schema([
                Item.self, Habit.self, HabitCompletionLog.self,
                Todo.self,
                DiaryEntry.self, FinancialTransaction.self, BodyMeasurement.self,
                TransactionCategory.self, Account.self
            ])
            container = try ModelContainer(for: schema, configurations: [config])
            let context = container.mainContext

            let categoryIncomePreview = TransactionCategory(name: "Зарплата (Превью)", type: .income)
            context.insert(categoryIncomePreview)

            let accountCardPreview = Account(name: "Карта (Превью)", currencyCode: "RUB")
            context.insert(accountCardPreview)

            context.insert(FinancialTransaction(
                timestamp: Date(),
                amount: 1000,
                transactionDescription: "Доход для превью",
                type: .income,
                currencyCode: accountCardPreview.currencyCode,
                category: categoryIncomePreview,
                account: accountCardPreview
            ))

            context.insert(Todo(title: "Превью Задача Дашборда"))
            context.insert(BodyMeasurement(timestamp: Date(), weightInKg: 70))
            context.insert(DiaryEntry(textContent: "Превью Дневник"))

            let habit = Habit(name: "Превью Привычка", showInWidget: true)
            context.insert(habit)
            let log = HabitCompletionLog(date: Date(), isCompleted: true)
            log.habit = habit
            context.insert(log)

        } catch {
            fatalError("Ошибка при создании ModelContainer: \(error)")
        }

        let appCoordinator = AppCoordinator(modelContainer: container)
        let dashboardCoordinator = DashboardCoordinator(
            modelContext: container.mainContext,
            appCoordinator: appCoordinator
        )

        let mainDashboardViewModel = MainDashboardViewModel(
            modelContext: container.mainContext,
            coordinator: dashboardCoordinator
        )

        return MainDashboardView(viewModel: mainDashboardViewModel)
            .modelContainer(container)
    }
}
