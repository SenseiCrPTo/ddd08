// Features/Finances/ViewModels/AddEditCategoryViewModel.swift
import SwiftUI
import SwiftData

@MainActor
class AddEditCategoryViewModel: ObservableObject {
    private var categoryRepository: TransactionCategoryRepositoryProtocol
    
    var categoryToEdit: TransactionCategory?

    @Published var categoryName: String = ""
    @Published var selectedType: TransactionType
    @Published var iconName: String = "tag.fill"
    @Published var selectedColorHex: String = "#808080"
    
    @Published var errorMessage: String? = nil
    @Published var isLoading: Bool = false

    var isEditing: Bool { categoryToEdit != nil }
    var navigationTitle: String { isEditing ? "Редактировать категорию" : "Новая категория" }
    var saveButtonLabel: String { isEditing ? "Сохранить" : "Добавить" }

    let savingCategoryName = "Накопления"
    var onSave: () -> Void = {}

    init(categoryRepository: TransactionCategoryRepositoryProtocol,
         categoryToEdit: TransactionCategory? = nil,
         initialTypeForNew: TransactionType = .expense,
         onSave: @escaping () -> Void) {
        self.categoryRepository = categoryRepository
        self.categoryToEdit = categoryToEdit
        self.onSave = onSave

        if let cat = categoryToEdit {
            self.categoryName = cat.name
            self.selectedType = cat.type
            self.iconName = cat.iconName ?? "tag.fill"
            self.selectedColorHex = cat.colorHex ?? "#808080"
        } else {
            self.selectedType = initialTypeForNew
        }
    }

    func saveCategory() {
        let trimmedName = categoryName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            errorMessage = "Имя категории не может быть пустым."
            return
        }
        
        if let cat = categoryToEdit {
            if cat.name.lowercased() == savingCategoryName.lowercased() &&
               (trimmedName.lowercased() != savingCategoryName.lowercased() || selectedType != .expense) {
                errorMessage = "Категорию 'Накопления' нельзя переименовать или изменить ее тип."
                return
            }
        } else {
            if trimmedName.lowercased() == savingCategoryName.lowercased() && selectedType != .expense {
                errorMessage = "Имя категории '\(savingCategoryName)' зарезервировано для типа 'Расход'."
                return
            }
        }

        isLoading = true
        errorMessage = nil

        // Теперь можно использовать просто Task, так как конфликт имен с моделью устранен
        Task<Void, Never> { // Можете попробовать и просто Task { ... }
            await performSaveCategory(trimmedName: trimmedName)
        }
    }

    private func performSaveCategory(trimmedName: String) async {
        do {
            if try await self.categoryRepository.categoryExists(name: trimmedName, type: self.selectedType, excludingId: self.categoryToEdit?.id) {
                self.errorMessage = "Категория с именем '\(trimmedName)' для типа '\(self.selectedType.rawValue)' уже существует."
                self.isLoading = false
                return
            }

            if let catToUpdate = self.categoryToEdit {
                try await self.categoryRepository.updateCategory(catToUpdate,
                                                           newName: trimmedName,
                                                           newType: self.selectedType,
                                                           newIconName: self.iconName,
                                                           newColorHex: self.selectedColorHex)
            } else {
                _ = try await self.categoryRepository.addCategory(name: trimmedName,
                                                          type: self.selectedType,
                                                          iconName: self.iconName,
                                                          colorHex: self.selectedColorHex)
            }
            self.isLoading = false
            self.onSave()
        } catch let repoError as RepositoryError {
            switch repoError {
            case .alreadyExists:
                self.errorMessage = "Категория с таким именем и типом уже существует."
            default:
                self.errorMessage = "Ошибка сохранения категории: \(repoError.localizedDescription)"
            }
            self.isLoading = false
        } catch {
            self.errorMessage = "Неизвестная ошибка сохранения: \(error.localizedDescription)"
            self.isLoading = false
        }
    }
}
