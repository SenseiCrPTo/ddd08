// Features/Finances/Utils/EditAccountSheetContext.swift (или Shared/Utils/)
import Foundation
import SwiftData // Для Account

// Убедитесь, что AccountUsageType.swift существует и добавлен в таргет
// enum AccountUsageType: String, Codable, CaseIterable, Identifiable { ... }

struct EditAccountSheetContext: Identifiable {
    let id = UUID()
    var accountToEdit: Account?
    var initialUsageType: AccountUsageType // <--- ИЗМЕНЕНО: теперь используем AccountUsageType

    // Инициализатор для нового счета
    init(accountToEdit: Account? = nil, initialUsageType: AccountUsageType = .expenseSource) { // Значение по умолчанию
        self.accountToEdit = accountToEdit
        // Если редактируем, initialUsageType берется из счета, иначе из параметра
        self.initialUsageType = accountToEdit?.accountUsageType ?? initialUsageType
    }
}
