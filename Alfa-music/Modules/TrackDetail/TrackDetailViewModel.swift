final class TrackDetailViewModel: TrackDetailViewModelProtocol {
    weak var view: TrackDetailView?

    private let albumId: String
    private let service: TrackServiceProtocol

    private var viewState = TrackListViewState() {
        didSet { view?.render(viewState) }
    }

    init(albumId: String, service: TrackServiceProtocol) {
        self.albumId = albumId
        self.service = service
    }

    func didLoad() {
        viewState.state = .loading

        let tracks = service.fetchTracks(albumId: albumId)
        if tracks.isEmpty {
            viewState.state = .empty
            return
        }

        let vms = tracks.map(TrackCellViewModel.init)
        viewState.state = .content(vms)
    }

    func didSelectTrack(id: String) {
        // Детали трека сделаем позже
        print("Selected track: \(id)")
    }
}
