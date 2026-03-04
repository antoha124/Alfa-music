class AuthRepository: AuthRepositoryProtocol {
    
    private var users: [User] = []

    init() {}

    func login(request: LoginRequest) throws -> LoginResponse {
        fatalError()
    }
}
