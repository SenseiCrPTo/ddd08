// Features/Finances/Views/AddEditCategoryView.swift
import SwiftUI
import SwiftData

struct AddEditCategoryView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel: AddEditCategoryViewModel

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Название категории")) {
                    TextField("Введите название", text: $viewModel.categoryName)
                }

                if !viewModel.isEditing && viewModel.categoryName.lowercased() != viewModel.savingCategoryName.lowercased() {
                    Section(header: Text("Тип категории")) {
                        Picker("Тип", selection: $viewModel.selectedType) {
                            ForEach(TransactionType.allCases) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                }
                // TODO: Добавить выбор иконки и цвета
                // Section("Оформление") {
                //     TextField("Имя иконки (SF Symbol)", text: $viewModel.iconName)
                //     ColorPicker("Цвет категории", selection: Binding(
                //         get: { Color(hex: viewModel.selectedColorHex) ?? .gray },
                //         set: { viewModel.selectedColorHex = $0.toHex() ?? "#808080" }
                //     ))
                // }
            }
            .navigationTitle(viewModel.navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(viewModel.saveButtonLabel) {
                        viewModel.saveCategory()
                        // dismiss() будет вызван из onSave в ViewModel или здесь, если saveCategory не асинхронный
                        if viewModel.errorMessage == nil { // Закрываем только если нет ошибки
                           dismiss()
                        }
                    }
                    .disabled(viewModel.categoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            // Показываем алерт, если есть ошибка
            .alert("Ошибка", isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Button("OK") { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "Произошла неизвестная ошибка.")
            }
        }
    }
}

// Previews для AddEditCategoryView
struct AddEditCategoryView_Previews: PreviewProvider {
    @MainActor
    static var previews: some View {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: TransactionCategory.self, Account.self, FinancialTransaction.self, Item.self)
        let context = container.mainContext

        // Создаем экземпляр репозитория для превью
        let categoryRepositoryPreview = TransactionCategoryRepositoryImpl(modelContext: context)

        // 1. Для новой категории дохода
        let addNewIncomeVM = AddEditCategoryViewModel(
            categoryRepository: categoryRepositoryPreview, // <--- ИЗМЕНЕНО
            initialTypeForNew: .income,
            onSave: { print("Preview: Новая категория дохода сохранена") }
        )

        // 2. Для новой категории расхода
        let addNewExpenseVM = AddEditCategoryViewModel(
            categoryRepository: categoryRepositoryPreview, // <--- ИЗМЕНЕНО
            initialTypeForNew: .expense,
            onSave: { print("Preview: Новая категория расхода сохранена") }
        )
        
        // 3. Для редактирования существующей категории
        let existingCategory = TransactionCategory(name: "Старая Еда Preview", type: .expense)
        context.insert(existingCategory) // Важно вставить в контекст перед редактированием
        
        let editExistingVM = AddEditCategoryViewModel(
            categoryRepository: categoryRepositoryPreview, // <--- ИЗМЕНЕНО
            categoryToEdit: existingCategory,
            onSave: { print("Preview: Категория отредактирована") }
        )

        return Group {
            AddEditCategoryView(viewModel: addNewIncomeVM)
                .previewDisplayName("Новый Доход")
                .modelContainer(container)

            AddEditCategoryView(viewModel: addNewExpenseVM)
                .previewDisplayName("Новый Расход")
                .modelContainer(container)
            
            AddEditCategoryView(viewModel: editExistingVM)
                .previewDisplayName("Редактировать Категорию")
                .modelContainer(container)
        }
    }
}
