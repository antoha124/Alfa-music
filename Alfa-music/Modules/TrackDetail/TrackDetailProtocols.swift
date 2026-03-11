protocol TrackDetailView: AnyObject {
    func render(_ state: TrackDetailViewState)
}

protocol TrackDetailViewModelProtocol: AnyObject {
    var view: TrackDetailView? { get set }
    func didLoad()
    func didTapPlay()
    func didTapLike()
    func didTapBack()
    func didTapNextTrack()
    func didTapPreviousTrack()
}

protocol TrackDetailCoordinatorProtocol: AnyObject {
    func dismiss()
}

protocol TrackServiceProtocol {
    func fetchTracks(albumId: String) -> [Track]
    func fetchTrack(id: String) -> Track?
}

protocol TrackRepositoryProtocol {
    func tracks(albumId: String) -> [Track]
    func track(id: String) -> Track?
}
