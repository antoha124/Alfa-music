struct LoginResponse: Decodable {
    let token: String
    let userId: String
    let displayName: String
}
