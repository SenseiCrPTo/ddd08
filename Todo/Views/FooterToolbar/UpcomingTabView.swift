// ✅ UpcomingTabView.swift
import SwiftUI

struct UpcomingTabView: View {
    let coordinator: TodoCoordinator

    var body: some View {
        TodoListView(viewModel: TodoListViewModel(
            context: coordinator.modelContext,
            coordinator: coordinator
        ))
        .navigationTitle("Предстоящие")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            TodoHeaderToolbarView()
        }
    }
}
