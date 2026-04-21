import UIKit

@MainActor
final class CatalogViewController: BDUIScreenHostingViewController, CatalogView {

    var viewModel: CatalogViewModelProtocol?
    private let screenBuilder = CatalogBDUIScreenBuilder()
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
        onCallback = { [weak self] callbackID in
            guard let self else { return }
            if callbackID == "catalog_retry_tap" {
                viewModel?.didTapRetry()
                return
            }
            if callbackID == "catalog_load_more_tap" {
                viewModel?.didLoadMore()
                return
            }
            if callbackID.hasPrefix("catalog_open_") {
                let albumID = String(callbackID.dropFirst("catalog_open_".count))
                viewModel?.didSelectAlbum(id: albumID)
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
            render(screen: screenBuilder.makeScreen(items: items))
            bindScrollPaginationIfNeeded()
        case .empty:
            render(
                templateName: "catalog_empty",
                context: ["emptyMessage": "Список пуст или ничего не найдено по запросу."]
            )
        case .error(let message):
            render(templateName: "catalog_error", context: ["errorMessage": message])
        }
    }

    private func bindScrollPaginationIfNeeded() {
        guard let scrollView = renderedView(withID: "catalog_root") as? UIScrollView else { return }
        scrollView.delegate = self
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
