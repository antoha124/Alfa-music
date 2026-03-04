class TrackRepository: TrackRepositoryProtocol {
    private var cache: [String: [Track]] = [:]
    
    func tracks(albumId: String) -> [Track] {
        return cache[albumId] ?? []
    }
    
    func track(id: String) -> Track? {
        return cache.values.flatMap { $0 }.first { $0.id == id }
    }
}
