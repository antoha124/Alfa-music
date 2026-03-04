enum Status: Equatable {
    case initial
    case loading
    case content(TrackDetailContent)
    case error(String)
}


struct TrackDetailViewState: Equatable {
    var status: Status
    var isLiked: Bool
    var isPlaying: Bool
}
