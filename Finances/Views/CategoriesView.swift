// Features/Finances/Views/CategoriesView.swift
import SwiftUI
import SwiftData

struct CategoriesView: View {
    @StateObject var viewModel: CategoriesViewModel
    @Environment(\.modelContext) private var modelContext

    @State private var showUsageAlert: Bool = false
    // @State private var usageAlertMessage: String = ""

    var body: some View {
        List {
            Section("Доходы") {
                if viewModel.incomeCategories.isEmpty && !viewModel.isLoading {
                    Text("Нет категорий доходов. Нажмите +, чтобы добавить.")
                        .foregroundColor(.gray)
                } else {
                    ForEach(viewModel.incomeCategories) { category in
                        categoryRow(category: category)
                    }
                    .onDelete { offsets in // Прямое замыкание
                        viewModel.deleteIncomeCategory(at: offsets)
                    }
                }
            }

            Section("Расходы") {
                if viewModel.expenseCategories.isEmpty && !viewModel.isLoading {
                     Text("Нет категорий расходов (кроме Накоплений). Нажмите +, чтобы добавить.")
                        .foregroundColor(.gray)
                } else {
                    ForEach(viewModel.expenseCategories) { category in
                        categoryRow(category: category)
                    }
                    .onDelete { offsets in // Прямое замыкание
                        viewModel.deleteExpenseCategory(at: offsets)
                    }
                }
            }
            
            Section("Накопления") {
                if let savings = viewModel.savingsCategoryObject {
                    HStack {
                        if let icon = savings.iconName, !icon.isEmpty { Image(systemName: icon) } else { Image(systemName: "banknote.fill") }
                        Text(savings.name)
                    }
                    .foregroundColor(.gray)
                } else if !viewModel.isLoading {
                    Text("Категория 'Накопления' не найдена/создана.")
                        .foregroundColor(.gray)
                } else {
                    EmptyView()
                }
            }
        }
        .navigationTitle("Категории")
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Menu {
                    Button("Новый Доход") { viewModel.presentAddCategorySheet(type: .income) }
                    Button("Новый Расход") { viewModel.presentAddCategorySheet(type: .expense) }
                } label: {
                    Image(systemName: "plus.circle.fill")
                }
            }
        }
        .sheet(item: $viewModel.sheetContext) { contextInfo in
            let categoryRepo = TransactionCategoryRepositoryImpl(modelContext: self.modelContext)
            let addEditVM = AddEditCategoryViewModel(
                categoryRepository: categoryRepo,
                categoryToEdit: contextInfo.categoryToEdit,
                initialTypeForNew: contextInfo.initialTypeForNew,
                onSave: {
                    viewModel.fetchCategories()
                }
            )
            AddEditCategoryView(viewModel: addEditVM)
                 .environment(\.modelContext, self.modelContext)
        }
        .alert("Удалить категорию?",
               isPresented: Binding<Bool>(
                    get: { viewModel.categoryToDeleteAlert != nil },
                    set: { if !$0 { viewModel.categoryToDeleteAlert = nil } }
               ),
               presenting: viewModel.categoryToDeleteAlert) { categoryToDelete in
            Button("Удалить", role: .destructive) {
                viewModel.confirmDeleteCategory()
            }
            Button("Отмена", role: .cancel) {
                 viewModel.cancelDelete()
            }
        } message: { categoryToDelete in
            Text("Вы уверены, что хотите удалить категорию '\(categoryToDelete.name)'? Транзакции с этой категорией не будут удалены, но могут потерять свою категорию.")
        }
        .alert("Ошибка", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "Произошла неизвестная ошибка.")
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView("Загрузка...")
            }
        }
        .onAppear {
            viewModel.fetchCategories()
        }
    }

    @ViewBuilder
    private func categoryRow(category: TransactionCategory) -> some View {
        HStack {
            if let iconName = category.iconName, !iconName.isEmpty {
                Image(systemName: iconName)
                    .foregroundColor(Color(hex: category.colorHex ?? "#808080") ?? .primary)
            } else {
                Image(systemName: "tag.fill")
                    .foregroundColor(Color(hex: category.colorHex ?? "#808080") ?? .primary)
            }
            Text(category.name)
            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if category.name.lowercased() != viewModel.savingCategoryName.lowercased() {
                viewModel.presentEditCategorySheet(category: category)
            }
        }
    }
    // Локальные методы-обертки deleteIncomeItems и deleteExpenseItems теперь не нужны,
    // так как мы используем прямое замыкание в .onDelete
}

// Previews остаются такими же
struct CategoriesView_Previews: PreviewProvider {
    @MainActor
    static var previews: some View {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: TransactionCategory.self, Account.self, FinancialTransaction.self, Item.self)
        let context = container.mainContext

        let catFood = TransactionCategory(name: "Еда", type: .expense, iconName: "fork.knife", colorHex: "#FF9500")
        let catSalary = TransactionCategory(name: "Зарплата", type: .income, iconName: "dollarsign.circle.fill", colorHex: "#34C759")
        let catSavings = TransactionCategory(name: "Накопления", type: .expense, iconName: "banknote.fill", colorHex: "#007AFF")
        context.insert(catFood)
        context.insert(catSalary)
        context.insert(catSavings)
        
        let categoryRepo = TransactionCategoryRepositoryImpl(modelContext: context)
        let viewModel = CategoriesViewModel(categoryRepository: categoryRepo, coordinator: nil)

        return NavigationView {
            CategoriesView(viewModel: viewModel)
                .modelContainer(container)
        }
    }
}
