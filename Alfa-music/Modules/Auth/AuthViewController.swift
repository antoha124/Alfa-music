import UIKit

@MainActor
final class AuthViewController: BDUIScreenHostingViewController, AuthView {

    var viewModel: AuthViewModelProtocol?

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

        onAction = { [weak self] action in
            guard let self else { return }
            switch action {
            case .event(let name, _):
                switch name {
                case "submit":
                let email = (renderedView(withID: "auth_email_field") as? DSFormTextField)?.currentText() ?? ""
                let password = (renderedView(withID: "auth_password_field") as? DSFormTextField)?.currentText() ?? ""
                viewModel?.didTapLogin(email: email, password: password)
                case "alternate":
                    viewModel?.didTapGuestLogin()
                case "retry":
                    viewModel?.didLoad()
                default:
                    break
                }
            }
        }

        viewModel?.view = self
        viewModel?.didLoad()
    }

    func render(_ state: AuthViewState) {
        if let errorText = state.errorText, !errorText.isEmpty {
            render(
                templateName: "auth_error",
                context: ["errorMessage": Self.escapeForJSON(errorText)]
            )
            return
        }

        render(templateName: "auth_idle", context: [:])
    }

    private static func escapeForJSON(_ value: String) -> String {
        value
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
            .replacingOccurrences(of: "\n", with: "\\n")
    }
}
