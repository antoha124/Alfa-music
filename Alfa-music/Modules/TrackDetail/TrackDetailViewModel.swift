import Foundation

final class TrackDetailViewModel: TrackDetailViewModelProtocol {
    weak var view: TrackDetailView?
    weak var coordinator: TrackDetailCoordinatorProtocol?

    private let albumId: String
    private let service: TrackServiceProtocol

    private var viewState = TrackListViewState() {
        didSet { view?.render(viewState) }
    }

    init(albumId: String, service: TrackServiceProtocol, coordinator: TrackDetailCoordinatorProtocol?) {
        self.albumId = albumId
        self.service = service
        self.coordinator = coordinator
    }

    func didLoad() {
        viewState.state = .loading

        let tracks = service.fetchTracks(albumId: albumId)
        if tracks.isEmpty {
            viewState.state = .empty
            return
        }

        viewState.state = .content(makeCellViewModels(from: tracks))
    }

    func didSelectTrack(id: String) {
        _ = id
    }

    func didTapBack() {
        coordinator?.finish()
    }

    func didTapRetry() {
        didLoad()
    }

    private func makeCellViewModels(from tracks: [Track]) -> [TrackCellViewModel] {
        tracks.map { track in
            let minutes = track.durationSeconds / 60
            let seconds = track.durationSeconds % 60
            return TrackCellViewModel(
                id: track.id,
                title: track.title,
                subtitle: track.artistName,
                rightText: String(format: "%d:%02d", minutes, seconds)
            )
        }
    }
}
