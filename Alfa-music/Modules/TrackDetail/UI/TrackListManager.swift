import UIKit

protocol TrackListManagerDelegate: AnyObject {
    func didSelectTrack(id: String)
}

final class TrackListManager: NSObject {

    weak var delegate: TrackListManagerDelegate?
    private var items: [TrackCellViewModel] = []

    private let tableView: UITableView

    init(tableView: UITableView) {
        self.tableView = tableView
        super.init()

        tableView.register(TrackListCell.self, forCellReuseIdentifier: TrackListCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
    }

    func setItems(_ items: [TrackCellViewModel]) {
        self.items = items
        tableView.reloadData()
    }
}

extension TrackListManager: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TrackListCell.reuseIdentifier, for: indexPath) as? TrackListCell else {
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
