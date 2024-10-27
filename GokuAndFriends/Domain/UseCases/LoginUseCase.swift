import Foundation

// MARK: - Protocol Definition
/// Protocol that defines the login use case.
protocol LoginUseCaseProtocol {
    /// Authenticates the user.
    /// - Parameters:
    ///   - username: Username for login.
    ///   - password: Password for login.
    ///   - completion: Closure returning a `Result` with `Void` on success or a `GAError` on failure.
    func login(username: String, password: String, completion: @escaping (Result<Void, GAError>) -> Void)
}

// MARK: - LoginUseCase Implementation
class LoginUseCase: LoginUseCaseProtocol {
    
    private let apiProvider: ApiProviderProtocol
    private let secureDataStore: SecureDataStoreProtocol
    
    // MARK: - Initializer
    /// Initializes the login use case.
    /// - Parameters:
    ///   - apiProvider: Injected API provider, default is `ApiProvider`.
    ///   - secureDataStore: Secure data store for storing the token.
    init(apiProvider: ApiProviderProtocol = ApiProvider(), secureDataStore: SecureDataStoreProtocol = SecureDataStore.shared) {
        self.apiProvider = apiProvider
        self.secureDataStore = secureDataStore
    }
    
    // MARK: - Login Function
    /// Performs the login operation.
    /// - Parameters:
    ///   - username: Username for login.
    ///   - password: Password for login.
    ///   - completion: Closure returning a `Result` with `Void` on success or a `GAError` on failure.
    func login(username: String, password: String, completion: @escaping (Result<Void, GAError>) -> Void) {
        guard !username.isEmpty, !password.isEmpty else {
            completion(.failure(.errorParsingData))
            return
        }

        apiProvider.login(username: username, password: password) { [weak self] result in
            switch result {
            case .success(let token):
                self?.secureDataStore.set(token: token) // Directly stores the token
                completion(.success(())) // Login successful
            case .failure(let error):
                completion(.failure(error)) // Handles error
            }
        }
    }
}
