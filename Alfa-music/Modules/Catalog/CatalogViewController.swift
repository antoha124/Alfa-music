import UIKit

final class CatalogViewController: UIViewController, CatalogView {

    var viewModel: CatalogViewModelProtocol?
    var session: UserSession?

    private var tableView = UITableView(frame: .zero, style: .plain)
    private var loadingIndicator = UIActivityIndicatorView(style: .large)
    private var messageLabel = UILabel()
    private var retryButton = UIButton(type: .system)

    private lazy var refreshControl: UIRefreshControl = {
        var c = UIRefreshControl()
        c.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        return c
    }()

    private var imageLoader: ImageLoaderProtocol = ImageLoader()
    private var listManager: CatalogListManager?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Каталог"

        setupUI()
        setupList()
        setupSearch()

        viewModel?.view = self
        viewModel?.didLoad()
    }

    private func setupUI() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.refreshControl = refreshControl
        view.addSubview(tableView)

        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.hidesWhenStopped = true
        view.addSubview(loadingIndicator)

        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        messageLabel.textColor = .secondaryLabel
        view.addSubview(messageLabel)

        retryButton.translatesAutoresizingMaskIntoConstraints = false
        retryButton.setTitle("Повторить", for: .normal)
        retryButton.addTarget(self, action: #selector(didTapRetry), for: .touchUpInside)
        view.addSubview(retryButton)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            messageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            messageLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            messageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            messageLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            retryButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 12),
            retryButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        messageLabel.isHidden = true
        retryButton.isHidden = true
    }

    private func setupList() {
        tableView.register(AlbumCell.self, forCellReuseIdentifier: AlbumCell.reuseIdentifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 76

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

        navigationItem.searchController = search
        navigationItem.hidesSearchBarWhenScrolling = false

        definesPresentationContext = true

        navigationItem.searchController?.hidesNavigationBarDuringPresentation = false
    }

    func render(_ state: CatalogViewState) {
        refreshControl.endRefreshing()

        switch state.loadingState {
        case .initial:
            loadingIndicator.stopAnimating()
            tableView.isHidden = true
            messageLabel.isHidden = true
            retryButton.isHidden = true

        case .loading:
            loadingIndicator.startAnimating()
            tableView.isHidden = true
            messageLabel.isHidden = true
            retryButton.isHidden = true

        case .content:
            loadingIndicator.stopAnimating()
            messageLabel.isHidden = true
            retryButton.isHidden = true
            tableView.isHidden = false
            listManager?.setItems(state.contentItems ?? [], in: tableView)

        case .empty:
            loadingIndicator.stopAnimating()
            tableView.isHidden = true
            messageLabel.text = "Пока пусто"
            messageLabel.isHidden = false
            retryButton.isHidden = true

        case .error:
            loadingIndicator.stopAnimating()
            tableView.isHidden = true
            messageLabel.text = state.errorMessage
            messageLabel.isHidden = false
            retryButton.isHidden = false
        }
    }

    @objc private func didTapRetry() {
        viewModel?.didTapRetry()
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
