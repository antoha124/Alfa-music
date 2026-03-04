protocol AuthServiceProtocol {
    func login(_ request: LoginRequest) throws -> UserSession
    func loginAsGuest() throws -> UserSession
}



protocol AuthViewModelProtocol: AnyObject {
    var view: AuthView? { get set }
    func didLoad()
    func didTapLogin(email: String, password: String)
    func didTapGuestLogin()
}


protocol AuthRepositoryProtocol {
    func login(request: LoginRequest) throws -> LoginResponse
}


protocol AuthView: AnyObject {
    func render(_ state: AuthViewState)
}
