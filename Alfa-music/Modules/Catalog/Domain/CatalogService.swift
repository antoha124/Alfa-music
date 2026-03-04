class CatalogService: CatalogServiceProtocol {
    private let repo: CatalogRepositoryProtocol

    init(repo: CatalogRepositoryProtocol) { self.repo = repo }

    func fetchAlbums() -> [Album] { return repo.getAlbums() }
    func search(query: String) -> [Album] { return [] }
}
