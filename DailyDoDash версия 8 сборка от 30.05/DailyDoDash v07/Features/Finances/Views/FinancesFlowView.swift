// Features/Finances/Views/FinancesFlowView.swift
import SwiftUI

struct FinancesFlowView: View {
    @ObservedObject var coordinator: FinancesCoordinator // Используем @ObservedObject

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            coordinator.createMoneyMiniAppView() // Вызываем метод координатора для корневого View
                .navigationDestination(for: FinanceNavigationTarget.self) { target in
                    coordinator.view(for: target) // Вызываем метод координатора для дочерних View
                }
        }
    }
}
