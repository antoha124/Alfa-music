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
    private var allItems: [AlbumCellViewModel] = []
    private var currentQuery: String = ""

    private var currentPage: Int = 1
    private let pageSize: Int = 10
    private let loadMoreThreshold = 3
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
                    allItems = []
                    viewState.loadingState = .empty
                } else {
                    allItems = makeCellViewModels(from: albums)
                    applySearchState()
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

                if !moreAlbums.isEmpty {
                    let newViewModels = makeCellViewModels(from: moreAlbums)
                    allItems.append(contentsOf: newViewModels)
                    applySearchState()
                }

                isLoadingMore = false
            } catch {
                currentPage -= 1
                isLoadingMore = false
            }
        }
    }

    func didDisplayItem(at index: Int, totalCount: Int) {
        guard totalCount > 0 else { return }
        if index >= totalCount - loadMoreThreshold {
            didLoadMore()
        }
    }

    func didSelectAlbum(id: String) {
        coordinator?.showTracks(albumId: id)
    }

    func didTapRetry() {
        didLoad()
    }

    func didSearch(query: String) {
        currentQuery = query
        applySearchState()
    }

    func clearCache() {
        useCase.clearCache()
        allItems = []
        currentQuery = ""
        didLoad()
    }

    private func makeCellViewModels(from albums: [Album]) -> [AlbumCellViewModel] {
        albums.map {
            AlbumCellViewModel(
                id: $0.id,
                title: $0.title,
                artistName: $0.artistName,
                releaseYear: $0.releaseYear,
                artworkUrl: $0.artworkUrl
            )
        }
    }

    private func applySearchState() {
        let query = currentQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        let filteredItems: [AlbumCellViewModel]

        if query.isEmpty {
            filteredItems = allItems
        } else {
            filteredItems = allItems.filter {
                $0.title.localizedCaseInsensitiveContains(query) ||
                $0.artistName.localizedCaseInsensitiveContains(query)
            }
        }

        viewState.loadingState = filteredItems.isEmpty ? .empty : .content(filteredItems)
    }
}
