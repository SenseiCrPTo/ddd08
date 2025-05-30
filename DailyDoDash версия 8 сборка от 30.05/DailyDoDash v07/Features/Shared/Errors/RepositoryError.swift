// Core/Repositories/RepositoryError.swift (или Shared/Errors/RepositoryError.swift)
import Foundation

enum RepositoryError: Error, Equatable {
    case fetchFailed(String?)
    case saveFailed(String?)
    case deleteFailed(String?)
    case alreadyExists
    case entityInUse(message: String)
    case unknown(String?)

    // Для Equatable: Swift может автоматически синтезировать ==,
    // если все ассоциированные значения являются Equatable. String? является Equatable.
    // Если бы у нас были ассоциированные значения типа `Error`, то Equatable было бы сложнее.
}
