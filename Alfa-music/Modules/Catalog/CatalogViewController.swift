import UIKit

final class CatalogViewController: UIViewController, CatalogView {

    var viewModel: CatalogViewModelProtocol?
    var session: UserSession?

    private var tableView = UITableView(frame: .zero, style: .plain)
    private var stateView = DSStateContainerView()

    private lazy var refreshControl: UIRefreshControl = {
        var c = UIRefreshControl()
        c.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        c.tintColor = DS.Colors.primary
        return c
    }()

    private var imageLoader: ImageLoaderProtocol = ImageLoader()
    private var listManager: CatalogListManager?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = DS.Colors.background
        title = "Каталог"

        setupUI()
        setupList()
        setupSearch()

        stateView.onRetry = { [weak self] in
            self?.viewModel?.didTapRetry()
        }

        viewModel?.view = self
        viewModel?.didLoad()
    }

    private func setupUI() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.refreshControl = refreshControl
        tableView.backgroundColor = DS.Colors.background
        view.addSubview(tableView)

        stateView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stateView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            stateView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stateView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        stateView.setState(.hidden)
    }

    private func setupList() {
        tableView.register(AlbumCell.self, forCellReuseIdentifier: AlbumCell.reuseIdentifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = DS.Layout.CatalogList.estimatedRowHeight
        tableView.separatorInset = UIEdgeInsets(
            top: 0,
            left: DS.Layout.CatalogList.separatorLeadingInset,
            bottom: 0,
            right: 0
        )

        var manager = CatalogListManager(imageLoader: imageLoader)
        manager.delegate = self
        tableView.dataSource = manager
        tableView.delegate = manager
        tableView.prefetchDataSource = manager
        listManager = manager
    }

    private func setupSearch() {
        var search = UISearchController(searchResultsController: nil)
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
        refreshControl.endRefreshing()

        switch state.loadingState {
        case .initial:
            stateView.setState(.hidden)
            tableView.isHidden = true

        case .loading:
            stateView.setState(.loading(message: nil))
            tableView.isHidden = true

        case .content:
            stateView.setState(.hidden)
            tableView.isHidden = false
            listManager?.setItems(state.contentItems ?? [], in: tableView)

        case .empty:
            stateView.setState(.empty(title: "Пока пусто", message: "Список пуст или ничего не найдено по запросу."))
            tableView.isHidden = true

        case .error:
            var message = state.errorMessage ?? "Ошибка"
            stateView.setState(.error(message: message, showsRetry: true))
            tableView.isHidden = true
        }
    }

    @objc private func didPullToRefresh() {
        viewModel?.clearCache()
    }
}

extension CatalogViewController: CatalogListManagerDelegate {
    func didSelectAlbum(id: String) {
        viewModel?.didSelectAlbum(id: id)
    }

    func didDisplayItem(at index: Int, totalCount: Int) {
        viewModel?.didDisplayItem(at: index, totalCount: totalCount)
    }
}

extension CatalogViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        viewModel?.didSearch(query: searchController.searchBar.text ?? "")
    }
}
