// Features/Dashboard/Views/Widgets/BodyWidgetView.swift
import SwiftUI
import SwiftData // Убедитесь, что импорт есть

struct BodyWidgetView: View {
    @StateObject var viewModel: BodyWidgetViewModel // Используем ViewModel

    var body: some View {
        Button(action: {
            viewModel.navigateToBodyApp()
        }) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Тело")
                    .font(.system(.headline, design: .rounded).bold())
            
                // Используем данные из ViewModel
                MetricRow(label:"Вес:", value: viewModel.currentWeightString)
                MetricRow(label:"Дней тренировок (всего):", value: viewModel.totalTrainingDays)
                MetricRow(label:"Цель (нед.):", value: "\(viewModel.targetWorkoutsPerWeek) дн.")

                Text("Тренировки (нед.):")
                    .font(.caption.bold())
                    .padding(.top, 2)
                
                // Убедитесь, что HabitTrackerBar.swift существует и добавлен в таргет
                HabitTrackerBar(
                    daysDone: viewModel.workoutsThisWeekCount,
                    totalDays: viewModel.totalDaysInWeekForTracker, // Можно получать из VM
                    activeColor: viewModel.activeColorForTracker    // Можно получать из VM
                )
                
                // Пример отображения цели, если targetWorkoutsPerWeek - строка
                let targetWorkouts = Int(viewModel.targetWorkoutsPerWeek) ?? 0
                Text("\(viewModel.workoutsThisWeekCount) из \(targetWorkouts > 0 ? viewModel.targetWorkoutsPerWeek : "~") (цель)")
                    .font(.caption2)
                    .foregroundColor(.gray)
                
                if viewModel.showEmptyState && viewModel.currentWeightString == "N/A" {
                    Spacer() // Добавляем Spacer перед текстом "Нет данных", если нужно
                    Text("Нет данных для отображения")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                
                Spacer()
            }
            .padding(10)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .contentShape(Rectangle())
            .background(Material.thin)
            .cornerRadius(16)
            .foregroundColor(.primary)
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            viewModel.fetchBodyData()
        }
    }
}

struct BodyWidgetView_Previews: PreviewProvider {
    @MainActor
    static var previews: some View {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: BodyMeasurement.self, Item.self) // Добавьте другие модели при необходимости

        let context = container.mainContext
        // Добавьте тестовые BodyMeasurement
        context.insert(BodyMeasurement(timestamp: Date(), weightInKg: 70.5, isWorkoutDay: true))
        context.insert(BodyMeasurement(timestamp: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, weightInKg: 70.2, isWorkoutDay: false))
        context.insert(BodyMeasurement(timestamp: Calendar.current.date(byAdding: .day, value: -2, to: Date())!, isWorkoutDay: true))
        
        let viewModel = BodyWidgetViewModel(modelContext: context, coordinator: nil)

        return BodyWidgetView(viewModel: viewModel)
            .padding()
            .previewLayout(.fixed(width: 170, height: 170))
            .modelContainer(container)
    }
}
