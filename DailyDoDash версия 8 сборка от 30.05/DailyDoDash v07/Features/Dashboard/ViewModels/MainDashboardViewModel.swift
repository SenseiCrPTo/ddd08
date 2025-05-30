// Features/Dashboard/ViewModels/MainDashboardViewModel.swift
import SwiftUI
import SwiftData
import Combine

@MainActor
class MainDashboardViewModel: ObservableObject {
    private var modelContext: ModelContext
    private weak var coordinator: DashboardCoordinator?

    @Published var moneyWidgetViewModel: MoneyWidgetViewModel
    @Published var tasksWidgetViewModel: TasksWidgetViewModel
    @Published var bodyWidgetViewModel: BodyWidgetViewModel
    @Published var diaryWidgetViewModel: DiaryWidgetViewModel
    @Published var habitWidgetViewModel: HabitWidgetViewModel

    @Published var dashboardTitle: String = "DayDash"

    init(modelContext: ModelContext, coordinator: DashboardCoordinator?) {
        self.modelContext = modelContext
        self.coordinator = coordinator
        
        // Инициализируем ViewModel'и для виджетов
        // Убедитесь, что все эти ViewModel классы существуют и добавлены в таргет
        self.moneyWidgetViewModel = MoneyWidgetViewModel(modelContext: modelContext, coordinator: coordinator)
        self.tasksWidgetViewModel = TasksWidgetViewModel(modelContext: modelContext, coordinator: coordinator)
        self.bodyWidgetViewModel = BodyWidgetViewModel(modelContext: modelContext, coordinator: coordinator)
        self.diaryWidgetViewModel = DiaryWidgetViewModel(modelContext: modelContext, coordinator: coordinator)
        self.habitWidgetViewModel = HabitWidgetViewModel(modelContext: modelContext, coordinator: coordinator)
    }
}
