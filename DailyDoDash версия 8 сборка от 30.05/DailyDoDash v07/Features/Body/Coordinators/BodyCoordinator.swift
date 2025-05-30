// Features/Body/Coordinators/BodyCoordinator.swift
import SwiftUI
import SwiftData

@MainActor
class BodyCoordinator: ObservableObject {
    private var modelContext: ModelContext
    private weak var parentCoordinator: AppCoordinator?

    init(modelContext: ModelContext, parentCoordinator: AppCoordinator?) {
        self.modelContext = modelContext
        self.parentCoordinator = parentCoordinator
    }

    @ViewBuilder
    func start() -> some View {
        Text("Модуль Тела (в разработке)")
            .navigationTitle("Тело")
    }
}
