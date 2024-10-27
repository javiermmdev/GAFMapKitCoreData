import Foundation

/// Enum representing the different API endpoints in the app
enum GAEndpoint {
    case heroes
    case locations
    case transformations
    case login
    
    // MARK: - Path for API Endpoints
    /// Retrieves the path for each endpoint
    /// - Returns: The specific path as a `String` for the selected endpoint
    func path() -> String {
        switch self {
        case .heroes:
            return "/api/heros/all"
        case .locations:
            return "/api/heros/locations"
        case .transformations:
            return "/api/heros/tranformations"
        case .login:
            return "/api/auth/login"
        }
    }
    
    // MARK: - HTTP Method for API Endpoints
    /// Retrieves the HTTP method to be used with each endpoint
    /// - Returns: The HTTP method (`POST`) as a `String` for the selected endpoint
    func httpMethod() -> String {
        switch self {
        case .heroes, .locations, .transformations, .login:
            return "POST"
        }
    }
}
