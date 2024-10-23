//
// Created by TruVideo on 18/06/24.
// Copyright © 2024 TruVideo. All rights reserved.
//

import Foundation

@_implementationOnly import shared

/// A protocol that defines the interface for refreshing authentication tokens.
///
/// The `TokenRefresher` protocol specifies a method for sending a request to the provider to refresh an authentication token.
protocol TokenRefresher {
    /// Send a request to the provider to refresh the token.
    ///
    /// - Returns: The new token or nil otherwise.
    /// - Throws: An error if something fails.
    func refreshToken() async throws
}

/// A custom implementation of the `TokenRefresher` that allows 1 request per refresh.
actor BearerTokenRefresher: TokenRefresher {
    // MARK: Private Properties

    private let authService: AuthService
    private var task: Task<Void, Error>?

    // MARK: Initializer

    /// Initializes a new instance of `BearerTokenTokenProvider` with the
    /// specified authentication service.
    ///
    /// - Parameter authService: The  authentication service used for token retrieval.
    init(authService: AuthService) {
        self.authService = authService
    }

    // MARK: TokenRefresher

    /// Send a request to the provider to refresh the token.
    ///
    /// - Returns: The new token or nil otherwise.
    /// - Throws: An error if something fails.
    func refreshToken() async throws {
        guard let task else {
            let task = Task<Void, Error> {
                defer { self.task = nil }

                try await authService.refresh(accessTokenTTL: nil, refreshTokenTTL: nil)
            }

            self.task = task
            try await task.value
            
            return
        }

        try await task.value
    }
}
