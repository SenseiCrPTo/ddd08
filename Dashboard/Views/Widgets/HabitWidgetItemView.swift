// Features/Dashboard/Views/Widgets/HabitWidgetItemView.swift
import SwiftUI
import SwiftData // <--- ДОБАВЛЕН ЭТОТ ИМПОРТ

struct HabitWidgetItemView: View {
    // Вместо @EnvironmentObject будем получать ViewModel или данные напрямую
    // Пока для простоты передаем Habit и ссылку на ViewModel родителя для действий
    let habit: Habit
    @ObservedObject var viewModel: HabitWidgetViewModel // Ссылка на родительскую ViewModel

    private var isCompletedToday: Bool {
        viewModel.isHabitCompletedOn(habitID: habit.id, date: Date())
    }

    private var isDueToday: Bool {
        viewModel.isHabitDueOn(habit: habit, date: Date())
    }

    var body: some View {
        Button(action: {
            if isDueToday && !habit.isArchived {
                viewModel.toggleHabitCompletion(habit: habit)
            }
        }) {
            VStack(alignment: .center, spacing: 6) {
                Image(systemName: habit.iconName)
                    .font(.title3)
                    .foregroundColor(isCompletedToday && isDueToday ? .white : (Color(hex: habit.colorHex) ?? .gray))
                    .frame(width: 36, height: 36)
                    .background(isCompletedToday && isDueToday ? (Color(hex: habit.colorHex) ?? .gray) : (Color(hex: habit.colorHex) ?? .gray).opacity(0.2))
                    .clipShape(Circle())
            
                Text(habit.name)
                    .font(.caption2)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
                    .frame(height: 30) // Для выравнивания
            }
            .frame(minWidth: 0, maxWidth: .infinity)
            .padding(.vertical, 8)
            .opacity(isDueToday && !habit.isArchived ? 1.0 : (habit.isArchived ? 0.4 : 0.6))
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!isDueToday || habit.isArchived)
    }
}

// Preview для HabitWidgetItemView потребует моковую ViewModel и Habit
struct HabitWidgetItemView_Previews: PreviewProvider {
    @MainActor
    static var previews: some View {
        // Теперь ModelConfiguration и ModelContainer должны быть видны
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: Habit.self, HabitCompletionLog.self)
        let context = container.mainContext
        
        let sampleHabit = Habit(name: "Тестовая Привычка", iconName: "figure.walk", colorHex: "#34C759", showInWidget: true)
        context.insert(sampleHabit)
        
        // Убедитесь, что HabitWidgetViewModel существует и добавлен в таргет
        let viewModel = HabitWidgetViewModel(modelContext: context, coordinator: nil)
        viewModel.habitsForWidget = [sampleHabit]

        return HabitWidgetItemView(habit: sampleHabit, viewModel: viewModel)
            .padding()
            .previewLayout(.sizeThatFits)
            .modelContainer(container)
    }
}
