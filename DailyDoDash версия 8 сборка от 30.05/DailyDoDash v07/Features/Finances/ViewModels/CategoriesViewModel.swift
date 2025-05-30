// Features/Finances/ViewModels/CategoriesViewModel.swift
import SwiftUI
import SwiftData
import Combine

@MainActor
class CategoriesViewModel: ObservableObject {
    private var categoryRepository: TransactionCategoryRepositoryProtocol
    private weak var coordinator: FinancesCoordinator?

    @Published var incomeCategories: [TransactionCategory] = []
    @Published var expenseCategories: [TransactionCategory] = []
    
    let savingCategoryName = "Накопления"
    @Published var savingsCategoryObject: TransactionCategory? = nil

    @Published var sheetContext: EditCategorySheetContext? = nil
    @Published var categoryToDeleteAlert: TransactionCategory? = nil
    @Published var errorMessage: String? = nil
    @Published var isLoading: Bool = false
    
    private var didAttemptSavingsCreation = false

    init(categoryRepository: TransactionCategoryRepositoryProtocol, coordinator: FinancesCoordinator?) {
        self.categoryRepository = categoryRepository
        self.coordinator = coordinator
        fetchCategories()
    }

    func fetchCategories() {
        Task<Void, Never> {
            await performFetchCategories()
        }
    }
    
    private func performFetchCategories() async {
        self.isLoading = true
        self.errorMessage = nil
        
        do {
            let allCategories = try await categoryRepository.fetchCategories(ofType: nil)
            
            self.incomeCategories = allCategories.filter { $0.type == .income }
                                                .sorted { $0.name < $1.name }
            
            self.expenseCategories = allCategories.filter { $0.type == .expense && $0.name.lowercased() != savingCategoryName.lowercased() }
                                                 .sorted { $0.name < $1.name }
            
            self.savingsCategoryObject = allCategories.first(where: { $0.name.lowercased() == savingCategoryName.lowercased() && $0.type == .expense })
            
            if self.savingsCategoryObject == nil && !didAttemptSavingsCreation {
                self.didAttemptSavingsCreation = true
                print("Категория 'Накопления' не найдена, создаем...")
                _ = try await categoryRepository.addCategory(name: savingCategoryName, type: .expense, iconName: "banknote.fill", colorHex: "#007AFF")
                await self.performFetchCategories()
                return
            }
        } catch let error {
            if let repoError = error as? RepositoryError {
                if case .alreadyExists = repoError, didAttemptSavingsCreation {
                    print("Категория 'Накопления', вероятно, уже была создана другим вызовом.")
                    Task {
                        do {
                            let allCategories = try await categoryRepository.fetchCategories(ofType: nil)
                            self.incomeCategories = allCategories.filter { $0.type == .income }.sorted { $0.name < $1.name }
                            self.expenseCategories = allCategories.filter { $0.type == .expense && $0.name.lowercased() != savingCategoryName.lowercased() }.sorted { $0.name < $1.name }
                            self.savingsCategoryObject = allCategories.first(where: { $0.name.lowercased() == savingCategoryName.lowercased() && $0.type == .expense })
                        } catch { self.errorMessage = "Не удалось повторно загрузить категории после проверки 'Накоплений'." }
                    }
                } else {
                    self.errorMessage = "Не удалось загрузить категории: \(repoError.localizedDescription)"
                }
            } else {
                self.errorMessage = "Не удалось загрузить категории: \(error.localizedDescription)"
            }
             print("Полная ошибка загрузки категорий в CategoriesViewModel: \(error)")
        }
        self.isLoading = false
    }
    
    func deleteIncomeCategory(at offsets: IndexSet) {
        for index in offsets { prepareForDelete(incomeCategories[index]) }
    }

    func deleteExpenseCategory(at offsets: IndexSet) {
        for index in offsets { prepareForDelete(expenseCategories[index]) }
    }

    func prepareForDelete(_ category: TransactionCategory) {
        if category.name.lowercased() == savingCategoryName.lowercased() {
            errorMessage = "Категорию '\(savingCategoryName)' нельзя удалить."
            return
        }
        self.categoryToDeleteAlert = category
    }
    
    func confirmDeleteCategory() {
        guard let categoryToDelete = categoryToDeleteAlert else { return }
        
        isLoading = true
        errorMessage = nil
        
        Task<Void, Never> {
            await performConfirmDeleteCategory(category: categoryToDelete)
        }
    }
    
    private func performConfirmDeleteCategory(category: TransactionCategory) async {
        do {
            try await categoryRepository.deleteCategory(category)
            self.categoryToDeleteAlert = nil // Успешно удалено, сбрасываем для алерта
            await self.performFetchCategories()
        } catch let repoError as RepositoryError {
            switch repoError {
            case .entityInUse(let message):
                self.errorMessage = message
                self.categoryToDeleteAlert = nil // Сбрасываем, так как подтверждение обработано (хоть и с ошибкой)
            default:
                self.errorMessage = "Ошибка удаления категории: \(repoError.localizedDescription)"
                self.categoryToDeleteAlert = nil // Сбрасываем и при других ошибках репозитория
            }
            print("Ошибка удаления категории (репозиторий): \(repoError)")
        } catch {
            self.errorMessage = "Неизвестная ошибка удаления категории: \(error.localizedDescription)"
            print("Неизвестная ошибка удаления категории: \(error)")
            self.categoryToDeleteAlert = nil // Сбрасываем и при неизвестных ошибках
        }
        self.isLoading = false
    }
    
    func cancelDelete() {
        self.categoryToDeleteAlert = nil
    }

    func presentAddCategorySheet(type: TransactionType) {
        sheetContext = EditCategorySheetContext(initialTypeForNew: type)
    }
    func presentEditCategorySheet(category: TransactionCategory) {
        if category.name.lowercased() == savingCategoryName.lowercased() { errorMessage = "Категорию '\(savingCategoryName)' нельзя редактировать."; return }
        sheetContext = EditCategorySheetContext(categoryToEdit: category)
    }
}
