enum CatalogLoadingState: Equatable {
    case initial
    case loading
    case content
    case error(String)
}

struct CatalogViewState: Equatable {
    var loadingState: CatalogLoadingState = .initial
    var albums: [Album] = []
    var searchQuery: String = ""
}
