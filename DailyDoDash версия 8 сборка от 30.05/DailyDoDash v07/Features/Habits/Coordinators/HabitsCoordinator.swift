// Features/Habits/Coordinators/HabitsCoordinator.swift
import SwiftUI
import SwiftData

@MainActor
class HabitsCoordinator: ObservableObject {
    private var modelContext: ModelContext
    private weak var parentCoordinator: AppCoordinator?

    init(modelContext: ModelContext, parentCoordinator: AppCoordinator?) {
        self.modelContext = modelContext
        self.parentCoordinator = parentCoordinator
    }

    @ViewBuilder
    func start() -> some View {
        Text("Модуль Привычек (в разработке)")
            .navigationTitle("Привычки")
    }
}
