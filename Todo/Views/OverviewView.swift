// MARK: - OverviewView.swift
import SwiftUI

struct OverviewView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("Обзор")
                        .font(.largeTitle.bold())
                        .padding(.top)

                    Text("\u{1F4CA} Здесь будут графики и отчёты по задачам, целям и активности.")
                        .foregroundColor(.secondary)
                }
                .padding()
            }
            .navigationTitle("Обзор")
        }
    }
}
