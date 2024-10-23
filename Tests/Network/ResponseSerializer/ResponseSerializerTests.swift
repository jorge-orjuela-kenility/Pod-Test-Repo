//
// Created by TruVideo on 18/06/24.
// Copyright © 2024 TruVideo. All rights reserved.
//

import TruvideoSdkFoundationTesting
import XCTest

@testable import TruvideoSdkFoundation

final class ResponseSerializerTests: XCTestCase {
    // MARK: Tests
    
    func testThatSerializerShouldSucceed() async throws {
        // Given
        let response = URLResponse(
            url: URL(string: "example.com")!,
            statusCode: 0,
            data: createMediaResponse.data(using: .utf8)
        )
        let sut = DecodableResponseSerializer<MediaDTO>()
        
        // When
        let result = try sut.serialize(
            response: response,
            data: response.data,
            error: nil
        )
        
        // Then
        XCTAssertEqual(result.id, "effc5a2f-72ce-4ab2-8329-bc034211747d")
        XCTAssertEqual(
            result.url.absoluteString,
            "https://sdk-mobile-beta.s3.us-west-2.amazonaws.com/media/FD4DAF1A-A2AA-2020-JSJS-3FB7B4A7A2EA.mp4"
        )
    }
    
    func testThatSerializerShouldReturnEmptyData() async throws {
        // Given
        let response = URLResponse(
            url: URL(string: "example.com")!,
            statusCode: 205,
            data: createMediaResponse.data(using: .utf8)
        )

        let sut = DecodableResponseSerializer<Empty>()
        
        // When
        let result = try sut.serialize(response: response, data: nil, error: nil)
        
        // Then
        XCTAssertNotNil(result)
    }
    
    func testThatSerializerShouldFailWithDataInSerialization() async throws {
        // Given
        var expectedError: TruVideoFoundationError!
        let errorDescription = "The data couldn’t be read because it isn’t in the correct format."
        let response = URLResponse(
            url: URL(string: "example.com")!,
            statusCode: 204,
            data: createMediaResponse.data(using: .utf8)
        )
        let sut = DecodableResponseSerializer<String>()
        
        // When
        do {
            _ = try sut.serialize(response: response, data: response.data, error: nil)
        } catch let error as TruVideoFoundationError {
            expectedError = error
        }
    
        // Then
        XCTAssertEqual(expectedError?.kind, ErrorReason.NetworkErrorReason.responseSerializationFailed)
        XCTAssertEqual(expectedError.underlyingError?.localizedDescription, errorDescription)
        XCTAssertEqual(expectedError.errorDescription, errorDescription)
    }
    
    func testThatSerializerShouldFailWithEmptyDataAndInvalidType() async throws {
        // Given
        var expectedError: TruVideoFoundationError!
        let response = URLResponse(
            url: URL(string: "example.com")!,
            statusCode: 205,
            data: nil
        )
        
        let sut = DecodableResponseSerializer<String>()
        
        // When
        do {
            _ = try sut.serialize(response: response, data: nil, error: nil)
        } catch let error as TruVideoFoundationError {
            expectedError = error
        }
        
        // Then
        XCTAssertEqual(expectedError.kind, ErrorReason.NetworkErrorReason.responseSerializationFailed)
        XCTAssertEqual(
            expectedError.failureReason,
            "Invalid empty type String."
        )
    }
    
    func testThatSerializerShouldFailWithEmptyDataAndInvalidEmptyStatusCode() async throws {
        // Given
        var expectedError: TruVideoFoundationError!
        let response = URLResponse(
            url: URL(string: "example.com")!,
            statusCode: 0,
            data: nil
        )

        let sut = DecodableResponseSerializer<MediaDTO>()
        
        // When
        do {
            _ = try sut.serialize(response: response, data: response.data, error: nil)
        } catch let error as TruVideoFoundationError {
            expectedError = error
        }
        
        // Then
        XCTAssertEqual(expectedError.kind, ErrorReason.NetworkErrorReason.responseSerializationFailed)
        XCTAssertEqual(
            expectedError.failureReason,
            "Status code Optional(0), is not a valid code for an empty response."
        )
    }
    
    func testThatSerializerShouldFailWhenAnErrorIsReceived() async throws {
        // Given
        var expectedError: Error!
        let response = URLResponse(
            url: URL(string: "example.com")!,
            statusCode: 0,
            data: nil
        )

        let sut = DecodableResponseSerializer<MediaDTO>()
        
        // When
        do {
            _ = try sut.serialize(
                response: response,
                data: response.data,
                error: NSError(domain: "error", code: 100)
            )
        } catch let error {
            expectedError = error
        }
        
        // Then
        XCTAssertNotNil(expectedError)
    }
}

// MARK: Helper

private struct MediaDTO: Decodable {
    let id: String
    
    let createdDate: String
    
    let url: URL
}

