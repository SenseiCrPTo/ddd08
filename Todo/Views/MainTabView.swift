// MARK: - MainTabView.swift

import SwiftUI
import SwiftData

struct MainTabView: View {
    let modelContext: ModelContext
    let coordinator: TodoCoordinator

    @State private var selectedTab = 0

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            TabView(selection: $selectedTab) {
                TodayTabView(coordinator: coordinator)
                    .tabItem {
                        Label("Сегодня", systemImage: "calendar")
                    }
                    .tag(0)

                UpcomingTabView(coordinator: coordinator)
                    .tabItem {
                        Label("Предстоящие", systemImage: "calendar.circle")
                    }
                    .tag(1)

                TimerTabView()
                    .tabItem {
                        Label("Таймер", systemImage: "timer")
                    }
                    .tag(2)

                MatrixTabView(coordinator: coordinator)
                    .tabItem {
                        Label("Матрица", systemImage: "square.grid.3x3")
                    }
                    .tag(3)

                GoalsTabView(coordinator: coordinator)
                    .tabItem {
                        Label("Цели", systemImage: "target")
                    }
                    .tag(4)
            }

            // Плавающая кнопка "+" только вне вкладки таймера
            if selectedTab != 2 {
                FloatingAddButton {
                    coordinator.showAdd() // ⬅ переход к добавлению задачи
                }
                .padding(.trailing, 16)
                .padding(.bottom, 78)
            }
        }
        .toolbar {
            // Общий тулбар, кроме вкладки таймера
            if selectedTab != 2 {
                TodoHeaderToolbarView()
            }
        }
    }
}
