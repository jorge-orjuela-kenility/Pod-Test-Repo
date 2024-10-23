//
// Created by TruVideo on 18/06/24.
// Copyright © 2024 Truvideo. All rights reserved.
//

import Foundation

@testable import TruvideoSdkFoundation

@_implementationOnly import shared

// Mock class for RequestInterceptor
final class RequestInterceptorMock: RequestInterceptor {
    /// The body of the response returned by the mock.
    public var body: String
    
    /// An optional error that can be set to simulate error scenarios.
    public var error: Error?
    
    /// The number of times the `intercept` method has been called.
    public var interceptCallCount = 0
    
    /// The base URL used for the requests.
    public let url = URL(string: "https://any-url.com/")!
    
    // MARK: Initializer
    
    /// Creates a new instance of `RequestInterceptorMock` with the specified body.
    ///
    /// - Parameters:
    ///    - body: The body of the response returned by the mock.
    public init(body: String = "") {
        self.body = body
    }
    
    /// Function to intercept the request and return a mock request.
    public func intercept(_ request: Request, client: HTTPClient) async throws -> Request {
        interceptCallCount += 1
        
        if let error {
            throw error
        }
        
        return request
    }
}
