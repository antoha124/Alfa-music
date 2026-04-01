import Foundation

class CatalogViewModel: CatalogViewModelProtocol {
    weak var view: CatalogView?
    weak var coordinator: CatalogCoordinatorProtocol?

    private let useCase: CatalogServiceProtocol
    private var viewState = CatalogViewState() {
        didSet {
            view?.render(viewState)
        }
    }
    private var loadingTask: Task<Void, Never>?

    private var currentPage: Int = 1
    private let pageSize: Int = 10
    private var isLoadingMore = false

    init(useCase: CatalogServiceProtocol, coordinator: CatalogCoordinatorProtocol?) {
        self.useCase = useCase
        self.coordinator = coordinator
    }

    func didLoad() {
        currentPage = 1
        loadingTask?.cancel()
        loadingTask = Task {
            viewState.loadingState = .loading

            do {
                let albums = try await useCase.fetchAlbums(page: currentPage, pageSize: pageSize)

                if albums.isEmpty {
                    viewState.loadingState = .empty
                } else {
                    let cellViewModels = albums.map { AlbumCellViewModel(from: $0) }
                    viewState.loadingState = .content(cellViewModels)
                }
            } catch let error as NetworkError {
                viewState.loadingState = .error(error.errorDescription ?? "Неизвестная ошибка")
            } catch {
                viewState.loadingState = .error("Ошибка загрузки данных")
            }
        }
    }

    func didLoadMore() {
        guard !isLoadingMore else { return }

        isLoadingMore = true
        currentPage += 1

        loadingTask?.cancel()
        loadingTask = Task {
            do {
                let moreAlbums = try await useCase.fetchAlbums(page: currentPage, pageSize: pageSize)

                if case .content(var existing) = viewState.loadingState {
                    let newViewModels = moreAlbums.map { AlbumCellViewModel(from: $0) }
                    existing.append(contentsOf: newViewModels)
                    viewState.loadingState = .content(existing)
                }

                isLoadingMore = false
            } catch {
                currentPage -= 1
                isLoadingMore = false
            }
        }
    }

    func didSelectAlbum(id: String) {
        coordinator?.showTracks(albumId: id)
    }

    func didTapRetry() {
        didLoad()
    }

    func didSearch(query: String) {
        print("Search query: \(query)")
    }

    func clearCache() {
        useCase.clearCache()
        didLoad()
    }
}
