import UIKit

final class TrackDetailViewController: UIViewController, TrackDetailView {

    var viewModel: TrackDetailViewModelProtocol?

    private var tableView = UITableView(frame: .zero, style: .plain)
    private var loadingIndicator = UIActivityIndicatorView(style: .large)
    private var messageLabel = UILabel()
    private var retryButton = UIButton(type: .system)

    private var listManager: TrackListManager?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Треки"

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "К каталогу",
            style: .plain,
            target: self,
            action: #selector(didTapBackToCatalog)
        )

        setupUI()
        setupList()

        viewModel?.view = self
        viewModel?.didLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    private func setupUI() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
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
            messageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: DS.Layout.TrackDetail.stateHorizontalInset),
            messageLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -DS.Layout.TrackDetail.stateHorizontalInset),

            retryButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: DS.Layout.TrackDetail.retryTopSpacing),
            retryButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        messageLabel.isHidden = true
        retryButton.isHidden = true
    }

    private func setupList() {
        tableView.register(TrackListCell.self, forCellReuseIdentifier: TrackListCell.reuseIdentifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60

        var manager = TrackListManager()
        manager.delegate = self
        tableView.dataSource = manager
        tableView.delegate = manager
        listManager = manager
    }

    func render(_ state: TrackListViewState) {
        switch state.state {
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
            messageLabel.text = "В этом альбоме пока нет треков"
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

    @objc private func didTapBackToCatalog() {
        viewModel?.didTapBack()
    }

    @objc private func didTapRetry() {
        viewModel?.didTapRetry()
    }
}

extension TrackDetailViewController: TrackListManagerDelegate {
    func didSelectTrack(id: String) {
        viewModel?.didSelectTrack(id: id)
    }
}
