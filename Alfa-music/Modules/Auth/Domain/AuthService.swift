class AuthService: AuthServiceProtocol {

    private let repo: AuthRepositoryProtocol

    init(repo: AuthRepositoryProtocol) { self.repo = repo }

    func login(_ request: LoginRequest) throws -> UserSession {
        let response = try repo.login(request: request)
        return UserSession(
            token: response.token,
            userId: response.userId,
            displayName: response.displayName
        )
    }

    func loginAsGuest() throws -> UserSession {
        return UserSession(token: "guest_token", userId: "guest", displayName: "Гость")
    }
}
