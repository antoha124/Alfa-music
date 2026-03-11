import UIKit

class AuthCoordinator: Coordinator, AuthCoordinatorProtocol {

    let navigationController: UINavigationController
    private var childCoordinator: (any Coordinator)?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let repo = AuthRepository()
        let service = AuthService(repo: repo)
        let viewModel = AuthViewModel(service: service, coordinator: self)
        let viewController = AuthViewController()
        viewController.viewModel = viewModel
        navigationController.setViewControllers([viewController], animated: false)
    }

    func showCatalog(session: UserSession) {
        let catalogCoordinator = CatalogCoordinator(
            navigationController: navigationController,
            session: session
        )
        childCoordinator = catalogCoordinator
        catalogCoordinator.start()
    }
}
