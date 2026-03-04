class AuthViewModel: AuthViewModelProtocol {
    weak var view: AuthView?

    private let service: AuthServiceProtocol

    init(service: AuthServiceProtocol) {
        self.service = service
    }

    func didLoad() {}
    func didTapLogin(email: String, password: String) {
        // вызывать сервис буду
    }
    func didTapGuestLogin() {}
}
