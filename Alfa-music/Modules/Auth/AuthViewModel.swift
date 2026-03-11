import Foundation

class AuthViewModel: AuthViewModelProtocol {

    weak var view: AuthView?
    weak var coordinator: AuthCoordinatorProtocol?
    private let service: AuthServiceProtocol

    private var viewState: AuthViewState = AuthViewState(isLoading: false, errorText: nil) {
        didSet {
            if viewState != oldValue {
                view?.render(viewState)
            }
        }
    }

    init(service: AuthServiceProtocol, coordinator: AuthCoordinatorProtocol) {
        self.service = service
        self.coordinator = coordinator
    }


    func didLoad() {
        view?.render(viewState)
    }

    func didTapLogin(email: String, password: String) {
        let email = email.trimmingCharacters(in: .whitespaces)
        let password = password.trimmingCharacters(in: .whitespaces)

        guard !email.isEmpty, !password.isEmpty else {
            viewState = AuthViewState(isLoading: false, errorText: "Введите email и пароль")
            return
        }

        do {
            let session = try service.login(LoginRequest(email: email, password: password))
            coordinator?.showCatalog(session: session)
        } catch AuthError.invalidCredentials {
            viewState = AuthViewState(isLoading: false, errorText: "Неверный email или пароль")
        } catch {
            viewState = AuthViewState(isLoading: false, errorText: "Ошибка: \(error.localizedDescription)")
        }
    }

    func didTapGuestLogin() {
        do {
            let session = try service.loginAsGuest()
            coordinator?.showCatalog(session: session)
        } catch {
            viewState = AuthViewState(isLoading: false, errorText: "Не удалось войти как гость")
        }
    }
}
