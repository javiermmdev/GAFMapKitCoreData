import KeychainSwift

// MARK: - SecureDataStoreProtocol

/// Protocol defining methods for storing, retrieving, and deleting a token in secure storage
protocol SecureDataStoreProtocol {
    
    func set(token: String)
    func getToken() -> String?
    func deleteToken()
}

// MARK: - SecureDataStore

/// Class to interact with Keychain using the KeychainSwift library
/// The KeychainSwift library was added as a project dependency using Swift Package Manager (SPM)
class SecureDataStore: SecureDataStoreProtocol {
    
    /// Key used for storing the token in Keychain
    private let kToken = "kToken"
    private let keychain  = KeychainSwift()
    
    /// Shared instance for accessing SecureDataStore globally
    static let shared: SecureDataStore = .init()
    
    /// Stores the token in Keychain
    /// - Parameter token: The token string to store
    func set(token: String) {
        // Avoids duplicates by deleting any existing token before setting a new one
        deleteToken()
        keychain.set(token, forKey: kToken)
    }
    
    /// Retrieves the token from Keychain, if it exists
    /// - Returns: An optional string containing the token, or nil if it doesn't exist
    func getToken() -> String? {
        keychain.get(kToken)
    }
    
    /// Deletes the token from Keychain
    func deleteToken() {
        keychain.delete(kToken)
    }
    
}
