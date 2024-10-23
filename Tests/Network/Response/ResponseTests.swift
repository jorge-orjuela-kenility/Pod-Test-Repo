//
// Created by TruVideo on 18/06/24.
// Copyright © 2024 TruVideo. All rights reserved.
//

import XCTest

@testable import TruvideoSdkFoundation

final class ResponseTests: XCTestCase {

    // MARK: Tests
    
    func testThatGetShouldSucceed() async throws {
        // Given
        let data = "{}".data(using: .utf8)
        let url = URL(string: "www.example.com")!
        let response = URLResponse(url: url, statusCode: 0, data: data)
        let result: Result<String, TruVideoFoundationError> = .success("Success")
        let sut = Response(response: response, result: result)
        
        // When
        let value = try await sut.get()
        
        // Then
        XCTAssertEqual(value, "Success")
        XCTAssertEqual(sut.response, response)
        XCTAssertEqual(sut.value, "Success")
        XCTAssertNil(sut.error)
        XCTAssertEqual(sut.description, "success(\"Success\")")
        XCTAssertEqual(sut.debugDescription, "[Response]:\n        [Status Code]: 0\n        [Body]: {}\n[Result]: success(\"Success\")")
    }
    
    func testThatGetShouldFail() async throws {
        // Given
        var expectedError: TruVideoFoundationError!
        let error = TruVideoFoundationError(kind: .unknown)
        let data = "{}".data(using: .utf8)
        let url = URL(string: "www.example.com")!
        let response = URLResponse(url: url, statusCode: 0, data: data)
        let result: Result<String, TruVideoFoundationError> = .failure(error)
        let sut = Response(response: response, result: result)
        
        // When
        do {
            _ = try await sut.get()
        } catch let error as TruVideoFoundationError {
            expectedError = error
        }
        
        
        // Then
        XCTAssertEqual(expectedError.kind, error.kind)
        XCTAssertEqual(sut.response, response)
        XCTAssertEqual(sut.value, nil)
        XCTAssertNotNil(sut.error)
        XCTAssertEqual(sut.description, """
                       failure(TruvideoSdkFoundation.TruVideoFoundationError(column: 44, failureReason: nil, line: 37, kind: TruvideoSdkFoundation.ErrorReason(rawValue: \"com.truVideo.foundation.unknownError\"), underlyingError: nil))
                       """)
        XCTAssertEqual(sut.debugDescription, "[Response]:\n        [Status Code]: 0\n        [Body]: {}\n[Result]: failure(TruvideoSdkFoundation.TruVideoFoundationError(column: 44, failureReason: nil, line: 37, kind: TruvideoSdkFoundation.ErrorReason(rawValue: \"com.truVideo.foundation.unknownError\"), underlyingError: nil))")
    }
}
