import UIKit


class CatalogViewController: UIViewController, CatalogView {

    var viewModel: CatalogViewModelProtocol?
    var session: UserSession?

    private let welcomeLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 22, weight: .semibold)
        l.textAlignment = .center
        l.numberOfLines = 0
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let subtitleLabel: UILabel = {
        let l = UILabel()
        l.text = "Каталог альбомов (в разработке)"
        l.font = .systemFont(ofSize: 16)
        l.textColor = .secondaryLabel
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let iconLabel: UILabel = {
        let l = UILabel()
        l.text = "МУЗЫКА WWW"
        l.font = .systemFont(ofSize: 32)
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupLayout()

        if let name = session?.displayName {
            welcomeLabel.text = "Добро пожаловать,\(name)!"
        } else {
            welcomeLabel.text = "Добро пожаловать!"
        }

        viewModel?.view = self
        viewModel?.didLoad()
    }


    private func setupLayout() {
        let stack = UIStackView(arrangedSubviews: [iconLabel, welcomeLabel, subtitleLabel])
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
        ])
    }


    func render(_ state: CatalogViewState) {}


    func albumTapped(id: String) {
        viewModel?.didSelectAlbum(id: id)
    }

    func searchChanged(_ query: String) {
        viewModel?.didSearch(query: query)
    }
}
