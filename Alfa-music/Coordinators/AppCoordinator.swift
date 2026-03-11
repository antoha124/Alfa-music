import UIKit

class AppCoordinator: Coordinator {

    let navigationController: UINavigationController
    private var childCoordinator: (any Coordinator)?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let authCoordinator = AuthCoordinator(navigationController: navigationController)
        childCoordinator = authCoordinator
        authCoordinator.start()
    }
}
