import Foundation

// MARK: - ApiProviderProtocol

/// Protocol defining methods for loading heroes, locations, transformations, and login functionality
protocol ApiProviderProtocol {
    func loadHeros(name: String, completion: @escaping ((Result<[ApiHero], GAError>) -> Void))
    func loadLocations(id: String, completion: @escaping ((Result<[ApiLocation], GAError>) -> Void))
    func loadTransformations(id: String, completion: @escaping ((Result<[ApiTransformation], GAError>) -> Void))
    func login(username: String, password: String, completion: @escaping ((Result<String, GAError>) -> Void))
}

// MARK: - ApiProvider

/// Class responsible for handling API calls related to heroes, locations, transformations, and user login
class ApiProvider: ApiProviderProtocol {
    private let session: URLSession
    private let requestBuilder: GARequestBuilder
    
    // MARK: - Initializer
    
    /// Initializes with URLSession and request builder, using default shared session
    /// - Parameters:
    ///   - session: URLSession for network tasks (default is `.shared`)
    ///   - requestBuilder: Responsible for constructing API requests
    init(session: URLSession = .shared, requestBuilder: GARequestBuilder = GARequestBuilder()) {
        self.session = session
        self.requestBuilder = requestBuilder
    }
    
    // MARK: - Load Heroes
    
    /// Loads a list of heroes based on the provided name
    /// - Parameters:
    ///   - name: Name of the hero to filter the search (default is an empty string for all heroes)
    ///   - completion: Completion handler with the result containing either an array of heroes or an error
    func loadHeros(name: String = "", completion: @escaping ((Result<[ApiHero], GAError>) -> Void)) {
        do {
            // Build the request for heroes endpoint
            let request = try requestBuilder.buildRequest(endPoint: .heroes, params: ["name": name])
            makeRequest(request: request, completion: completion)
        } catch {
            completion(.failure(.errorFromServer(error: error)))
        }
    }
    
    // MARK: - Load Locations
    
    /// Loads a list of locations associated with a specific hero ID
    /// - Parameters:
    ///   - id: The hero ID to retrieve locations for
    ///   - completion: Completion handler with the result containing either an array of locations or an error
    func loadLocations(id: String, completion: @escaping ((Result<[ApiLocation], GAError>) -> Void)) {
        do {
            // Build the request for locations endpoint
            let request = try requestBuilder.buildRequest(endPoint: .locations, params: ["id": id])
            makeRequest(request: request, completion: completion)
        } catch {
            completion(.failure(.errorFromServer(error: error)))
        }
    }
    
    // MARK: - Load Transformations
    
    /// Loads a list of transformations associated with a specific hero ID
    /// - Parameters:
    ///   - id: The hero ID to retrieve transformations for
    ///   - completion: Completion handler with the result containing either an array of transformations or an error
    func loadTransformations(id: String, completion: @escaping ((Result<[ApiTransformation], GAError>) -> Void)) {
        do {
            // Build the request for transformations endpoint
            let request = try requestBuilder.buildRequest(endPoint: .transformations, params: ["id": id])
            makeRequest(request: request, completion: completion)
        } catch {
            completion(.failure(.errorFromServer(error: error)))
        }
    }
    
    // MARK: - Login
    
    /// Logs in the user by validating the username and password
    /// - Parameters:
    ///   - username: Username for authentication
    ///   - password: Password for authentication
    ///   - completion: Completion handler with the result containing either a token or an error
    func login(username: String, password: String, completion: @escaping ((Result<String, GAError>) -> Void)) {
        // Encode the username and password in base64 format for basic auth
        let loginString = "\(username):\(password)"
        guard let loginData = loginString.data(using: .utf8) else {
            completion(.failure(GAError.authenticationFailed))
            return
        }
        let base64LoginString = loginData.base64EncodedString()
        
        do {
            // Build the request for login endpoint
            var request = try requestBuilder.buildRequest(endPoint: .login, params: [:], requiresToken: false)
            // Set Authorization header with encoded credentials
            request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
            makeRequest(request: request, completion: completion)
        } catch {
            completion(.failure(GAError.errorFromApi(statusCode: 400))) // Error in request creation
        }
    }
    
    // MARK: - Make Request
    
    /// Sends the request to the server and handles the response
    /// - Parameters:
    ///   - request: The URLRequest to be sent
    ///   - completion: Completion handler with the result, containing either the decoded response data or an error
    private func makeRequest<T: Decodable>(request: URLRequest, completion: @escaping ((Result<T, GAError>) -> Void)) {
        session.dataTask(with: request) { data, response, error in
            // Check for a network error
            if let error = error {
                completion(.failure(.errorFromServer(error: error)))
                return
            }
            
            // Ensure a valid HTTP response was received
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.noDataReceived))
                return
            }
            
            switch httpResponse.statusCode {
            case 200:
                // Process data if the response status is 200 (OK)
                guard let data = data, !data.isEmpty else {
                    completion(.failure(.noDataReceived))
                    return
                }
                
                // Special handling for string-based token responses
                if T.self == String.self {
                    if let token = String(data: data, encoding: .utf8) {
                        completion(.success(token as! T))
                    } else {
                        completion(.failure(.errorParsingData))
                    }
                    return
                }
                
                // Decode the JSON data into the expected model
                do {
                    let apiInfo = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(apiInfo))
                } catch {
                    completion(.failure(.errorParsingData))
                }
                
            case 401:
                // Handle authentication failure
                completion(.failure(.authenticationFailed))
                
            default:
                // Handle other response status codes
                completion(.failure(.errorFromApi(statusCode: httpResponse.statusCode)))
            }
        }.resume()
    }
}
