// Features/Dashboard/Views/MainDashboardView.swift
import SwiftUI
import SwiftData

struct MainDashboardView: View {
    @StateObject var viewModel: MainDashboardViewModel

    let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HeaderView(appTitle: viewModel.dashboardTitle)
                        .padding(.bottom, 4)

                    LazyVGrid(columns: columns, spacing: 16) {
                        // Убедитесь, что все эти ViewModel и View существуют и в таргете
                        MoneyWidgetView(viewModel: viewModel.moneyWidgetViewModel)
                        TasksWidgetView(viewModel: viewModel.tasksWidgetViewModel)
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
        .navigationViewStyle(.stack)
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
            
            let modelContext = container.mainContext
            
            let categoryIncomePreview = TransactionCategory(name: "Зарплата (Превью)", type: .income)
            modelContext.insert(categoryIncomePreview)
            
            // Создаем счет с указанием валюты
            let accountCardPreview = Account(name: "Карта (Превью)", currencyCode: "RUB") // Пример валюты
            modelContext.insert(accountCardPreview)

            // ИСПРАВЛЕНО: Добавляем currencyCode
            modelContext.insert(FinancialTransaction(timestamp: Date(),
                                                     amount: 1000,
                                                     transactionDescription: "Доход для превью",
                                                     type: .income,
                                                     currencyCode: accountCardPreview.currencyCode, // <--- ДОБАВЛЕНО
                                                     category: categoryIncomePreview,
                                                     account: accountCardPreview))
            
            modelContext.insert(Todo(title: "Превью Задача Дашборда для Main"))
            modelContext.insert(BodyMeasurement(timestamp: Date(), weightInKg: 70))
            modelContext.insert(DiaryEntry(textContent: "Превью Дневник для Main"))
            
            let habitPreview = Habit(name: "Превью Привычка Дашборд для Main", showInWidget: true)
            modelContext.insert(habitPreview)
            let logPreview = HabitCompletionLog(date: Date(), isCompleted: true)
            logPreview.habit = habitPreview // Устанавливаем связь
            modelContext.insert(logPreview)

        } catch {
            fatalError("Не удалось создать ModelContainer для превью MainDashboardView: \(error)")
        }
        
        // Убедитесь, что AppCoordinator, DashboardCoordinator, MainDashboardViewModel существуют и в таргете
        let appCoordinator = AppCoordinator(modelContainer: container)
        let dashboardCoordinator = DashboardCoordinator(modelContext: container.mainContext, appCoordinator: appCoordinator)
        let mainDashboardViewModel = MainDashboardViewModel(modelContext: container.mainContext, coordinator: dashboardCoordinator)

        return MainDashboardView(viewModel: mainDashboardViewModel)
            .modelContainer(container)
    }
}
