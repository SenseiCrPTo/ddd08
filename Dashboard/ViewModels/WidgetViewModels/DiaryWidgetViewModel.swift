// Features/Dashboard/ViewModels/WidgetViewModels/DiaryWidgetViewModel.swift
import SwiftUI
import SwiftData
import Combine

@MainActor
class DiaryWidgetViewModel: ObservableObject {
    private var modelContext: ModelContext
    private weak var coordinator: DashboardCoordinator?

    @Published var moodIconName: String = "questionmark.circle.fill"
    @Published var moodName: String = "Нет данных"
    @Published var moodColor: Color = .gray
    @Published var latestEntryExcerpt: String = "Нет записей для отображения."
    @Published var reminderText: String = "Как прошел ваш день?"
    @Published var showEmptyState: Bool = true

    init(modelContext: ModelContext, coordinator: DashboardCoordinator?) {
        self.modelContext = modelContext
        self.coordinator = coordinator
        // fetchDiaryData() // Вызывается в onAppear во View
    }

    func fetchDiaryData() {
        let sortDescriptor = SortDescriptor(\DiaryEntry.timestamp, order: .reverse)
        var fetchDescriptor = FetchDescriptor<DiaryEntry>(sortBy: [sortDescriptor])
        fetchDescriptor.fetchLimit = 1

        do {
            let latestEntries = try modelContext.fetch(fetchDescriptor)
            if let latestEntry = latestEntries.first {
                moodIconName = latestEntry.moodIconName ?? "face.smiling"
                moodName = moodRatingToName(latestEntry.moodRating)
                
                // ВНИМАНИЕ: Следующая строка вызовет ошибку, если ColorExtension.swift
                // с init?(hex: String) не существует или не добавлен в таргет.
                moodColor = Color(hex: latestEntry.moodColorHex ?? "#808080") ?? .gray

                if latestEntry.textContent.isEmpty {
                    latestEntryExcerpt = "Запись без текста."
                } else {
                    latestEntryExcerpt = String(latestEntry.textContent.prefix(100)) + (latestEntry.textContent.count > 100 ? "..." : "")
                }
                
                reminderText = "Последняя запись: \(latestEntry.timestamp.formatted(.relative(presentation: .named))) назад"
                showEmptyState = false
            } else {
                moodIconName = "plus.circle.fill"
                moodName = "Добавьте запись"
                moodColor = .gray
                latestEntryExcerpt = "Начните вести свой дневник сегодня!"
                reminderText = "Запишите свои мысли и чувства."
                showEmptyState = true
            }
        } catch {
            print("Ошибка загрузки данных для DiaryWidgetViewModel: \(error)")
            moodName = "Ошибка"
            latestEntryExcerpt = "Не удалось загрузить данные."
            showEmptyState = true
        }
    }

    private func moodRatingToName(_ rating: Int?) -> String {
        guard let rating = rating else { return "Не указано" }
        switch rating {
        case 5: return "Отлично"
        case 4: return "Хорошо"
        case 3: return "Нормально"
        case 2: return "Плохо"
        case 1: return "Ужасно"
        default: return "Неизвестно (\(rating))"
        }
    }

    func navigateToDiaryApp() {
        coordinator?.navigateToDiary()
    }
}
