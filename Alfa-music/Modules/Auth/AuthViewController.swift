import UIKit

@MainActor
final class AuthViewController: BDUIScreenHostingViewController, AuthView {

    var viewModel: AuthViewModelProtocol?
    private let screenBuilder = AuthBDUIScreenBuilder()

    init() {
        super.init(
            loader: BundleBDUIScreenLoader(),
            registry: BDUIMapperRegistry.makeDefault(),
            actionBinder: BDUIActionBinder(),
            actionHandler: BDUIActionHandler()
        )
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Вход"

        onCallback = { [weak self] callbackID in
            guard let self else { return }
            switch callbackID {
            case "auth_login_tap":
                let email = (renderedView(withID: "auth_email_field") as? DSFormTextField)?.currentText() ?? ""
                let password = (renderedView(withID: "auth_password_field") as? DSFormTextField)?.currentText() ?? ""
                viewModel?.didTapLogin(email: email, password: password)
            case "auth_guest_tap":
                viewModel?.didTapGuestLogin()
            case "auth_retry_tap":
                viewModel?.didLoad()
            default:
                break
            }
        }

        viewModel?.view = self
        viewModel?.didLoad()
    }

    func render(_ state: AuthViewState) {
        render(screen: screenBuilder.makeScreen(state: state))
    }
}
