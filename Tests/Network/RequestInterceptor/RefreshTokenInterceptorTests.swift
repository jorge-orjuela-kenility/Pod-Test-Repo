//
// Created by TruVideo on 18/06/24.
// Copyright © 2024 TruVideo. All rights reserved.
//

import TruvideoSdkFoundationTesting
import XCTest

@testable import TruvideoSdkFoundation

final class RefreshTokenInterceptorTests: XCTestCase {
    // MARK: Private Properties

    private let client = HTTPClientMock()
    private let url = URL(string: "https://httpbin.org")!
    private lazy var request: Request = {
        Request(url: url, requestInterceptor: nil) {
            URLResponse(url: self.url, statusCode: 1, data: nil)
        }
    }()
    
    // MARK: Tests
    
    func testThatInterceptShouldSucceed() async throws {
        // Given
        let authService = AuthServiceMock()
        let sut = RefreshTokenInterceptor(authService: authService)
        
        // When
        let interceptedRequest = try await sut.intercept(request, client: client)
        let interceptedUrl = await interceptedRequest.url
        
        // Then
        XCTAssertEqual(interceptedUrl, url)
    }
    
    func testThatInterceptShouldRefreshTokenOnlyOneTime() async throws {
        // Given
        let authService = AuthServiceMock()
        let sut = RefreshTokenInterceptor(authService: authService)
        
        // When
        Task {
            try await sut.intercept(request, client: client)
        }

        Task {
            try await sut.intercept(request, client: client)
        }
        
        _ = try await sut.intercept(request, client: client)

        // Then
        XCTAssertEqual(authService.refreshTokenCallCount, 1)
    }

}
