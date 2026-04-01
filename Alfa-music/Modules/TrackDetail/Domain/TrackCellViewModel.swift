import Foundation

struct TrackCellViewModel: Equatable {
    let id: String
    let title: String
    let subtitle: String
    let rightText: String

    init(track: Track) {
        id = track.id
        title = track.title
        subtitle = track.artistName

        let minutes = track.durationSeconds / 60
        let seconds = track.durationSeconds % 60
        rightText = String(format: "%d:%02d", minutes, seconds)
    }
}
