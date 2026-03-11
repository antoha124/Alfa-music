class AuthRepository: AuthRepositoryProtocol {
    private enum Credentials {
        static let email = "user@alfa.ru"
        static let password = "music123"
        static let userId = "usr_001"
        static let displayName = "Alfa User"
        static let token = "hardcoded_token_abc"
    }

    func login(request: LoginRequest) throws -> LoginResponse {
        guard request.email == Credentials.email,
              request.password == Credentials.password else {
            throw AuthError.invalidCredentials
        }
        return LoginResponse(
            token: Credentials.token,
            userId: Credentials.userId,
            displayName: Credentials.displayName
        )
    }
}
