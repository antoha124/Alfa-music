import UIKit

final class CatalogViewController: UIViewController, CatalogView {

    var viewModel: CatalogViewModelProtocol?
    var session: UserSession?

    private let tableView = UITableView(frame: .zero, style: .plain)
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    private let messageLabel = UILabel()
    private let retryButton = UIButton(type: .system)

    private lazy var refreshControl: UIRefreshControl = {
        let c = UIRefreshControl()
        c.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        return c
    }()

    private let imageLoader: ImageLoaderProtocol = ImageLoader()
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
        let manager = CatalogListManager(tableView: tableView, imageLoader: imageLoader)
        manager.delegate = self
        listManager = manager
    }

    private func setupSearch() {
        let search = UISearchController(searchResultsController: nil)
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

        case .content(let items):
            loadingIndicator.stopAnimating()
            messageLabel.isHidden = true
            retryButton.isHidden = true
            tableView.isHidden = false
            listManager?.setItems(items)

        case .empty:
            loadingIndicator.stopAnimating()
            tableView.isHidden = true
            messageLabel.text = "Пока пусто"
            messageLabel.isHidden = false
            retryButton.isHidden = true

        case .error(let message):
            loadingIndicator.stopAnimating()
            tableView.isHidden = true
            messageLabel.text = message
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

    func didReachListEnd() {
        viewModel?.didLoadMore()
    }
}

extension CatalogViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let query = searchController.searchBar.text ?? ""
        listManager?.applyFilter(query: query)
    }
}
