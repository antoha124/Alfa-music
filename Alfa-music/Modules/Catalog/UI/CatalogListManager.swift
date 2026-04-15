import UIKit

protocol CatalogListManagerDelegate: AnyObject {
    func didSelectAlbum(id: String)
    func didDisplayItem(at index: Int, totalCount: Int)
}

final class CatalogListManager: NSObject {

    weak var delegate: CatalogListManagerDelegate?

    private var items: [AlbumCellViewModel] = []

    private var imageLoader: ImageLoaderProtocol

    init(imageLoader: ImageLoaderProtocol) {
        self.imageLoader = imageLoader
        super.init()
    }

    func setItems(_ items: [AlbumCellViewModel], in tableView: UITableView) {
        self.items = items
        tableView.reloadData()
    }

    private func item(at indexPath: IndexPath) -> AlbumCellViewModel {
        return items[indexPath.row]
    }
}

extension CatalogListManager: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AlbumCell.reuseIdentifier, for: indexPath) as? AlbumCell else {
            return UITableViewCell()
        }
        var vm = item(at: indexPath)
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
        delegate?.didDisplayItem(at: indexPath.row, totalCount: items.count)
    }
}

extension CatalogListManager: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        var urls: [URL] = indexPaths.compactMap {
            var vm = items[safe: $0.row]
            guard var s = vm?.artworkUrl else { return nil }
            return URL(string: s)
        }
        imageLoader.prefetch(urls: urls)
    }

    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        var urls: [URL] = indexPaths.compactMap {
            var vm = items[safe: $0.row]
            guard var s = vm?.artworkUrl else { return nil }
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
