// Features/Dashboard/Views/Widgets/DiaryWidgetView.swift
import SwiftUI
import SwiftData // Убедитесь, что импорт есть

struct DiaryWidgetView: View {
    @StateObject var viewModel: DiaryWidgetViewModel // Используем ViewModel

    var body: some View {
        Button(action: {
            viewModel.navigateToDiaryApp()
        }) {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Дневник")
                        .font(.headline)
                        .fontWeight(.bold)
                    Spacer()
                    Image(systemName: viewModel.moodIconName)
                        .foregroundColor(viewModel.moodColor)
                        .font(.title3)
                }

                Text(viewModel.moodName)
                    .font(.subheadline)
                    .foregroundColor(viewModel.moodColor)
                    .lineLimit(1)

                Text(viewModel.latestEntryExcerpt)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
                    .frame(minHeight: 40, alignment: .top) // Даем высоту для текста

                Spacer() // Чтобы текст напоминания был внизу

                Text(viewModel.reminderText)
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
            .padding(12)
            .frame(maxWidth: .infinity, minHeight: 160, alignment: .topLeading)
            .background(Material.thin)
            .cornerRadius(16)
            .foregroundColor(.primary)
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            viewModel.fetchDiaryData()
        }
    }
}

struct DiaryWidgetView_Previews: PreviewProvider {
    @MainActor
    static var previews: some View {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: DiaryEntry.self, Item.self) // Добавьте другие модели при необходимости

        let context = container.mainContext
        // Добавьте тестовые DiaryEntry
        context.insert(DiaryEntry(textContent: "Отличный день для превью!", moodRating: 5, moodIconName: "sun.max.fill", moodColorHex: "#FFD700"))
        context.insert(DiaryEntry(timestamp: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, textContent: "Вчера было немного пасмурно, но в целом нормально.", moodRating: 3, moodIconName: "cloud.fill", moodColorHex: "#A9A9A9"))
        
        let viewModel = DiaryWidgetViewModel(modelContext: context, coordinator: nil)

        return NavigationView { // Обертка для корректного отображения NavigationLink (если он будет внутри)
            DiaryWidgetView(viewModel: viewModel)
                .padding()
                .frame(width: 170, height: 180) // Адаптируйте размер
                .modelContainer(container)
        }
    }
}
