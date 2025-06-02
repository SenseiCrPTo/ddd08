// MARK: - SearchView.swift
import SwiftUI

struct SearchView: View {
    @State private var query: String = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                TextField("Поиск задач...", text: $query)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Spacer()
                Text("🔍 Введите текст для поиска")
                    .foregroundColor(.secondary)
                Spacer()
            }
            .navigationTitle("Поиск")
        }
    }
}
