import UIKit

@MainActor
final class CatalogViewController: BDUIScreenHostingViewController, CatalogView {

    var viewModel: CatalogViewModelProtocol?
    private var loadMoreTriggered = false

    init() {
        super.init(
            loader: BundleBDUIScreenLoader(),
            registry: BDUIMapperRegistry.makeDefault(),
            actionBinder: BDUIActionBinder(),
            actionHandler: BDUIActionHandler()
        )
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Каталог"
        setupSearch()
        setupCallbacks()

        viewModel?.view = self
        viewModel?.didLoad()
    }

    private func setupCallbacks() {
        onAction = { [weak self] action in
            guard let self else { return }
            guard case let .event(name, payload) = action else { return }
            switch name {
            case "retry":
                viewModel?.didTapRetry()
            case "paginate":
                viewModel?.didLoadMore()
            case "select":
                if let albumID = payload?["itemId"] {
                    viewModel?.didSelectAlbum(id: albumID)
                }
            default:
                break
            }
        }
    }

    private func setupSearch() {
        let search = UISearchController(searchResultsController: nil)
        search.obscuresBackgroundDuringPresentation = false
        search.searchResultsUpdater = self
        search.searchBar.placeholder = "Поиск по альбомам"
        search.searchBar.autocapitalizationType = .none
        search.searchBar.returnKeyType = .done
        search.searchBar.tintColor = DS.Colors.primary

        navigationItem.searchController = search
        navigationItem.hidesSearchBarWhenScrolling = false

        definesPresentationContext = true

        navigationItem.searchController?.hidesNavigationBarDuringPresentation = false
    }

    func render(_ state: CatalogViewState) {
        switch state.loadingState {
        case .initial:
            render(templateName: "catalog_loading", context: [:])
        case .loading:
            render(templateName: "catalog_loading", context: [:])
        case .content(let items):
            loadMoreTriggered = false
            render(
                templateName: "catalog_content",
                context: [
                    "itemsCount": "\(items.count)",
                    "albumNodes": makeAlbumNodesJSON(items)
                ]
            )
            bindScrollPaginationIfNeeded()
        case .empty:
            render(
                templateName: "catalog_empty",
                context: ["emptyMessage": "Список пуст или ничего не найдено по запросу."]
            )
        case .error(let message):
            render(
                templateName: "catalog_error",
                context: ["errorMessage": Self.escapeForJSON(message)]
            )
        }
    }

    private func bindScrollPaginationIfNeeded() {
        guard let scrollView = renderedView(withID: "catalog_root") as? UIScrollView else { return }
        scrollView.delegate = self
    }

    private func makeAlbumNodesJSON(_ items: [AlbumCellViewModel]) -> String {
        let nodes = items.map(makeAlbumNodeDictionary(_:))
        guard
            let data = try? JSONSerialization.data(withJSONObject: nodes),
            let json = String(data: data, encoding: .utf8)
        else {
            return "[]"
        }
        return json
    }

    private func makeAlbumNodeDictionary(_ item: AlbumCellViewModel) -> [String: Any] {
        let imageURL: Any = item.artworkUrl ?? NSNull()
        return [
            "id": "catalog_album_\(item.id)",
            "type": "container",
            "content": [
                "backgroundColor": "elevated",
                "padding": "m",
                "cornerRadius": "m"
            ],
            "subviews": [
                [
                    "id": "catalog_album_row_\(item.id)",
                    "type": "hStack",
                    "content": [
                        "spacing": "m"
                    ],
                    "subviews": [
                        [
                            "id": "catalog_album_image_\(item.id)",
                            "type": "image",
                            "content": [
                                "url": imageURL,
                                "width": Double(DS.Layout.AlbumCell.artworkSize),
                                "height": Double(DS.Layout.AlbumCell.artworkSize),
                                "cornerRadius": "s",
                                "contentMode": "scaleAspectFill"
                            ]
                        ],
                        [
                            "id": "catalog_album_text_\(item.id)",
                            "type": "vStack",
                            "content": [
                                "spacing": "xs"
                            ],
                            "subviews": [
                                [
                                    "id": "catalog_album_title_\(item.id)",
                                    "type": "label",
                                    "content": [
                                        "text": item.title,
                                        "textStyle": "listTitle",
                                        "color": "textPrimary",
                                        "alignment": "left",
                                        "numberOfLines": 0
                                    ]
                                ],
                                [
                                    "id": "catalog_album_subtitle_\(item.id)",
                                    "type": "label",
                                    "content": [
                                        "text": "\(item.artistName) • \(item.releaseYear)",
                                        "textStyle": "listSubtitle",
                                        "color": "textSecondary",
                                        "alignment": "left",
                                        "numberOfLines": 0
                                    ]
                                ]
                            ]
                        ]
                    ]
                ]
            ],
            "action": [
                "type": "event",
                "name": "select",
                "payload": [
                    "itemId": item.id
                ]
            ]
        ]
    }

    private static func escapeForJSON(_ value: String) -> String {
        value
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
            .replacingOccurrences(of: "\n", with: "\\n")
    }
}

extension CatalogViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        viewModel?.didSearch(query: searchController.searchBar.text ?? "")
    }
}

extension CatalogViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let threshold: CGFloat = 120
        let offsetY = scrollView.contentOffset.y
        let maxOffsetY = scrollView.contentSize.height - scrollView.bounds.height
        guard maxOffsetY > 0 else { return }

        if offsetY > maxOffsetY - threshold {
            guard !loadMoreTriggered else { return }
            loadMoreTriggered = true
            viewModel?.didLoadMore()
        } else if offsetY < maxOffsetY - threshold * 2 {
            loadMoreTriggered = false
        }
    }
}
