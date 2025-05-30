// Features/Finances/Coordinators/FinancesCoordinator.swift
import SwiftUI
import SwiftData

// Убедитесь, что FinanceNavigationTarget.swift существует и добавлен в таргет
// enum FinanceNavigationTarget: String, Hashable, CaseIterable { ... }

@MainActor
class FinancesCoordinator: ObservableObject {
    @Published var path = NavigationPath()
    
    private var modelContext: ModelContext
    private weak var parentCoordinator: AppCoordinator?

    init(modelContext: ModelContext, parentCoordinator: AppCoordinator?) {
        self.modelContext = modelContext
        self.parentCoordinator = parentCoordinator
        print("FinancesCoordinator initialized")
    }

    @ViewBuilder
    func start() -> some View {
        // Убедитесь, что FinancesFlowView.swift существует и добавлен в таргет
        FinancesFlowView(coordinator: self)
    }
    
    @ViewBuilder
    func createMoneyMiniAppView() -> some View {
        // Убедитесь, что MoneyMiniAppViewModel и MoneyMiniAppView существуют и в таргете
        let viewModel = MoneyMiniAppViewModel(modelContext: modelContext, coordinator: self)
        return MoneyMiniAppView(viewModel: viewModel)
    }
    
    func navigateToAccounts() {
        print("FinancesCoordinator: Навигация к Счетам (добавление в path)")
        path.append(FinanceNavigationTarget.accounts)
    }

    func navigateToCategories() {
        print("FinancesCoordinator: Навигация к Категориям (добавление в path)")
        path.append(FinanceNavigationTarget.categories)
    }
    
    @ViewBuilder
    func view(for target: FinanceNavigationTarget) -> some View {
        switch target {
        case .accounts:
            // Убедитесь, что AccountRepositoryImpl, AccountsViewModel, AccountsView существуют и в таргете
            let accountRepo = AccountRepositoryImpl(modelContext: modelContext)
            // ИСПРАВЛЕНО: Добавляем modelContext в вызов init
            let viewModel = AccountsViewModel(accountRepository: accountRepo, modelContext: self.modelContext, coordinator: self)
            AccountsView(viewModel: viewModel)
        case .categories:
            // Убедитесь, что TransactionCategoryRepositoryImpl, CategoriesViewModel, CategoriesView существуют и в таргете
            let categoryRepo = TransactionCategoryRepositoryImpl(modelContext: modelContext)
            let viewModel = CategoriesViewModel(categoryRepository: categoryRepo, coordinator: self)
            CategoriesView(viewModel: viewModel)
        }
    }
    
    func goBack() {
        if !path.isEmpty {
            path.removeLast()
        }
    }
    
    func dismissFinancesModule() {
        parentCoordinator?.showDashboard()
    }
}
