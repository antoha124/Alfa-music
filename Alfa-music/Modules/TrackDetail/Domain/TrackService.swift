class TrackService: TrackServiceProtocol {
    private let repo: TrackRepositoryProtocol

    init(repo: TrackRepositoryProtocol) { self.repo = repo }

    func fetchTracks(albumId: String) -> [Track]{
        return repo.tracks(albumId: albumId)
    }
    func fetchTrack(id: String) -> Track?{
        return repo.track(id: id)
    }
}
