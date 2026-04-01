protocol TrackDetailView: AnyObject {
    func render(_ state: TrackListViewState)
}

protocol TrackDetailViewModelProtocol: AnyObject {
    var view: TrackDetailView? { get set }
    func didLoad()
    func didSelectTrack(id: String)
}

// Детали трека сделаю позже
protocol TrackDetailCoordinatorProtocol: AnyObject {}

protocol TrackServiceProtocol {
    func fetchTracks(albumId: String) -> [Track]
    func fetchTrack(id: String) -> Track?
}

protocol TrackRepositoryProtocol {
    func tracks(albumId: String) -> [Track]
    func track(id: String) -> Track?
}
