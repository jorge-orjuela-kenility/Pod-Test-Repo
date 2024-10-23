//
// Created by TruVideo on 18/06/24.
// Copyright © 2024 TruVideo. All rights reserved.
//

import TruvideoSdkFoundationTesting
import XCTest

@testable import TruvideoSdkFoundation

final class AuthenticationValidatorInterceptorTests: XCTestCase {
    // MARK: Private Properties

    private let client = HTTPClientMock()
    private let url = URL(string: "https://httpbin.org")!
    private lazy var request: Request = {
        Request(url: url, requestInterceptor: nil) {
            URLResponse(url: self.url, statusCode: 1, data: nil)
        }
    }()

    // MARK: Tests
    
    func testThatInterceptShouldSucceed() async {
        // Given
        let authService = AuthServiceMock()
        let sut = AuthenticationValidatorInterceptor(authService: authService)
        
        // When
        let interceptedRequest = try! await sut.intercept(request, client: client)
        let interceptedUrl = await interceptedRequest.url
        
        // Then
        XCTAssertEqual(interceptedUrl, url)
    }
    
    func testThatInterceptShouldFailedWhenUserNoIsAuthenticated() async {
        // Given
        var expectedError: TruVideoFoundationError?
        let authService = AuthServiceMock()
        let sut = AuthenticationValidatorInterceptor(authService: authService)

        // When
        authService.isAuthenticated = false
        
        do {
           _ = try await sut.intercept(request, client: client)
        } catch {
            expectedError = error as? TruVideoFoundationError
        }
        
        // Then
        XCTAssertEqual(expectedError?.kind, ErrorReason.NetworkErrorReason.authenticationTokenNotFound)
    }
}
