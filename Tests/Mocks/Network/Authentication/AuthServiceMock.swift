//
// Created by TruVideo on 09/10/24.
// Copyright © 2024 TruVideo. All rights reserved.
//

import Foundation
import shared

/// A mock implementation of `AuthService` for testing purposes.
///
/// This class simulates an authentication service by providing mock behavior
/// for methods such as token refresh, payload generation, and authentication handling.
class AuthServiceMock: AuthService {
    // MARK: - Properties
    
    /// The API key used for authentication.
    public var apiKey: String = ""
    
    /// The current authentication state containing access and refresh tokens.
    public var authentication: TruvideoSdkAuthentication?
    
    /// An optional error to simulate failures during service calls.
    public var error: Error?

    /// Indicates whether the user is currently authenticated.
    public var isAuthenticated: Bool = true
    
    /// Indicates whether the authentication token has expired.
    public var isAuthenticationExpired: Bool = false
    
    /// Indicates if the token is within the valid time period.
    public var isInValidPeriod: Bool = false
    
    /// Indicates whether the service has been successfully initialized.
    public var isInitialized_: Bool = true
    
    /// Holds the current SDK settings.
    public var settings: TruvideoSdkSettings?
    
    /// A simulated payload string returned by `generatePayload()`.
    public var payload: String = ""
    
    /// Tracks how many times `authenticate` has been called.
    public var authenticateCallCount = 0
    
    /// Tracks how many times `clear()` has been called.
    public var clearCallCount = 0
    
    /// Tracks how many times `generatePayload()` has been called.
    public var generatePayloadCallCount = 0
    
    /// Tracks how many times `doInit(accessTokenTTL:refreshTokenTTL:)` has been called.
    public var doInitCallCount = 0
    
    /// Tracks how many times `refresh(accessTokenTTL:refreshTokenTTL:)` has been called.
    public var refreshTokenCallCount = 0

    // MARK: Initializer
    
    public init() {}

    // MARK: Methods

    public func authenticate(apiKey: String, payload: String, signature: String, accessTokenTTL: KotlinLong?, refreshTokenTTL: KotlinLong?, externalId: String?) async throws {
        authenticateCallCount += 1

        if apiKey != "validKey" {
            throw MockError.invalidApiKey
        }

        self.isAuthenticated = true
    }
    
    public func clear() {
        clearCallCount += 1

        self.apiKey = ""
        self.authentication = nil
        self.isAuthenticated = false
        self.isAuthenticationExpired = false
        self.isInValidPeriod = false
    }
    
    public func generatePayload() -> String {
        generatePayloadCallCount += 1

        return payload
    }
    
    public func doInit(accessTokenTTL: KotlinLong?, refreshTokenTTL: KotlinLong?) async throws {
        doInitCallCount += 1

        if !isInitialized_ {
            throw MockError.initializationFailed
        }
    }
    
    public func refresh(accessTokenTTL: KotlinLong?, refreshTokenTTL: KotlinLong?) async throws {
        refreshTokenCallCount += 1
        
        if let error = error {
            throw error
        }
        
        try? await Task.sleep(nanoseconds: 1_000_000_000)
    }
}

enum MockError: Error {
    case invalidApiKey
    case initializationFailed
    case refreshFailed
}
