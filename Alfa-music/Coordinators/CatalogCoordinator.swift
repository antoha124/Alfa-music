import UIKit

class CatalogCoordinator: Coordinator {

    let navigationController: UINavigationController
    private let session: UserSession

    init(navigationController: UINavigationController, session: UserSession) {
        self.navigationController = navigationController
        self.session = session
    }

    func start() {
        let viewController = CatalogViewController()
        viewController.session = session
        navigationController.setViewControllers([viewController], animated: true)
    }
}
