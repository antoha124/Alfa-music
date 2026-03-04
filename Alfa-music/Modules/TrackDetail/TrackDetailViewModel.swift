final class TrackDetailViewModel: TrackDetailViewModelProtocol {
    weak var view: TrackDetailView?

    private let trackId: String
    private let albumId: String
    private let service: TrackService

    init(trackId: String, albumId: String, service: TrackService) {
        self.trackId = trackId
        self.albumId = albumId
        self.service = service
    }

    func didLoad() {}
    func didTapPlay() {}
    func didTapLike() {}
    func didTapBack() {}
    func didTapNextTrack() {}
    func didTapPreviousTrack() {}
}
