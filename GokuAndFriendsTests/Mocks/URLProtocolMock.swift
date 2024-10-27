

import Foundation

/// Mock class for `URLProtocol` to be used in `URLSession` for API testing.
/// This allows testing the app code with mock API responses and errors.
/// Reference: WWDC 2018, video [https://developer.apple.com/videos/play/wwdc2018/417]
class URLProtocolMock: URLProtocol {
    
    /// Error to be returned in the test if any
    static var error: Error?
    
    /// Handler to provide custom `Data` and `HTTPURLResponse` for the request, used in the tests
    static var handler: ((URLRequest) throws -> (Data, HTTPURLResponse))?
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        // If an error is set, send it to the client
        if let error = Self.error {
            client?.urlProtocol(self, didFailWithError: error)
            return
        }
        
        // If neither error nor handler is provided, trigger a fatal error as one of these is required
        guard let handler = Self.handler else {
            fatalError("No Error or handler provided")
        }
        
        do {
            // Passes `Data` and `HTTPURLResponse` to the client, received from the handler
            let (data, response) = try handler(self.request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }
    
    override func stopLoading() {}
}
