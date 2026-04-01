enum TrackListLoadingState: Equatable {
    case initial
    case loading
    case content([TrackCellViewModel])
    case empty
    case error(String)
}

struct TrackListViewState: Equatable {
    var state: TrackListLoadingState = .initial
}
