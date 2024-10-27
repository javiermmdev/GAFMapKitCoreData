import Foundation

// MARK: - GARequestBuilder

/// Class responsible for building API requests, including URL creation and header configuration
class GARequestBuilder {
    
    /// Host of the API
    private let host = "dragonball.keepcoding.education"
    private var request: URLRequest?
    
    /// Session token retrieved from Keychain (SecureDataStore)
    var token: String? {
        secureStorage.getToken()
    }
    
    private let secureStorage: SecureDataStoreProtocol
    
    // MARK: - Initializer
    /// Initializes with `SecureDataStore` to manage secure storage
    /// - Parameter secureStorage: Dependency injection for secure storage, defaults to `SecureDataStore.shared`
    init(secureStorage: SecureDataStoreProtocol = SecureDataStore.shared) {
        self.secureStorage = secureStorage
    }
    
    // MARK: - URL Generation
    /// Generates the URL for the request based on the provided endpoint
    /// - Parameter endPoint: The endpoint for which the URL is created
    /// - Returns: The URL constructed from URL components
    /// - Throws: `GAError.badUrl` if the URL could not be created
    private func url(endPoint: GAEndpoint) throws -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = self.host
        components.path = endPoint.path()
        if let url = components.url {
            return url
        } else {
            throw GAError.badUrl
        }
    }
    
    // MARK: - Header Configuration
    /// Sets up headers for the request, including authorization if required
    /// - Parameters:
    ///   - params: Parameters to be included in the request body
    ///   - requiresToken: Indicates if the request requires an authorization token
    /// - Throws: `GAError.sessionTokenMissing` if token is required but not available, or `GAError.errorParsingData` if parameters can't be serialized
    private func setHeaders(params: [String: String]?, requiresToken: Bool = true) throws {
        if requiresToken {
            guard let token = self.token else { throw GAError.sessionTokenMissing }
            request?.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let params = params {
            do {
                // Convert parameters to JSON and set as request body
                let jsonData = try JSONSerialization.data(withJSONObject: params)
                request?.httpBody = jsonData
            } catch {
                throw GAError.errorParsingData
            }
        }
        
        // Set content and accept headers to JSON
        request?.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request?.setValue("application/json", forHTTPHeaderField: "Accept")
    }
    
    // MARK: - Request Building
    /// Builds a URLRequest based on provided endpoint, parameters, and token requirements
    /// - Parameters:
    ///   - endPoint: The `GAEndpoint` for which the request is being created
    ///   - params: Parameters to include in the request body
    ///   - requiresToken: Specifies if the request needs an authentication token
    /// - Returns: A configured URLRequest ready to be used for network calls
    /// - Throws: `GAError.requestWasNil` if request creation fails, or any error thrown by URL and header methods
    func buildRequest(endPoint: GAEndpoint, params: [String: String], requiresToken: Bool = true) throws -> URLRequest {
        do {
            // Ensure URL creation is successful, and if token is required, it exists
            let url = try self.url(endPoint: endPoint)
            // Initialize the request with URL and HTTP method
            request = URLRequest(url: url)
            request?.httpMethod = endPoint.httpMethod()
            // Set up headers
            try setHeaders(params: params, requiresToken: requiresToken)
            // Return the completed request
            if let finalRequest = self.request {
                return finalRequest
            }
        } catch {
            throw error
        }
        throw GAError.requestWasNil
    }
}
