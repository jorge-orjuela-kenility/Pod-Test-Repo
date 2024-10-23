//
// Created by TruVideo on 18/06/24.
// Copyright © 2024 TruVideo. All rights reserved.
//

import Foundation

@_implementationOnly import shared

/// Provides an abstraction for access token retrieval.
public protocol TokenProvider {
    /// Retrieves the current access token available in the session
    /// returns null when no session is active at the moment.
    ///
    /// - Returns: The existing auth token otherwise nil.
    func retrieveToken() -> String?
}

/// A token provider implementation that retrieves JWT tokens.
public struct BearerTokenTokenProvider: TokenProvider {
    // MARK: Private Properties

    private let authService: AuthService
    
    // MARK: Initializer
    
    /// Initializes a new instance of `BearerTokenTokenProvider` with the
    /// specified authentication service.
    ///
    /// - Parameter authService: The  authentication service used for token retrieval.
    init(authService: AuthService) {
        self.authService = authService
    }
    
    // MARK: TokenProvider
    
    /// Retrieves the current access token available in the session
    /// returns null when no session is active at the moment.
    ///
    /// - Returns: The existing auth token otherwise nil.
    public func retrieveToken() -> String? {
        guard let authentication = authService.authentication else {
            return nil
        }
        
        return authentication.accessToken
    }
}
