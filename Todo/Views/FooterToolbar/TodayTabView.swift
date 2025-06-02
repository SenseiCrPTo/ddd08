// ✅ TodayTabView.swift
import SwiftUI

struct TodayTabView: View {
    let coordinator: TodoCoordinator

    var body: some View {
        VStack {
            Spacer()
            Label("\u{1F4C5} Здесь появятся задачи и события сегодняшнего дня", systemImage: "calendar")
                .foregroundColor(.secondary)
            Spacer()
        }
        .navigationTitle("Сегодня")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            TodoHeaderToolbarView()
        }
    }
}
