import Foundation

struct AlbumDTO: Codable {
    let id: String
    let collectionName: String
    let artistName: String
    let releaseYear: Int
    let artworkUrl100: String?

    func toDomain() -> Album {
        return Album(
            id: id,
            title: collectionName,
            artistName: artistName,
            releaseYear: releaseYear,
            artworkUrl: artworkUrl100
        )
    }
}
