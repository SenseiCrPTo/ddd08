// Features/Dashboard/ViewModels/WidgetViewModels/BodyWidgetViewModel.swift
import SwiftUI
import SwiftData
import Combine

@MainActor
class BodyWidgetViewModel: ObservableObject {
    private var modelContext: ModelContext
    private weak var coordinator: DashboardCoordinator?

    @Published var currentWeightString: String = "N/A"
    @Published var totalTrainingDays: String = "0"    // Сделаем строкой для гибкости отображения
    @Published var targetWorkoutsPerWeek: String = "0" // Сделаем строкой
    @Published var workoutsThisWeekCount: Int = 0      // Оставим Int для HabitTrackerBar
    @Published var showEmptyState: Bool = true

    // Для HabitTrackerBar (если он остается в виджете)
    let totalDaysInWeekForTracker = 7
    var activeColorForTracker: Color = .indigo // Пример цвета

    init(modelContext: ModelContext, coordinator: DashboardCoordinator?) {
        self.modelContext = modelContext
        self.coordinator = coordinator
        // fetchBodyData() // Можно вызывать здесь или в onAppear View
    }

    func fetchBodyData() {
        // 1. Получаем последние измерения и статистику по тренировкам.
        // Эта логика будет сильно зависеть от того, как вы храните данные о тренировках.
        // Предположим, что BodyMeasurement содержит флаг isWorkoutDay.

        let sortDescriptor = SortDescriptor(\BodyMeasurement.timestamp, order: .reverse)
        let fetchDescriptor = FetchDescriptor<BodyMeasurement>(sortBy: [sortDescriptor])

        do {
            let measurements = try modelContext.fetch(fetchDescriptor)

            // Последний вес
            if let latestMeasurementWithWeight = measurements.first(where: { $0.weightInKg != nil }) {
                currentWeightString = String(format: "%.1f кг", latestMeasurementWithWeight.weightInKg!)
            } else {
                currentWeightString = "N/A"
            }

            // Статистика по тренировкам (упрощенная)
            // Общее количество дней с тренировками (если isWorkoutDay=true)
            let allWorkoutDays = measurements.filter { $0.isWorkoutDay }.count
            totalTrainingDays = "\(allWorkoutDays)"

            // Цель на неделю (это значение, вероятно, будет храниться где-то в настройках, а не в BodyMeasurement)
            // Пока заглушка:
            let targetWorkouts = 3 // Пример: пользователь установил цель 3 тренировки в неделю
            targetWorkoutsPerWeek = "\(targetWorkouts)"

            // Тренировки за текущую неделю
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            guard let weekStartDate = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)) else {
                workoutsThisWeekCount = 0
                showEmptyState = currentWeightString == "N/A" && allWorkoutDays == 0
                return
            }
            
            let workoutsThisWeek = measurements.filter {
                $0.isWorkoutDay && $0.timestamp >= weekStartDate && $0.timestamp <= today
            }.count
            workoutsThisWeekCount = workoutsThisWeek
            
            showEmptyState = currentWeightString == "N/A" && allWorkoutDays == 0 && workoutsThisWeekCount == 0

        } catch {
            print("Ошибка загрузки данных для BodyWidgetViewModel: \(error)")
            currentWeightString = "Ошибка"
            totalTrainingDays = "0"
            targetWorkoutsPerWeek = "0"
            workoutsThisWeekCount = 0
            showEmptyState = true
        }
    }

    func navigateToBodyApp() {
        coordinator?.navigateToBody()
    }
}
