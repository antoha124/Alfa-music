import Foundation

protocol NetworkClient {
    func get<T: Decodable>(_ url: URL) async throws -> T
}

class URLSessionNetworkClient: NetworkClient {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func get<T: Decodable>(_ url: URL) async throws -> T {
        let request = URLRequest(url: url)
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.badServerResponse(statusCode: 0)
            }
            
            guard 200..<300 ~= httpResponse.statusCode else {
                throw NetworkError.badServerResponse(statusCode: httpResponse.statusCode)
            }
            
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch let networkError as NetworkError {
            throw networkError
        } catch let decodingError as DecodingError {
            throw NetworkError.decodingError(decodingError.localizedDescription)
        } catch let urlError as URLError {
            throw NetworkError.networkError(urlError.localizedDescription)
        } catch {
            throw NetworkError.unknown(error)
        }
    }
}
