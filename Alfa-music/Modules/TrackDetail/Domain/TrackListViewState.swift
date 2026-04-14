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

extension TrackListViewState {
    var contentItems: [TrackCellViewModel]? {
        guard case .content(let items) = state else { return nil }
        return items
    }

    var errorMessage: String? {
        guard case .error(let message) = state else { return nil }
        return message
    }
}
