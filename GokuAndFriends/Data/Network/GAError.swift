import Foundation

/// Enum representing errors managed within the app
/// Implements CustomStringConvertible to provide custom error descriptions
enum GAError: Error, CustomStringConvertible {
    
    case requestWasNil
    case errorFromServer(error: Error)
    case errorFromApi(statusCode: Int)
    case noDataReceived
    case errorParsingData
    case coreDataError(error: Error)
    case authenticationFailed
    case sessionTokenMissing
    case badUrl
    case heroNotFound(heroId: String)
    
    // MARK: - Error Description

    /// Provides a description of the error for debugging and user feedback
    var description: String {
        switch self {
        case .requestWasNil:
            return "Error creating request"
        case .errorFromServer(error: let error):
            return "Received error from server with code \((error as NSError).code)"
        case .errorFromApi(statusCode: let code):
            return "Received error from API with status code \(code)"
        case .noDataReceived:
            return "No data received from server"
        case .errorParsingData:
            return "An error occurred while parsing data"
        case .coreDataError(error: let error):
            return "Core Data error: \((error as NSError).localizedDescription)"
        case .authenticationFailed:
            return "Authentication failed. Please check your credentials"
        case .sessionTokenMissing:
            return "Session token is missing"
        case .badUrl:
            return "Invalid URL provided"
        case .heroNotFound(heroId: let heroId):
            return "Hero with ID \(heroId) not found"
        }
    }
}
