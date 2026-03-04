import UIKit


class CatalogViewController: UIViewController, CatalogView {
    var viewModel: CatalogViewModelProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel?.view = self
        viewModel?.didLoad()
    }

    func albumTapped(id: String) {
        viewModel?.didSelectAlbum(id: id)
    }

    func searchChanged(_ query: String) {
        viewModel?.didSearch(query: query)
    }
    
    func render(_ state: CatalogViewState) {}

}
