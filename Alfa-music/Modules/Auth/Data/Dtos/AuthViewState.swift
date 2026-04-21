struct AuthViewState: Equatable {
    var isLoading: Bool
    var emailError: String?
    var passwordError: String?
    var errorText: String?

    init(
        isLoading: Bool = false,
        emailError: String? = nil,
        passwordError: String? = nil,
        errorText: String? = nil
    ) {
        self.isLoading = isLoading
        self.emailError = emailError
        self.passwordError = passwordError
        self.errorText = errorText
    }
}
