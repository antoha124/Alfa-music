protocol CatalogServiceProtocol {
    func fetchAlbums() async throws -> [Album]
    func fetchAlbums(page: Int, pageSize: Int) async throws -> [Album]
    func search(query: String) async throws -> [Album]
    func clearCache()
}


protocol CatalogRepositoryProtocol {
    func fetchAlbums() async throws -> [Album]
    func fetchAlbums(page: Int, pageSize: Int) async throws -> [Album]
    func clearCache()
}

protocol CatalogView: AnyObject {
    func render(_ state: CatalogViewState)
}

protocol CatalogCoordinatorProtocol: AnyObject {
    func showTracks(albumId: String)
}

protocol CatalogViewModelProtocol: AnyObject {
    var view: CatalogView? { get set }
    func didLoad()
    func didSelectAlbum(id: String)
    func didTapRetry()
    func didSearch(query: String)
    func didLoadMore()
    func clearCache()
}
