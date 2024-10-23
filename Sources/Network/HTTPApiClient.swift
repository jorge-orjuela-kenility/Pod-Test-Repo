//
// Created by TruVideo on 4/10/23.
// Copyright © 2024 TruVideo. All rights reserved.
//

import Foundation
import shared

private extension String {
    /// Returns the ``URL`` representation of the resource using the path component.
    ///
    /// - Parameter path: The path subcomponent.
    /// - Returns: A new instance of the url, otherwise an `Error`.
    func asURL(with path: String) throws -> URL {
        let path = path.starts(with: "/") ? path : "/".appending(path)
                
        guard let url = URL(string: self.appending(path)) else {
            throw TruVideoFoundationError(
                kind: .NetworkErrorReason.invalidURL,
                failureReason: "Invalid or malformed URL: \(self)"
            )
        }
        
        return url
    }
}

private extension URL {
    /// Appends the given query parameters to the URL.
    ///
    /// This method takes a dictionary of query parameters and appends them to the URL.
    /// If the URL cannot be converted to URLComponents, the original URL is returned.
    ///
    /// - Parameter queryParameters: A dictionary containing the query parameters to append to the URL.
    /// - Returns: A new URL with the query parameters appended, or the original URL if the operation fails.
    func appendingQueryParameters(_ queryParameters: [String: String]) -> URL {
        guard var components = URLComponents(string: absoluteString) else {
            return self
        }
        
        components.queryItems = queryParameters.map { URLQueryItem(name: $0, value: $1) }
        
        return components.url ?? self
    }
}

/// A client that handles HTTP requests with optional authentication.
///
/// The `HTTPApiClient` class is responsible for making HTTP requests to a specified URL. It can be authenticated using a token provider
/// to include an authorization header in the requests.
public final class HTTPApiClient: HTTPClient {
    // MARK: - Private Properties
    
    private var headers: [String: String] = [:]
    private let httpService: HttpService
    private let requestInterceptor: RequestInterceptor?
    private let tokenProvider: TokenProvider
    private let url: String
    
    // MARK: Initilizer
    
    /// Initializes a new instance of the `SharedHTTPClient`.
    ///
    /// - Parameters:
    ///   - url: The base URL for the HTTP requests.
    ///   - httpService: The HTTP service responsible for making requests.
    ///   - tokenProvider: The token provider used for retrieving authentication tokens.
    ///   - requestInterceptor: The interceptor to use to modify the request.
    init(
        url: String,
        httpService: HttpService,
        tokenProvider: TokenProvider,
        requestInterceptor: RequestInterceptor?
    ) {
        
        self.httpService = httpService
        self.requestInterceptor = requestInterceptor
        self.tokenProvider = tokenProvider
        self.url = url
    }
    
    /// Initializes a new instance of the `SharedHTTPClient`.
    ///
    /// - Parameters:
    ///   - url: The base URL for the HTTP requests.
    ///   - tokenProvider: The token provider used for retrieving authentication tokens.
    ///   - requestInterceptor: The interceptor to use to modify the request.
    public convenience init(url: String, tokenProvider: TokenProvider, requestInterceptor: RequestInterceptor?) {
        self.init(
            url: url,
            httpService: TruvideoSdkCommonKt.sdk_common.http,
            tokenProvider: tokenProvider,
            requestInterceptor: requestInterceptor
        )
    }
    
    // MARK: HTTPClient
    
    /// Fetch and applies the authorization header from the `TokenProvider`.
    ///
    /// - Returns: A new copy of the `HTTPClient` with the authorization header.
    /// - Throws: An error if the token retrival fails.
    public func authenticated() async throws -> HTTPApiClient {
        guard let authToken = tokenProvider.retrieveToken() else {
            throw TruVideoFoundationError(
                kind: .NetworkErrorReason.authenticationTokenNotFound,
                failureReason: "Attempted to create an authenticated token but no token was found."
            )
        }
        
        let sharedHTTPClient = HTTPApiClient(
            url: url,
            httpService: httpService,
            tokenProvider: tokenProvider,
            requestInterceptor: requestInterceptor
        )
        
        sharedHTTPClient.headers = headers
        sharedHTTPClient.headers["Authorization"] = "Bearer \(authToken)"
        
        return sharedHTTPClient
    }
    
    /// Makes a get request to the given `path`.
    ///
    /// - Parameters:
    ///   - path: The path of the resource.
    ///   - parameters: The query parameters to send in the request.
    ///   - headers: The headers value to be added to the request.
    /// - Returns: The serialized `Value`.
    /// - Throws: An `Error` if something fails.
    public func get(_ path: String, parameters: [String: String], headers: [String: String]) async throws -> Request {
        let url = try url.asURL(with: path).appendingQueryParameters(parameters)
        let request = Request(url: url, requestInterceptor: requestInterceptor) { @MainActor in
            let response = try await self.httpService.get(
                url: url.absoluteString,
                headers: self.headers + headers,
                retry: false
            )
            
            guard let response else {
                // FIX ME
                throw NSError(domain: "", code: 0)
            }
            
            return URLResponse(url: url, statusCode: Int(response.code), data: response.body.data(using: .utf8))
        }
        
        return try await prepareRequest(request)
    }
    
    /// Makes a post request to the given `path`.
    ///
    /// - Parameters:
    ///   - path: The path of the resource.
    ///   - parameters: The parameters to send in the request.
    ///   - encoder: The encoder to be used to encode the `parameters` value into the `Request`.
    ///   - headers: The headers value to be added to the request.
    /// - Returns: The serialized `Value`.
    /// - Throws: An `Error` if something fails.
    public func post<Parameters: Encodable>(
        _ path: String,
        parameters: Parameters,
        encoder: any ParameterEncoder,
        headers: [String: String]
    ) async throws -> Request {

        let url = try url.asURL(with: path)
        let request = Request(url: url, requestInterceptor: requestInterceptor) { @MainActor in
            var headers = self.headers + headers
            let body = try encoder.encode(parameters, headers: &headers)
            
            let response = try await self.httpService.post(
                url: url.absoluteString,
                headers: headers,
                body: body,
                retry: false
            )
            
            guard let response else {
                // FIX ME
                throw NSError(domain: "", code: 0)
            }
            
            return URLResponse(url: url, statusCode: Int(response.code), data: response.body.data(using: .utf8))
        }
        
        return try await prepareRequest(request)
    }
    
    // MARK: Private methods
    
    private func prepareRequest(_ request: Request) async throws -> Request {
        guard let requestInterceptor else { return request }
        
        do {
            return try await requestInterceptor.intercept(request, client: self)
        } catch {
            throw error.asFoundationError(
                or: TruVideoFoundationError(kind: .NetworkErrorReason.interceptionFailed, underlyingError: error)
            )
        }
    }
}
