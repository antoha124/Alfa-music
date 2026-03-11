struct TrackDetailContent: Equatable {
    let track: Track
    let albumTitle: String
    let trackIndex: Int
    let totalTracks: Int
}


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
