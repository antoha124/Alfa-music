class CatalogService: CatalogServiceProtocol {
    private let repo: CatalogRepositoryProtocol

    init(repo: CatalogRepositoryProtocol) { self.repo = repo }

    func fetchAlbums() async throws -> [Album] {
        return try await repo.fetchAlbums()
    }

    func fetchAlbums(page: Int, pageSize: Int) async throws -> [Album] {
        return try await repo.fetchAlbums(page: page, pageSize: pageSize)
    }

    func search(query: String) async throws -> [Album] {
        return []
    }
    
    func clearCache() {
        repo.clearCache()
    }
}
