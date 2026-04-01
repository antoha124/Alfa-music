import UIKit

final class TrackDetailCoordinator: Coordinator, TrackDetailCoordinatorProtocol {

    let navigationController: UINavigationController
    private let albumId: String

    init(navigationController: UINavigationController, albumId: String) {
        self.navigationController = navigationController
        self.albumId = albumId
    }

    func start() {
        let trackRepository: TrackRepositoryProtocol = TrackRepository()
        let trackService: TrackServiceProtocol = TrackService(repo: trackRepository)

        let vm: TrackDetailViewModelProtocol = TrackDetailViewModel(
            albumId: albumId,
            service: trackService
        )

        let vc = TrackDetailViewController()
        vc.viewModel = vm
        vm.view = vc
        navigationController.pushViewController(vc, animated: true)
    }
}
