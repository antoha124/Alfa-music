import UIKit

class TrackDetailViewController: UIViewController, TrackDetailView {
    var viewModel: TrackDetailViewModelProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel?.didLoad()
    }

    func render(_ state: TrackDetailViewState) {}
}
