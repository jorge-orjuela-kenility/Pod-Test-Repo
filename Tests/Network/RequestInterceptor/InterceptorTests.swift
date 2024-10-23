//
// Created by TruVideo on 18/06/24.
// Copyright © 2024 TruVideo. All rights reserved.
//

import TruvideoSdkFoundationTesting
import XCTest

@testable import TruvideoSdkFoundation

final class InterceptorTests: XCTestCase {
    // MARK: Tests

    func testThatInterceptShouldSucceed() async {
        // Given
        let url = URL(string: "https://httpbin.org")!
        let httpClient = HTTPClientMock()
        let interceptors = [RequestInterceptorMock(), .init(body: "string")]
        let sut = Interceptor(interceptors: interceptors)
        let mockDataTask: @Sendable () async throws -> TruvideoSdkFoundation.URLResponse? = {
            URLResponse(url: url, statusCode: 1, data: nil)
        }
        
        let request = Request(
            id: UUID(),
            url: url,
            requestInterceptor: RequestInterceptorMock(),
            dataTask: mockDataTask
        )
        
        // When
        let interceptedRequest = try! await sut.intercept(request, client: httpClient)
        let interceptedUrl = await interceptedRequest.url
        let interceptedInterceptor = await interceptedRequest.requestInterceptor

        // Then
        XCTAssertEqual(interceptedUrl, url)
        XCTAssertNotNil(interceptedInterceptor)
    }
}
