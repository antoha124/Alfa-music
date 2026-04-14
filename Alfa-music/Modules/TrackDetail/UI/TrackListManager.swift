import UIKit

protocol TrackListManagerDelegate: AnyObject {
    func didSelectTrack(id: String)
}

final class TrackListManager: NSObject {

    weak var delegate: TrackListManagerDelegate?

    private var items: [TrackCellViewModel] = []

    func setItems(_ items: [TrackCellViewModel], in tableView: UITableView) {
        self.items = items
        tableView.reloadData()
    }
}

extension TrackListManager: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: TrackListCell.reuseIdentifier,
            for: indexPath
        ) as? TrackListCell else {
            return UITableViewCell()
        }
        cell.configure(with: items[indexPath.row])
        return cell
    }
}

extension TrackListManager: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.didSelectTrack(id: items[indexPath.row].id)
    }
}
