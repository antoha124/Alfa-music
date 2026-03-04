class AuthService: AuthServiceProtocol {
    private let repo: AuthRepositoryProtocol

    init(repo: AuthRepositoryProtocol) { self.repo = repo }

    func login(_ request: LoginRequest) throws -> UserSession {
        //
        fatalError()
    }
    func loginAsGuest() throws -> UserSession {
        //
        fatalError()
    }
}
