import Foundation

enum GoalHorizon: String, Codable, CaseIterable {
    case month
    case year
    case threeYears = "3y"
    case fiveYears = "5y"

    var title: String {
        switch self {
        case .month: return "1 месяц"
        case .year: return "1 год"
        case .threeYears: return "3 года"
        case .fiveYears: return "5 лет"
        }
    }
}
