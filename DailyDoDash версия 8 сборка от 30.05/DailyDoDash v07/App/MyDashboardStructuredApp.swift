// App/MyDashboardStructuredApp.swift
import SwiftUI
import SwiftData

@main
struct MyDashboardStructuredApp: App {
    @StateObject private var appCoordinator: AppCoordinator
    private let container: ModelContainer

    init() {
        let tempContainer: ModelContainer
        do {
            // --- ВКЛЮЧИТЕ ВСЕ ВАШИ МОДЕЛИ В СХЕМУ ---
            let schema = Schema([
                Item.self,
                Habit.self,
                HabitCompletionLog.self,
                Todo.self,
                DiaryEntry.self,
                FinancialTransaction.self,
                BodyMeasurement.self,
                TransactionCategory.self,
                Account.self
            ])
            // ----------------------------------------------------

            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            tempContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
            // ЭТО СООБЩЕНИЕ В КОНСОЛИ ДОЛЖНО ПОКАЗАТЬ ВСЕ 9 МОДЕЛЕЙ
            print("--- ModelContainer успешно создан со схемой: \(schema.entities.map { $0.name ?? "N/A" }.sorted()) ---")
        } catch {
            print("--- КРИТИЧЕСКАЯ ОШИБКА: Не удалось создать ModelContainer. ---")
            print("Ошибка: \(error)")
            if let swiftDataError = error as? SwiftDataError {
                print("Детали ошибки SwiftData: \(swiftDataError)")
                // Можно добавить больше деталей, если это поможет
                // let mirror = Mirror(reflecting: swiftDataError)
                // if let explanation = mirror.descendant("_explanation") as? String? {
                //     print("SwiftDataError _explanation: \(explanation ?? "N/A")")
                // }
            }
            fatalError("Не удалось создать ModelContainer: \(error)")
        }
        
        self.container = tempContainer
        _appCoordinator = StateObject(wrappedValue: AppCoordinator(modelContainer: tempContainer))
    }

    var body: some Scene {
        WindowGroup {
            NavigationView {
                if let rootView = appCoordinator.currentRootViewWrapper {
                    rootView
                } else {
                    ProgressView().onAppear { appCoordinator.start() }
                }
            }
            .navigationViewStyle(.stack)
        }
        .modelContainer(container)
    }
}
