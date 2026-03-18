struct AlbumCellViewModel: Equatable {
    let id: String
    let title: String
    let artistName: String
    let releaseYear: Int
    let artworkUrl: String?

    init(from album: Album) {
        self.id = album.id
        self.title = album.title
        self.artistName = album.artistName
        self.releaseYear = album.releaseYear
        self.artworkUrl = album.artworkUrl
    }
}
