import UIKit

final class TrackDetailCoordinator: Coordinator, TrackDetailCoordinatorProtocol {

    let navigationController: UINavigationController
    private let albumId: String
    private let onFinish: () -> Void

    init(
        navigationController: UINavigationController,
        albumId: String,
        onFinish: @escaping () -> Void = {}
    ) {
        self.navigationController = navigationController
        self.albumId = albumId
        self.onFinish = onFinish
    }

    func start() {
        let trackRepository: TrackRepositoryProtocol = TrackRepository()
        let trackService: TrackServiceProtocol = TrackService(repo: trackRepository)

        let vm: TrackDetailViewModelProtocol = TrackDetailViewModel(
            albumId: albumId,
            service: trackService,
            coordinator: self
        )

        let vc = TrackDetailViewController()
        vc.viewModel = vm
        vm.view = vc
        navigationController.pushViewController(vc, animated: true)
    }

    func finish() {
        navigationController.popViewController(animated: true)
        onFinish()
    }
}
