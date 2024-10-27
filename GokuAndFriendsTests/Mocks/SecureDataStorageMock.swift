
import Foundation
@testable import GokuAndFriends

/// Mock class for `SecureDataStorage` implementing `SecureDataStoreProtocol`
/// This mock uses `UserDefaults` instead of Keychain for testing purposes
class SecureDataStorageMock: SecureDataStoreProtocol {
    
    private let kToken = "kToken"
    private var userDefaults = UserDefaults.standard
    
    /// Sets the token in `UserDefaults`, replacing any existing token
    func set(token: String) {
        deleteToken()
        userDefaults.set(token, forKey: kToken)
    }
    
    /// Retrieves the token from `UserDefaults`
    func getToken() -> String? {
        userDefaults.string(forKey: kToken)
    }
    
    /// Deletes the token from `UserDefaults`
    func deleteToken() {
        userDefaults.removeObject(forKey: kToken)
    }
}
