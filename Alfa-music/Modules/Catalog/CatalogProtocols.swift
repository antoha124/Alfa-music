protocol CatalogRepositoryProtocol {
    func getAlbums() -> [Album]
}


protocol CatalogServiceProtocol {
    func fetchAlbums() -> [Album]
    func search(query: String) -> [Album]
}



protocol CatalogView: AnyObject {
    func render(_ state: CatalogViewState)
}

protocol CatalogViewModelProtocol: AnyObject {
    var view: CatalogView? { get set }
    func didLoad()
    func didSelectAlbum(id: String)
    func didTapRetry()
    func didSearch(query: String)
}
