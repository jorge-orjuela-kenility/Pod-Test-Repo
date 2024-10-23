//
// Created by TruVideo on 18/06/24.
// Copyright © 2024 TruVideo. All rights reserved.
//

import TruvideoSdkFoundationTesting
import XCTest

@testable import TruvideoSdkFoundation

final class HTTPApiClientTests: XCTestCase {

    // MARK: Tests
    
    func testThatAuthenticatedShouldSucceed() async throws {
        // Given
        let httpService = HTTPServiceMock()
        let tokenProvider = TokenProviderMock(authToken: "authToken")
        let sut = HTTPApiClient(
            url: "www.example.com",
            httpService: httpService,
            tokenProvider: tokenProvider,
            requestInterceptor: nil
        )
        
        // When
        _ = try await sut.authenticated()
        
        // Then
        XCTAssertEqual(tokenProvider.retrieveTokenCallCount, 1)
    }
    
    func testThatAuthenticatedShouldFailed() async throws {
        // Given
        var expectedError: TruVideoFoundationError!
        let httpService = HTTPServiceMock()
        let tokenProvider = TokenProviderMock(authToken: "authToken")
        let sut = HTTPApiClient(
            url: "www.example.com",
            httpService: httpService,
            tokenProvider: tokenProvider,
            requestInterceptor: nil
        )
        
        // When
        tokenProvider.error = NSError(domain: "", code: 1)

        do {
            _ = try await sut.authenticated()
        } catch let error as TruVideoFoundationError {
            expectedError = error
        }
        
        // Then
        XCTAssertEqual(expectedError.kind, ErrorReason.NetworkErrorReason.authenticationTokenNotFound)
        XCTAssertEqual(tokenProvider.retrieveTokenCallCount, 1)
    }
    
    func testThatGetShouldSucceed() async throws {
        // Given
        let parameters = ["get":"foo"]
        let headers = ["foo" : "foo"]
        let httpService = HTTPServiceMock()
        let tokenProvider = TokenProviderMock(authToken: "authToken")
        let sut = HTTPApiClient(
            url: "www.example.com",
            httpService: httpService,
            tokenProvider: tokenProvider,
            requestInterceptor: nil
        )
        
        // When
        _ = try await sut.get("get", parameters: parameters, headers: headers)
            .serializingResponse(of: Empty.self)
        
        // Then
        XCTAssertEqual(httpService.getCallCount, 1)
        XCTAssertEqual(httpService.headers, headers)
    }
    
    func testThatGetShouldSucceedWithoutParametersAndHeaders() async throws {
        // Given
        let httpService = HTTPServiceMock()
        let tokenProvider = TokenProviderMock(authToken: "authToken")
        let sut = HTTPApiClient(
            url: "www.example.com",
            httpService: httpService,
            tokenProvider: tokenProvider,
            requestInterceptor: nil
        )
        
        // When
        _ = try await sut.get("get")
            .serializingResponse(of: Empty.self)
        
        // Then
        XCTAssertEqual(httpService.getCallCount, 1)
    }
    
    func testThatGetShouldSucceedWithARequestInterceptor() async throws {
        // Given
        let parameters = ["get":"foo"]
        let headers = ["foo" : "foo"]
        let httpService = HTTPServiceMock()
        let tokenProvider = TokenProviderMock(authToken: "authToken")
        let requestInterceptor = RequestInterceptorMock()
        let sut = HTTPApiClient(
            url: "www.example.com",
            httpService: httpService,
            tokenProvider: tokenProvider,
            requestInterceptor: requestInterceptor
        )
        
        // When
        _ = try await sut.get("/get", parameters: parameters, headers: headers)
            .serializingResponse(of: Empty.self)
        
        // Then
        XCTAssertEqual(httpService.getCallCount, 1)
        XCTAssertEqual(httpService.headers, headers)
        XCTAssertEqual(requestInterceptor.interceptCallCount, 1)
    }
    
    func testThatGetShouldFailOnRequestInterceptorError() async throws {
        // Given
        var expectedError: TruVideoFoundationError!
        let parameters = ["get":"foo"]
        let headers = ["foo" : "foo"]
        let httpService = HTTPServiceMock()
        let tokenProvider = TokenProviderMock(authToken: "authToken")
        let requestInterceptor = RequestInterceptorMock()
        let sut = HTTPApiClient(
            url: "www.example.com",
            httpService: httpService,
            tokenProvider: tokenProvider,
            requestInterceptor: requestInterceptor
        )
        
        // When
        requestInterceptor.error = NSError(domain: "", code: 0)
        
        do {
            _ = try await sut.get("get", parameters: parameters, headers: headers)
        } catch let error as TruVideoFoundationError {
            expectedError = error
        }
        
        // Then
        XCTAssertEqual(expectedError.kind, ErrorReason.NetworkErrorReason.interceptionFailed)
        XCTAssertEqual(expectedError.errorDescription, "The operation couldn’t be completed. ( error 0.)")
        XCTAssertEqual(requestInterceptor.interceptCallCount, 1)
    }
    
    func testThatPostShouldSucceed() async throws {
        // Given
        let headers = ["foo" : "foo"]
        let httpService = HTTPServiceMock()
        let tokenProvider = TokenProviderMock(authToken: "authToken")
        let sut = HTTPApiClient(
            url: "www.example.com",
            httpService: httpService,
            tokenProvider: tokenProvider,
            requestInterceptor: nil
        )
        
        // When
        _ = try await sut.post("post", parameters: ["post":"foo"], encoder: JSONStringEncoder(), headers: headers)
            .serializingResponse(of: Empty.self)
        
        // Then
        XCTAssertEqual(httpService.postCallCount, 1)
        XCTAssertEqual(httpService.headers["foo"], "foo")
    }
    
    func testThatPostShouldSucceedWithDefaultEncoder() async throws {
        // Given
        let headers = ["foo" : "foo"]
        let httpService = HTTPServiceMock()
        let tokenProvider = TokenProviderMock(authToken: "authToken")
        let sut = HTTPApiClient(
            url: "www.example.com",
            httpService: httpService,
            tokenProvider: tokenProvider,
            requestInterceptor: nil
        )
        
        // When
        _ = try await sut.post("post", parameters: ["post":"foo"], headers: headers)
            .serializingResponse(of: Empty.self)
        
        // Then
        XCTAssertEqual(httpService.postCallCount, 1)
        XCTAssertEqual(httpService.headers["foo"], "foo")
    }
}
