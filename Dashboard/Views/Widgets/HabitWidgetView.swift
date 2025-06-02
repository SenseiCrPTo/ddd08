// Features/Dashboard/Views/Widgets/HabitWidgetView.swift
import SwiftUI
import SwiftData // Убедитесь, что импорт есть

struct HabitWidgetView: View {
    @StateObject var viewModel: HabitWidgetViewModel // Используем ViewModel

    // Колонки для сетки привычек
    let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10), // Можно 3 или 4 колонки
        GridItem(.flexible(), spacing: 10)
    ]
    
    var body: some View {
        Button(action: {
            viewModel.navigateToHabitsApp()
        }) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Привычки")
                    .font(.headline)
                    .fontWeight(.bold) // Добавил для консистентности
                    .padding(.bottom, 4)
                    .foregroundColor(.primary)

                HStack {
                    VStack(alignment: .leading) {
                        Text("Всего активных:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(viewModel.totalActiveHabits)")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                    }
                    Spacer()
                    VStack(alignment: .leading) {
                        Text("Выполнено сегодня:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(String(format: "%.0f%%", viewModel.dailyCompletionPercentage))
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(viewModel.completionColor(viewModel.dailyCompletionPercentage))
                    }
                }
                .padding(.bottom, 8)

                if viewModel.showEmptyState {
                    Text("Нет привычек для отображения на виджете или активных привычек.")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, minHeight: 60)
                        .padding(.vertical)
                } else {
                    LazyVGrid(columns: columns, alignment: .center, spacing: 10) {
                        ForEach(viewModel.habitsForWidget) { habit in
                            HabitWidgetItemView(habit: habit, viewModel: viewModel)
                        }
                    }
                    // Динамический Spacer для выравнивания, если элементов мало
                    if viewModel.habitsForWidget.count > 0 && viewModel.habitsForWidget.count < (columns.count == 2 ? 3 : 5) { // Примерная логика для 2 или 4 колонок
                         Spacer().frame(minHeight: 40)
                    }
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, minHeight: 180, alignment: .topLeading)
            .background(Material.thin)
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            viewModel.fetchHabitData()
        }
    }
}

struct HabitWidgetView_Previews: PreviewProvider {
    @MainActor
    static var previews: some View {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: Habit.self, HabitCompletionLog.self, Item.self) // Добавьте все нужные модели

        let context = container.mainContext
        // Добавьте тестовые Habit объекты
        let habit1 = Habit(name: "Пить воду", iconName: "drop.fill", colorHex: "#007AFF", showInWidget: true)
        let habit2 = Habit(name: "Читать книгу", iconName: "book.fill", colorHex: "#FF9500", showInWidget: true)
        let habit3 = Habit(name: "Тренировка", iconName: "figure.walk", colorHex: "#34C759", showInWidget: true)
        let habit4 = Habit(name: "Медитация", iconName: "heart.fill", colorHex: "#AF52DE", showInWidget: true)
        let habit5 = Habit(name: "Скрытая привычка", iconName: "eye.slash", colorHex: "#8E8E93", showInWidget: false)
        
        context.insert(habit1)
        context.insert(habit2)
        context.insert(habit3)
        context.insert(habit4)
        context.insert(habit5)

        // Добавим лог выполнения для одной из привычек
        let log = HabitCompletionLog(date: Calendar.current.startOfDay(for: Date()), isCompleted: true)
        log.habit = habit1 // Связываем с привычкой
        context.insert(log)
        // habit1.completionLogs?.append(log) // SwiftData должно само обработать

        let viewModel = HabitWidgetViewModel(modelContext: context, coordinator: nil)

        return NavigationView {
            HabitWidgetView(viewModel: viewModel)
                .padding()
                .frame(width: 340, height: 240) // Сделаем превью пошире для 4 колонок
                .modelContainer(container)
        }
    }
}
