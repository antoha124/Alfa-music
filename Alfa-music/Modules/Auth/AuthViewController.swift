import UIKit

class AuthViewController: UIViewController, AuthView{
    var viewModel: AuthViewModelProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel?.view = self
        viewModel?.didLoad()
    }

    private func loginTapped() {
        viewModel?.didTapLogin(email: "email", password: "password")
    }

    private func guestTapped() {
        viewModel?.didTapGuestLogin()
    }
    
    func render(_ state: AuthViewState) {}

}
