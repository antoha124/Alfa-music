import UIKit

class CatalogCoordinator: Coordinator, CatalogCoordinatorProtocol {

    let navigationController: UINavigationController
    private let session: UserSession
    private var childCoordinator: (any Coordinator)?

    init(navigationController: UINavigationController, session: UserSession) {
        self.navigationController = navigationController
        self.session = session
    }

    func start() {
        navigationController.setNavigationBarHidden(false, animated: true)

        let networkClient: NetworkClient = URLSessionNetworkClient()
        let repository: CatalogRepositoryProtocol = CatalogRepository(networkClient: networkClient)
        let service: CatalogServiceProtocol = CatalogService(repo: repository)
        let viewModel: CatalogViewModel = CatalogViewModel(useCase: service, coordinator: self)

        let viewController = CatalogViewController()
        viewController.session = session
        viewController.viewModel = viewModel

        viewModel.view = viewController

        navigationController.setViewControllers([viewController], animated: true)
    }

    func showTracks(albumId: String) {
        let tracksCoordinator = TrackDetailCoordinator(
            navigationController: navigationController,
            albumId: albumId,
            onFinish: { [weak self] in
                self?.childCoordinator = nil
            }
        )
        childCoordinator = tracksCoordinator
        tracksCoordinator.start()
    }
}
