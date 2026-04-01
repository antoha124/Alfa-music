import UIKit

protocol CatalogListManagerDelegate: AnyObject {
    func didSelectAlbum(id: String)
    func didReachListEnd()
}

final class CatalogListManager: NSObject {

    weak var delegate: CatalogListManagerDelegate?

    private var items: [AlbumCellViewModel] = []
    private var filteredItems: [AlbumCellViewModel] = []

    private var isFiltering: Bool = false

    private let tableView: UITableView
    private let imageLoader: ImageLoaderProtocol

    init(tableView: UITableView, imageLoader: ImageLoaderProtocol) {
        self.tableView = tableView
        self.imageLoader = imageLoader
        super.init()

        tableView.register(AlbumCell.self, forCellReuseIdentifier: AlbumCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.prefetchDataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 76
    }

    func setItems(_ items: [AlbumCellViewModel]) {
        self.items = items
        if !isFiltering {
            filteredItems = items
        }
        applySnapshotReload()
    }

    func applyFilter(query: String) {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if q.isEmpty {
            isFiltering = false
            filteredItems = items
        } else {
            isFiltering = true
            filteredItems = items.filter {
                $0.title.localizedCaseInsensitiveContains(q) ||
                $0.artistName.localizedCaseInsensitiveContains(q)
            }
        }
        applySnapshotReload()
    }

    private func applySnapshotReload() {
        tableView.reloadData()
    }

    private func item(at indexPath: IndexPath) -> AlbumCellViewModel {
        return filteredItems[indexPath.row]
    }
}

extension CatalogListManager: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AlbumCell.reuseIdentifier, for: indexPath) as? AlbumCell else {
            return UITableViewCell()
        }
        let vm = item(at: indexPath)
        cell.configure(with: vm, imageLoader: imageLoader)
        return cell
    }
}

extension CatalogListManager: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.didSelectAlbum(id: item(at: indexPath).id)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row >= filteredItems.count - 3 {
            delegate?.didReachListEnd()
        }
    }
}

extension CatalogListManager: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        let urls: [URL] = indexPaths.compactMap {
            let vm = filteredItems[safe: $0.row]
            guard let s = vm?.artworkUrl else { return nil }
            return URL(string: s)
        }
        imageLoader.prefetch(urls: urls)
    }

    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        let urls: [URL] = indexPaths.compactMap {
            let vm = filteredItems[safe: $0.row]
            guard let s = vm?.artworkUrl else { return nil }
            return URL(string: s)
        }
        imageLoader.cancelPrefetch(urls: urls)
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        guard indices.contains(index) else { return nil }
        return self[index]
    }
}
