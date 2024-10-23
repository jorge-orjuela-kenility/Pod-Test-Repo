//
// Created by TruVideo on 18/06/24.
// Copyright © 2024 Truvideo. All rights reserved.
//

import Foundation

@_implementationOnly import shared

/// A mock implementation of the `HttpService` protocol for testing purposes.
final class HTTPServiceMock: HttpService {
    /// A list of parameters passed in the body of the POST request.
    public var bodyParameters: [Any?] = []
    
    /// An optional error that can be set to simulate error scenarios.
    public var error: Error?
    
    /// The number of times the `get` method has been called.
    public var getCallCount = 0
    
    /// A dictionary of headers passed in the request.
    public var headers: [String: String] = [:]
    
    /// The number of times the `head` method has been called.
    public var headCallCount = 0
    
    /// The number of times the `post` method has been called.
    public var postCallCount = 0
    
    /// A flag indicating whether the request is successful.
    public var isSuccess = true
    
    // MARK: Initializer
    
    /// Creates a new instance of `HTTPServiceMock`.
    public init() {}

    // MARK: HttpService
    
    /// Simulates a GET request.
    ///
    /// - Parameters:
    ///   - url: The URL to send the request to.
    ///   - headers: The headers for the request.
    ///   - retry: A flag indicating whether the request should be retried.
    /// - Returns: A `TruvideoSdkHttpResponse` instance with the mock response.
    /// - Throws: An error if the operation fails.
    public func get(url: String, headers: [String : String], retry: Bool) async throws -> TruvideoSdkHttpResponse? {
        getCallCount += 1
        self.headers = headers
        
        if let error {
            throw error
        }
        
        return .init(code: 1, body: "", isSuccess: self.isSuccess)
    }
    
    /// Simulates a HEAD request.
    ///
    /// - Parameters:
    ///   - url: The URL to send the request to.
    ///   - retry: A flag indicating whether the request should be retried.
    /// - Returns: A `TruvideoSdkHttpResponse` instance with the mock response.
    /// - Throws: An error if the operation fails.
    public func head(url: String, retry: Bool) async throws -> TruvideoSdkHttpResponse? {
        headCallCount += 1
        
        if let error {
            throw error
        }
        
        return .init(code: 1, body: "", isSuccess: self.isSuccess)
    }
    
    /// Simulates a POST request.
    ///
    /// - Parameters:
    ///   - url: The URL to send the request to.
    ///   - headers: The headers for the request.
    ///   - body: The body of the request.
    ///   - retry: A flag indicating whether the request should be retried.
    /// - Returns: A `TruvideoSdkHttpResponse` instance with the mock response.
    /// - Throws: An error if the operation fails.
    public func post(
        url: String,
        headers: [String : String],
        body: Any?,
        retry: Bool
    ) async throws -> TruvideoSdkHttpResponse? {
        bodyParameters = [body]
        postCallCount += 1
        self.headers = headers
        
        
        if let error {
            throw error
        }
        
        return .init(code: 1, body: "", isSuccess: self.isSuccess)
    }
}
