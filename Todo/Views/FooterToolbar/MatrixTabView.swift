// ✅ MatrixTabView.swift
import SwiftUI

struct MatrixTabView: View {
    let coordinator: TodoCoordinator

    var body: some View {
        VStack {
            Spacer()
            Label("\u{1F4CA} Здесь появится визуализация приоритетов", systemImage: "chart.bar")
                .foregroundColor(.secondary)
            Spacer()
        }
        .navigationTitle("Матрица")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            TodoHeaderToolbarView()
        }
    }
}
