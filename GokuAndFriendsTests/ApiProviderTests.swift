

import XCTest
@testable import GokuAndFriends

/// Class to test the ApiProvider functionality
final class ApiProviderTests: XCTestCase {
    
    // System Under Test (SUT) - the ApiProvider instance being tested
    var sut: ApiProvider!

    // Sets up the test environment before each test case runs
    override func setUpWithError() throws {
        
        // Configure ApiProvider:
        // - Use ephemeral session (doesn’t store cache on disk)
        // - Set protocol class to URLProtocolMock for intercepting network requests
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolMock.self]
        let session = URLSession(configuration: configuration)
        
        // Mock the SecureDataStorage for the request builder
        let requestProvider = GARequestBuilder(secureStorage: SecureDataStorageMock())
        
        // Initialize the ApiProvider
        sut = ApiProvider(session: session, requestBuilder: requestProvider)
        try super.setUpWithError()
    }

    // Cleans up after each test case runs
    override func tearDownWithError() throws {
        // Reset objects
        SecureDataStorageMock().deleteToken()
        URLProtocolMock.handler = nil
        URLProtocolMock.error = nil
        sut = nil
        try super.tearDownWithError()
    }
    
    
    // MARK: - Login Tests

    func test_login_shouldReturn_Token() throws {
        // Given
        let username = "goku"
        let password = "superSaiyan"
        let expectedToken = "ValidAuthToken"
        var receivedToken: String?
        
        // URLProtocolMock handler to simulate a successful response with a token
        URLProtocolMock.handler = { request in
            
            // Validate request properties: method, URL, and headers
            let expectedUrl = try XCTUnwrap(URL(string: "https://dragonball.keepcoding.education/api/auth/login"))
            XCTAssertEqual(request.httpMethod, "POST")
            XCTAssertEqual(request.url?.absoluteString, expectedUrl.absoluteString)
            XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Basic Z29rdTpzdXBlclNhaXlhbg==") // Base64 for "goku:superSaiyan"
            
            // Return token data and response from the handler
            let data = expectedToken.data(using: .utf8)!
            let response = HTTPURLResponse(url: expectedUrl, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (data, response)
        }
        
        // When
        let expectation = expectation(description: "Login Success")
        
        // Call the login function
        sut.login(username: username, password: password) { result in
            switch result {
            case .success(let token):
                receivedToken = token
                expectation.fulfill()
            case .failure(_):
                XCTFail("Success expected")
            }
        }
        
        // Then
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(receivedToken, expectedToken)
    }

    func test_loginError_shouldReturn_Error() throws {
        // Given
        let username = "goku"
        let password = "wrongPassword"
        var errorDescription: String?
        
        // URLProtocolMock handler simulating a 401 Unauthorized response
        URLProtocolMock.handler = { request in
            
            let expectedUrl = try XCTUnwrap(URL(string: "https://dragonball.keepcoding.education/api/auth/login"))
            XCTAssertEqual(request.httpMethod, "POST")
            XCTAssertEqual(request.url?.absoluteString, expectedUrl.absoluteString)
            XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Basic Z29rdTp3cm9uZ1Bhc3N3b3Jk") // Base64 for "goku:wrongPassword"
            
            // Simulate a 401 response with no data
            let response = HTTPURLResponse(url: expectedUrl, statusCode: 401, httpVersion: nil, headerFields: nil)!
            return (Data(), response)
        }
        
        // When
        let expectation = expectation(description: "Login Failure")
        
        // Call the login function
        sut.login(username: username, password: password) { result in
            switch result {
            case .success(_):
                XCTFail("Error expected")
            case .failure(let receivedError):
                errorDescription = receivedError.description
                expectation.fulfill()
            }
        }
        
        // Then
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(errorDescription, "Authentication failed. Please check your credentials")
    }

    
    // MARK: - Heroes Tests

    func test_loadHeros_shouldReturn_26_Heroes() throws {
        // Given
        let expecrtedToken = "Some Token"
        let expectedHero = try MockData.mockHeroes().first!
        var heroesResponse = [ApiHero]()
        
        // URLProtocolMock handler for loading heroes with simulated data and response
        URLProtocolMock.handler = { request in
            let expectedUrl = try XCTUnwrap(URL(string: "https://dragonball.keepcoding.education/api/heros/all"))
            
            XCTAssertEqual(request.httpMethod, "POST")
            XCTAssertEqual(request.url?.absoluteString, expectedUrl.absoluteString)
            XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer \(expecrtedToken)")
            
            // Return heroes data and response
            let data = try MockData.loadHeroesData()
            let response = HTTPURLResponse(url: expectedUrl, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (data, response)
        }
        
        // When
        let expectation = expectation(description: "Load Heroes")
        setToken(expecrtedToken)
        
        // Call loadHeros
        sut.loadHeros { result in
            switch result {
            case .success(let apiheroes):
                heroesResponse = apiheroes
                expectation.fulfill()
            case .failure(_):
                XCTFail("Success expected")
            }
        }
        
        // Then
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(heroesResponse.count, 26)
        let heroReceived = heroesResponse.first
        XCTAssertEqual(heroReceived?.id, expectedHero.id)
        XCTAssertEqual(heroReceived?.name, expectedHero.name)
        XCTAssertEqual(heroReceived?.description, expectedHero.description)
        XCTAssertEqual(heroReceived?.favorite, expectedHero.favorite)
        XCTAssertEqual(heroReceived?.photo, expectedHero.photo)
    }
    
    func test_loadHerosError_shouldReturn_Error() throws {
        // Given
        let expecrtedToken = "Some Token"
        var error: GAError?
        URLProtocolMock.error = NSError(domain: "ios.Keepcoding", code: 503)
        
        // When
        let expectation = expectation(description: "Load Heroes Error")
        setToken(expecrtedToken)
        
        // Call loadHeros expecting an error
        sut.loadHeros { result in
            switch result {
            case .success(_):
                XCTFail("Error expected")
            case .failure(let receivedError):
                error = receivedError
                expectation.fulfill()
            }
        }

        // Then
        wait(for: [expectation], timeout: 2)
        let receivedError = try XCTUnwrap(error)
        XCTAssertEqual(receivedError.description, "Received error from server with code 503")
    }
    
    // Sets the token in storage for testing purposes
    func setToken(_ token: String) {
        SecureDataStorageMock().set(token: token)
    }
    
    
    // MARK: - Transformations Tests

    func test_loadTransformations_shouldReturn_15_Transformations() throws {
        // Given
        let heroIDTransformation = "D13A40E5-4418-4223-9CE6-D2F9A28EBE94"
        let expectedToken = "Some Token"
        let expectedTransformation = try MockData.mockTransformations().first!
        var transformationResponse = [ApiTransformation]()
        
        // URLProtocolMock handler for loading transformations
        URLProtocolMock.handler = { request in
            let expectedUrl = try XCTUnwrap(URL(string: "https://dragonball.keepcoding.education/api/heros/tranformations"))
            
            XCTAssertEqual(request.httpMethod, "POST")
            XCTAssertEqual(request.url?.absoluteString, expectedUrl.absoluteString)
            XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer \(expectedToken)")
            
            // Return transformations data and response
            let data = try MockData.loadTransformationData()
            let response = HTTPURLResponse(url: expectedUrl, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (data, response)
        }
        
        // When
        let expectation = expectation(description: "Load Transformations")
        setToken(expectedToken)
        
        // Call loadTransformations
        sut.loadTransformations(id: heroIDTransformation) { result in
            switch result {
            case .success(let apitransformation):
                transformationResponse = apitransformation
                expectation.fulfill()
            case .failure(_):
                XCTFail("Success expected")
            }
        }
        
        // Then
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(transformationResponse.count, 15)
        let transformationRecived = transformationResponse.first
        XCTAssertEqual(transformationRecived?.id, expectedTransformation.id)
        XCTAssertEqual(transformationRecived?.name, expectedTransformation.name)
        XCTAssertEqual(transformationRecived?.description, expectedTransformation.description)
        XCTAssertEqual(transformationRecived?.photo, expectedTransformation.photo)
    }
    
    
    func test_loadTransformationsError_shouldReturn_Error() throws {
        // Given
        let expectedToken = "Some Token"
        var error: GAError?
        URLProtocolMock.error = NSError(domain: "ios.Keepcoding", code: 503)
        
        // When
        let expectation = expectation(description: "Load Transformations Error")
        setToken(expectedToken)
        
        // Call loadTransformations expecting an error
        sut.loadTransformations(id: "D13A40E5-4418-4223-9CE6-D2F9A28EBE94") { result in
            switch result {
            case .success(_):
                XCTFail("Error expected")
            case .failure(let receivedError):
                error = receivedError
                expectation.fulfill()
            }
        }
        
        // Then
        wait(for: [expectation], timeout: 2)
        let receivedError = try XCTUnwrap(error)
        XCTAssertEqual(receivedError.description, "Received error from server with code 503")
    }

    
    // MARK: - Locations Tests

    func test_loadLocations_shouldReturn_Locations() throws {
        // Given
        let heroID = "D88BE50B-913D-4EA8-AC42-04D3AF1434E3"
        let expectedToken = "Some Token"
        let expectedLocation = try MockData.mockLocations().first!
        var locationsResponse = [ApiLocation]()
        
        // URLProtocolMock handler for loading locations
        URLProtocolMock.handler = { request in
            let expectedUrl = try XCTUnwrap(URL(string: "https://dragonball.keepcoding.education/api/heros/locations"))
            
            XCTAssertEqual(request.httpMethod, "POST")
            XCTAssertEqual(request.url?.absoluteString, expectedUrl.absoluteString)
            XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer \(expectedToken)")
            
            // Return locations data and response
            let data = try MockData.loadLocationData()
            let response = HTTPURLResponse(url: expectedUrl, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (data, response)
        }
        
        // When
        let expectation = expectation(description: "Load Locations")
        setToken(expectedToken)
        
        // Call loadLocations
        sut.loadLocations(id: heroID) { result in
            switch result {
            case .success(let apiLocations):
                locationsResponse = apiLocations
                expectation.fulfill()
            case .failure(_):
                XCTFail("Success expected")
            }
        }
        
        // Then
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(locationsResponse.count, 2)
        let locationReceived = locationsResponse.first
        XCTAssertEqual(locationReceived?.id, expectedLocation.id)
        XCTAssertEqual(locationReceived?.date, expectedLocation.date)
        XCTAssertEqual(locationReceived?.latitude, expectedLocation.latitude)
        XCTAssertEqual(locationReceived?.longitude, expectedLocation.longitude)
        XCTAssertEqual(locationReceived?.hero?.id, expectedLocation.hero?.id)
    }


    func test_loadLocationsError_shouldReturn_Error() throws {
        // Given
        let expectedToken = "Some Token"
        var error: GAError?
        URLProtocolMock.error = NSError(domain: "ios.Keepcoding", code: 503)
        
        // When
        let expectation = expectation(description: "Load Locations Error")
        setToken(expectedToken)
        
        // Call loadLocations expecting an error
        sut.loadLocations(id: "D13A40E5-4418-4223-9CE6-D2F9A28EBE94") { result in
            switch result {
            case .success(_):
                XCTFail("Error expected")
            case .failure(let receivedError):
                error = receivedError
                expectation.fulfill()
            }
        }
        
        // Then
        wait(for: [expectation], timeout: 2)
        let receivedError = try XCTUnwrap(error)
        XCTAssertEqual(receivedError.description, "Received error from server with code 503")
    }
    
}
