import SwiftUI
import SwiftData

struct TodoWidgetView: View {
    @StateObject var viewModel: TodoWidgetViewModel

    var body: some View {
        Button(action: {
            viewModel.coordinator?.navigateToTodos()
        }) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Задачи")
                        .font(.headline)
                        .fontWeight(.bold)
                    Spacer()
                }
                .padding(.bottom, 2)

                Text("Целей на месяц: \(viewModel.monthlyStats.completed)/\(viewModel.monthlyStats.total)")
                    .font(.caption)

                if viewModel.monthlyStats.total > 0 {
                    ProgressView(value: Double(viewModel.monthlyStats.completed) / Double(viewModel.monthlyStats.total))
                        .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                        .padding(.bottom, 4)
                }

                if !viewModel.topMonthlyGoals.isEmpty {
                    Text("Основные цели на месяц:")
                        .font(.caption.bold())
                    ForEach(viewModel.topMonthlyGoals) { todo in
                        TodoWidgetRow(todo: todo)
                    }
                }

                if !viewModel.todayTodos.isEmpty {
                    Text("Задачи на сегодня:")
                        .font(.caption.bold())
                        .padding(.top, viewModel.topMonthlyGoals.isEmpty ? 0 : 4)
                    ForEach(viewModel.todayTodos) { todo in
                        TodoWidgetRow(todo: todo)
                    }
                }

                if viewModel.topMonthlyGoals.isEmpty && viewModel.todayTodos.isEmpty {
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
            viewModel.fetchTodos()
        }
    }
}
