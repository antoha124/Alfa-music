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

        let emailError = validateEmail(email)
        let passwordError = validatePassword(password)
        guard emailError == nil, passwordError == nil else {
            viewState = AuthViewState(
                isLoading: false,
                emailError: emailError,
                passwordError: passwordError,
                errorText: nil
            )
            return
        }

        do {
            let session = try service.login(LoginRequest(email: email, password: password))
            coordinator?.showCatalog(session: session)
        } catch AuthError.invalidCredentials {
            viewState = AuthViewState(
                isLoading: false,
                emailError: nil,
                passwordError: "Неверный email или пароль",
                errorText: "Неверный email или пароль"
            )
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

    private func validateEmail(_ email: String) -> String? {
        guard !email.isEmpty else { return "Введите email" }
        guard email.contains("@"), email.contains(".") else {
            return "Введите корректный email"
        }
        return nil
    }

    private func validatePassword(_ password: String) -> String? {
        guard !password.isEmpty else { return "Введите пароль" }
        guard password.count >= 4 else { return "Минимум 4 символа" }
        return nil
    }
}
