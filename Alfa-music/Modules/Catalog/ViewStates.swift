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
