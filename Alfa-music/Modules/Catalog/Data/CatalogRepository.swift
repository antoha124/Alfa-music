import Foundation

class CatalogRepository: CatalogRepositoryProtocol {
    private let networkClient: NetworkClient
    private let isu = "408740"
    private let echoPath = "albums"
    private let useLocalFallback = true
    private var allAlbums: [Album] = []
    
    private let cache = CacheManager<String, [Album]>(ttl: 300)
    private let cacheKey = "albums_list"

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    func fetchAlbums() async throws -> [Album] {
        if let cachedAlbums = cache.get(forKey: cacheKey) {
            allAlbums = cachedAlbums
            return cachedAlbums
        }
        
        guard let url = URL(string: "https://alfaitmo.ru/server/echo/\(isu)/\(echoPath)") else {
            throw NetworkError.invalidURL
        }

        do {
            let albums: [AlbumDTO] = try await networkClient.get(url)
            allAlbums = albums.map { $0.toDomain() }
            cache.set(allAlbums, forKey: cacheKey)
            return allAlbums
        } catch {
            if useLocalFallback {
                allAlbums = try loadLocalAlbums()
                cache.set(allAlbums, forKey: cacheKey)
                return allAlbums
            }
            throw error
        }
    }

    func fetchAlbums(page: Int, pageSize: Int) async throws -> [Album] {
        if allAlbums.isEmpty {
            _ = try await fetchAlbums()
        }

        let startIndex = (page - 1) * pageSize
        let endIndex = min(startIndex + pageSize, allAlbums.count)

        guard startIndex < allAlbums.count else {
            return []
        }

        return Array(allAlbums[startIndex..<endIndex])
    }
    
    func clearCache() {
        cache.clear()
        allAlbums.removeAll()
    }

    private func loadLocalAlbums() throws -> [Album] {
        guard let path = Bundle.main.url(forResource: "albums", withExtension: "json") else {
            throw NetworkError.invalidURL
        }
        
        let data = try Data(contentsOf: path)
        let albums = try JSONDecoder().decode([AlbumDTO].self, from: data)
        return albums.map { $0.toDomain() }
    }
}
