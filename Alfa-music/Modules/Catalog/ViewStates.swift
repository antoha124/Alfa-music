enum CatalogLoadingState: Equatable {
    case initial
    case loading
    case content([AlbumCellViewModel])
    case empty
    case error(String)
}

struct CatalogViewState: Equatable {
    var loadingState: CatalogLoadingState = .initial
}

extension CatalogViewState {
    var contentItems: [AlbumCellViewModel]? {
        guard case let .content(items) = loadingState else { return nil }
        return items
    }

    var errorMessage: String? {
        guard case let .error(message) = loadingState else { return nil }
        return message
    }
}
