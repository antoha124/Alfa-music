class CatalogViewModel: CatalogViewModelProtocol {
    weak var view: CatalogView?

    private let useCase: CatalogServiceProtocol

    init(useCase: CatalogServiceProtocol) {
        self.useCase = useCase
    }

    func didLoad() {}
    func didSelectAlbum(id: String) {}
    func didTapRetry() {}
    func didSearch(query: String) {}
}
