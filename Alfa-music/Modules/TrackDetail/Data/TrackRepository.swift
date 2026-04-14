class TrackRepository: TrackRepositoryProtocol {
    private var cache: [String: [Track]] = [
        "1": [
            Track(id: "1-1", albumId: "1", title: "Intro", artistName: "OG Buda", durationSeconds: 112),
            Track(id: "1-2", albumId: "1", title: "Купюры", artistName: "OG Buda", durationSeconds: 168),
            Track(id: "1-3", albumId: "1", title: "Пуля", artistName: "OG Buda", durationSeconds: 201)
        ],
        "2": [
            Track(id: "2-1", albumId: "2", title: "Звезда", artistName: "MAYOT", durationSeconds: 154),
            Track(id: "2-2", albumId: "2", title: "Вне игры", artistName: "MAYOT", durationSeconds: 189),
            Track(id: "2-3", albumId: "2", title: "Снег", artistName: "MAYOT", durationSeconds: 173)
        ],
        "3": [
            Track(id: "3-1", albumId: "3", title: "Голоса", artistName: "NILETTO", durationSeconds: 196),
            Track(id: "3-2", albumId: "3", title: "Луна", artistName: "NILETTO", durationSeconds: 207)
        ]
    ]

    func tracks(albumId: String) -> [Track] {
        return cache[albumId] ?? []
    }

    func track(id: String) -> Track? {
        return cache.values.flatMap { $0 }.first { $0.id == id }
    }
}
