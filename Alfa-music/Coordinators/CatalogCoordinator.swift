import UIKit

class CatalogCoordinator: Coordinator {

    let navigationController: UINavigationController
    private let session: UserSession

    init(navigationController: UINavigationController, session: UserSession) {
        self.navigationController = navigationController
        self.session = session
    }

    func start() {
        let networkClient: NetworkClient = URLSessionNetworkClient()
        let repository: CatalogRepositoryProtocol = CatalogRepository(networkClient: networkClient)
        let service: CatalogServiceProtocol = CatalogService(repo: repository)
        let viewModel: CatalogViewModelProtocol = CatalogViewModel(useCase: service)
        
        let viewController = CatalogViewController()
        viewController.session = session
        viewController.viewModel = viewModel
        
        viewModel.view = viewController
        
        navigationController.setViewControllers([viewController], animated: true)
    }
}
