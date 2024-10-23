//
// Created by TruVideo on 18/06/24.
// Copyright © 2024 TruVideo. All rights reserved.
//

import XCTest

@testable import TruvideoSdkFoundation

final class ParameterEncoderTests: XCTestCase {

    // MARK: Tests
    
    func testThatEncodeShouldSucceed() async throws {
        // Given
        let parameters = ["get":"foo"]
        var headers = ["":""]
        let sut = JSONStringEncoder()
        
        // When
        let result = try sut.encode(parameters, headers: &headers)
        
        // Then
        XCTAssertEqual(result, "{\n  \"get\" : \"foo\"\n}")
        XCTAssertEqual(headers["Content-Type"], "application/json")
    }
    
    func testThatEncodeShouldSucceedWithNilParameters() async throws {
        // Given
        var headers = ["":""]
        let sut = JSONStringEncoder()
        
        // When
        let result = try sut.encode(nil as String?, headers: &headers)
        
        // Then
        XCTAssertEqual(result, "")
        XCTAssertNil(headers["Content-Type"])
    }
    
    func testThatEncodeShouldFailOnEncode() async throws {
        // Given
        var expectedError: TruVideoFoundationError!
        let parameters = [Double.nan:"foo"]
        var headers = ["":""]
        let sut = JSONStringEncoder()
        
        // When
        do {
            _ = try sut.encode(parameters, headers: &headers)
        } catch let error as TruVideoFoundationError {
            expectedError = error
        }
        
        // Then
        XCTAssertEqual(expectedError.kind, ErrorReason.NetworkErrorReason.parameterEncodingFailed)
        XCTAssertNil(headers["Content-Type"])
    }
}
