final class TrackDetailViewModel: TrackDetailViewModelProtocol {
    weak var view: TrackDetailView?

    private let trackId: String
    private let albumId: String
    private let service: TrackServiceProtocol

    private var viewState: TrackDetailViewState = TrackDetailViewState(
        status: .initial,
        isLiked: false,
        isPlaying: false
    ) {
        didSet { view?.render(viewState) }
    }

    init(trackId: String, albumId: String, service: TrackServiceProtocol) {
        self.trackId = trackId
        self.albumId = albumId
        self.service = service
    }

    func didLoad() {
        viewState = TrackDetailViewState(status: .loading, isLiked: false, isPlaying: false)

        guard let track = service.fetchTrack(id: trackId) else {
            viewState = TrackDetailViewState(
                status: .error("Трек не найден"),
                isLiked: false,
                isPlaying: false
            )
            return
        }

        let tracks = service.fetchTracks(albumId: albumId)
        let index  = tracks.firstIndex(where: { $0.id == trackId }) ?? 0
        let content = TrackDetailContent(
            track: track,
            albumTitle: albumId,
            trackIndex: index + 1,
            totalTracks: tracks.count
        )
        viewState = TrackDetailViewState(status: .content(content), isLiked: false, isPlaying: false)
    }

    func didTapPlay() {
        viewState = TrackDetailViewState(
            status: viewState.status,
            isLiked: viewState.isLiked,
            isPlaying: !viewState.isPlaying
        )
    }

    func didTapLike() {
        viewState = TrackDetailViewState(
            status: viewState.status,
            isLiked: !viewState.isLiked,
            isPlaying: viewState.isPlaying
        )
    }

    func didTapBack() {}

    func didTapNextTrack() {
        guard case .content(let c) = viewState.status,
              c.trackIndex < c.totalTracks else { return }
        let tracks = service.fetchTracks(albumId: albumId)
        let nextTrack = tracks[c.trackIndex] // trackIndex — 1-based, поэтому [trackIndex] — следующий
        let content = TrackDetailContent(
            track: nextTrack,
            albumTitle: c.albumTitle,
            trackIndex: c.trackIndex + 1,
            totalTracks: c.totalTracks
        )
        viewState = TrackDetailViewState(status: .content(content), isLiked: false, isPlaying: viewState.isPlaying)
    }

    func didTapPreviousTrack() {
        guard case .content(let c) = viewState.status,
              c.trackIndex > 1 else { return }
        let tracks = service.fetchTracks(albumId: albumId)
        let prevTrack = tracks[c.trackIndex - 2] // trackIndex — 1-based, поэтому [trackIndex-2] — предыдущий
        let content = TrackDetailContent(
            track: prevTrack,
            albumTitle: c.albumTitle,
            trackIndex: c.trackIndex - 1,
            totalTracks: c.totalTracks
        )
        viewState = TrackDetailViewState(status: .content(content), isLiked: false, isPlaying: viewState.isPlaying)
    }
}
