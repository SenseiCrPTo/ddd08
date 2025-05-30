// Features/Dashboard/Views/Widgets/TasksWidgetView.swift
import SwiftUI
import SwiftData

struct TasksWidgetView: View {
    @StateObject var viewModel: TasksWidgetViewModel

    var body: some View {
        Button(action: {
            viewModel.navigateToTasksApp()
        }) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Задачи")
                        .font(.headline)
                        .fontWeight(.bold)
                    Spacer()
                }
                .padding(.bottom, 2)

                Text(viewModel.monthlyGoalStatsText)
                    .font(.caption)
                
                if viewModel.monthlyGoalProgressColor != .gray || viewModel.monthlyGoalStatsText != "Нет целей на этот месяц." {
                     ProgressView(value: viewModel.monthlyGoalProgress)
                        .progressViewStyle(LinearProgressViewStyle(tint: viewModel.monthlyGoalProgressColor))
                        .padding(.bottom, 4)
                }

                if !viewModel.topMonthlyGoals.isEmpty {
                    Text("Основные цели на месяц:")
                        .font(.caption.bold())
                    ForEach(viewModel.topMonthlyGoals) { todoItem in // <--- Переменная может называться todoItem
                        TaskWidgetRow(todo: todoItem) // <--- Передаем todoItem как todo
                    }
                }
            
                if !viewModel.tasksDueToday.isEmpty {
                    Text("Текущие задачи на сегодня:")
                        .font(.caption.bold())
                        .padding(.top, viewModel.topMonthlyGoals.isEmpty ? 0 : 4)
                    ForEach(viewModel.tasksDueToday) { todoItem in // <--- Переменная может называться todoItem
                        TaskWidgetRow(todo: todoItem) // <--- Передаем todoItem как todo
                    }
                }
            
                if viewModel.showEmptyState {
                     Text("Нет активных задач или целей!")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical)
                }
                Spacer(minLength: 0)
            }
            .padding(10)
            .frame(maxWidth: .infinity, minHeight: 170, alignment: .topLeading)
            .background(Material.thin)
            .cornerRadius(16)
            .foregroundColor(.primary)
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            viewModel.fetchTasksData()
        }
    }
}

struct TasksWidgetView_Previews: PreviewProvider {
    @MainActor
    static var previews: some View {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        // Используем Todo.self для ModelContainer
        let container = try! ModelContainer(for: Todo.self, Item.self, Habit.self)

        let context = container.mainContext
        context.insert(Todo(title: "Превью: Важная цель", isImportant: true, isMonthlyGoal: true))
        context.insert(Todo(title: "Превью: Задача на сегодня", dueDate: Date()))
        
        // Убедитесь, что TasksWidgetViewModel.swift существует и в таргете
        let viewModel = TasksWidgetViewModel(modelContext: context, coordinator: nil)

        return NavigationView {
            TasksWidgetView(viewModel: viewModel)
                .padding()
                .frame(width: 200, height: 220)
                .modelContainer(container)
        }
    }
}
