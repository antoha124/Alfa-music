import Foundation

enum AuthError: Error, LocalizedError {
    case invalidCredentials
    case emptyCredentials

    var errorDescription: String? {
        switch self {
        case .invalidCredentials: return "Неверный email или пароль"
        case .emptyCredentials: return "Введите email и пароль"
        }
    }
}
