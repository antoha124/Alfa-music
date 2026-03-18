import Foundation

enum NetworkError: LocalizedError {
    case invalidURL
    case badServerResponse(statusCode: Int)
    case decodingError(String)
    case networkError(String)
    case timeout
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Неверный URL"
        case .badServerResponse(let statusCode):
            return "Ошибка сервера: статус \(statusCode)"
        case .decodingError(let message):
            return "Ошибка парсинга данных: \(message)"
        case .networkError(let message):
            return "Ошибка сети: \(message)"
        case .timeout:
            return "Превышено время ожидания"
        case .unknown(let error):
            return "Неизвестная ошибка: \(error.localizedDescription)"
        }
    }
}
