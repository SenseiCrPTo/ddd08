// ✅ GoalsTabView.swift
import SwiftUI

struct GoalsTabView: View {
    let coordinator: TodoCoordinator

    var body: some View {
        VStack(spacing: 16) {
            Text("\u{1F3AF} Цели")
                .font(.largeTitle.bold())
            Text("Сюда попадут цели на месяц, год, 3 и 5 лет")
                .foregroundColor(.secondary)
        }
        .padding()
        .navigationTitle("Цели")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            TodoHeaderToolbarView()
        }
    }
}
