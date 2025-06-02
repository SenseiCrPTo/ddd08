// Features/Diary/Coordinators/DiaryCoordinator.swift
import SwiftUI
import SwiftData

@MainActor
class DiaryCoordinator: ObservableObject {
    private var modelContext: ModelContext
    private weak var parentCoordinator: AppCoordinator?

    init(modelContext: ModelContext, parentCoordinator: AppCoordinator?) {
        self.modelContext = modelContext
        self.parentCoordinator = parentCoordinator
    }

    @ViewBuilder
    func start() -> some View {
        Text("Модуль Дневника (в разработке)")
            .navigationTitle("Дневник")
    }
}
