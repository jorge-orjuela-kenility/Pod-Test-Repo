//
// Created by TruVideo on 18/06/24.
// Copyright © 2024 TruVideo. All rights reserved.
//

import TruvideoSdkFoundationTesting
import XCTest

@testable import TruvideoSdkFoundation

final class TokenProviderTests: XCTestCase {
    // MARK: Test
    
    func testThatRetrieveTokenShouldSucceed() {
        // Given
        let authService = AuthServiceMock()
        let sut = BearerTokenTokenProvider(authService: authService)
        
        // When
        authService.authentication = .init(id: "", accessToken: "test", refreshToken: "")

        let result = sut.retrieveToken()
        
        // Then
        XCTAssertEqual(result, "test")
    }
    
    func testThatRetrieveTokenShouldReturnNil() {
        // Given
        let authService = AuthServiceMock()
        let sut = BearerTokenTokenProvider(authService: authService)
        
        // When
        let result = sut.retrieveToken()
        
        // Then
        XCTAssertNil(result)
    }
}
