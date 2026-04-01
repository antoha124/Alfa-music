import UIKit

final class TrackDetailViewController: UIViewController, TrackDetailView {

    var viewModel: TrackDetailViewModelProtocol?

    private let tableView = UITableView(frame: .zero, style: .plain)
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    private let messageLabel = UILabel()

    private var manager: TrackListManager?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Треки"

        setupUI()
        setupManager()

        viewModel?.view = self
        viewModel?.didLoad()
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
            messageLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])

        messageLabel.isHidden = true
    }

    private func setupManager() {
        let m = TrackListManager(tableView: tableView)
        m.delegate = self
        manager = m
    }

    func render(_ state: TrackListViewState) {
        switch state.state {
        case .initial:
            loadingIndicator.stopAnimating()
            tableView.isHidden = true
            messageLabel.isHidden = true

        case .loading:
            loadingIndicator.startAnimating()
            tableView.isHidden = true
            messageLabel.isHidden = true

        case .content(let items):
            loadingIndicator.stopAnimating()
            messageLabel.isHidden = true
            tableView.isHidden = false
            manager?.setItems(items)

        case .empty:
            loadingIndicator.stopAnimating()
            tableView.isHidden = true
            messageLabel.text = "В этом альбоме пока нет треков"
            messageLabel.isHidden = false

        case .error(let message):
            loadingIndicator.stopAnimating()
            tableView.isHidden = true
            messageLabel.text = message
            messageLabel.isHidden = false
        }
    }
}

extension TrackDetailViewController: TrackListManagerDelegate {
    func didSelectTrack(id: String) {
        viewModel?.didSelectTrack(id: id)
    }
}
