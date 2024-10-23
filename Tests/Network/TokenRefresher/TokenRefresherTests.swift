//
// Created by TruVideo on 18/06/24.
// Copyright © 2024 TruVideo. All rights reserved.
//

import TruvideoSdkFoundationTesting
import XCTest

@testable import TruvideoSdkFoundation

final class TokenRefresherTests: XCTestCase {
    // MARK: Tests

    func testThatRetryShouldRefreshOnceOnMultipleCalls() async throws {
        // Given
        let authService = AuthServiceMock()
        let sut = BearerTokenRefresher(authService: authService)

        // When
        for _ in 0..<5 {
            Task {
                try await sut.refreshToken()
            }
        }

        try await sut.refreshToken()

        // Then
        XCTAssertEqual(authService.refreshTokenCallCount, 1)
    }
}
