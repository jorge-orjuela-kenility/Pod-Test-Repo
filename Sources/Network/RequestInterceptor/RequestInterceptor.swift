//
// Created by TruVideo on 18/06/24.
// Copyright © 2024 TruVideo. All rights reserved.
//

import Foundation

@_implementationOnly import shared

/// A type that determines whether a request should be intercepted.
public protocol RequestInterceptor {
    /// Inspects and adapts the specified `Request` in some
    /// manner and returns the Result.
    ///
    /// - Parameters:
    ///   - request: The `Request` tha has been intercepted.
    ///   - client: The `HTTPClient` that will execute the `Request`.
    /// - Throws: An error if something went wrong.
    func intercept(_ request: Request, client: HTTPClient) async throws -> Request
}

/// An interceptor that refreshes the authentication token before allowing the request to proceed.
///
/// The `RefreshTokenInterceptor` uses an `AuthService` to refresh the token if needed. It can be used
/// to ensure that the request has a valid token before being executed.
public struct AuthenticationValidatorInterceptor: RequestInterceptor {
    // MARK: Private Properties

    private let authService: AuthService
    
    // MARK: Initializer
    
    /// Creates a new instance of the `AuthenticationInterceptor`.
    ///
    /// - Parameter authService: The  authentication service used for token refreshal.
    init(authService: AuthService) {
        self.authService = authService
    }
    
    // MARK: RequestInterceptor
    
    /// Inspects and adapts the specified `Request` in some
    /// manner and returns the Result.
    ///
    /// - Parameters:
    ///   - request: The `Request` tha has been intercepted.
    ///   - client: The `HTTPClient` that will execute the `Request`.
    /// - Throws: An error if something went wrong.
    ///
    /// > Note:
    ///
    ///     This class needs to be marked as a `@MainActor` due to the Kotlin library dependency;
    ///     otherwise, it will throw a crash.
    public func intercept(_ request: Request, client: HTTPClient) async throws -> Request {
        guard authService.isAuthenticated else {
            throw TruVideoFoundationError(
                kind: .NetworkErrorReason.authenticationTokenNotFound,
                failureReason: "User is not authenticated"
            )
        }
        
        return request
    }
}

/// A request interceptor that handles authentication by inspecting and adapting HTTP requests
/// to ensure that they are authenticated. This interceptor works in conjunction with an
/// `AuthService` to check if the user is authenticated before allowing the request to proceed.
public struct Interceptor: RequestInterceptor {
    // MARK: - Public Properties
    
    /// All `RequestInterceptor`s associated with the instance.
    public let interceptors: [RequestInterceptor]

    // MARK: RequestInterceptor

    /// Inspects and adapts the specified `URLRequest` in some
    /// manner and returns the Result.
    ///
    /// - Parameters:
    ///   - request: The `URLRequest` tha has been intercepted.
    ///   - client: The `HTTPApiClient` that will execute the `URLRequest`.
    /// - Throws: An error if something went wrong.
    public func intercept(_ request: Request, client: HTTPClient) async throws -> Request {
        try await intercept(request, interceptors: interceptors, client: client)
    }

    // MARK: Private methods

    private func intercept(
        _ request: Request,
        interceptors: [RequestInterceptor],
        client: HTTPClient
    ) async throws -> Request {

        var interceptors = interceptors

        guard !interceptors.isEmpty else {
            return request
        }

        let interceptor = interceptors.removeFirst()
        let request = try await interceptor.intercept(request, client: client)

        return try await intercept(request, interceptors: interceptors, client: client)
    }
}

/// An interceptor that refreshes the authentication token before allowing the request to proceed.
///
/// The `RefreshTokenInterceptor` uses an `AuthService` to refresh the token if needed. It can be used
/// to ensure that the request has a valid token before being executed.
final actor RefreshTokenInterceptor: RequestInterceptor {
    // MARK: - Private Properties
    
    private let authService: AuthService
    private var task: Task<Void, Error>?
    
    // MARK: Initializer
    
    /// Creates a new instance of the `RefreshTokenInterceptor`.
    ///
    /// - Parameter authService: The  authentication service used for token refreshal.
    init(authService: AuthService) {
        self.authService = authService
    }
    
    // MARK: RequestInterceptor
    
    /// Inspects and adapts the specified `Request` in some
    /// manner and returns the Result.
    ///
    /// - Parameters:
    ///   - request: The `Request` tha has been intercepted.
    ///   - client: The `HTTPClient` that will execute the `Request`.
    /// - Throws: An error if something went wrong.
    ///
    /// > Note:
    ///
    ///     This class needs to be marked as a `@MainActor` due to the Kotlin library dependency;
    ///     otherwise, it will throw a crash.
    func intercept(_ request: Request, client: HTTPClient) async throws -> Request {
        defer {
            task = nil
        }
        
        guard let task else {
            let task = Task { @MainActor in
                try await authService.refresh(accessTokenTTL: nil, refreshTokenTTL: nil)
            }
            
            self.task = task
            try await task.value
            
            return request
        }
        
        try await task.value
        return request
    }
}
