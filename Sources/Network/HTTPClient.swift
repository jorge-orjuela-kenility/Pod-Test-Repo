//
// Created by TruVideo on 18/06/24.
// Copyright © 2024 TruVideo. All rights reserved.
//

import Foundation

/// A protocol that coordinates a group of related, network data transfer tasks.
///
/// The `HTTPCLient` protocol and related classes provide an API for preparing data and uploading
/// to endpoints indicated by the path definition.
public protocol HTTPClient {
    /// Fetch and applies the authorization header from the `TokenProvider`.
    ///
    /// - Returns: A new copy of the `HTTPClient` with the authorization header.
    /// - Throws: An error if the token retrival fails.
    func authenticated() async throws -> Self
    
    /// Makes a get request to the given `path`.
    ///
    /// - Parameters:
    ///   - path: The path of the resource.
    ///   - parameters: The query parameters to send in the request.
    ///   - headers: The headers value to be added to the request.
    /// - Returns: The serialized `Value`.
    /// - Throws: An `Error` if something fails.
    func get(_ path: String, parameters: [String: String], headers: [String: String]) async throws -> Request
    
    /// Makes a post request to the given `path`.
    ///
    /// - Parameters:
    ///   - path: The path of the resource.
    ///   - parameters: The parameters to send in the request.
    ///   - encoder: The encoder to be used to encode the `parameters` value into the `Request`.
    ///   - headers: The headers value to be added to the request.
    /// - Returns: The serialized `Value`.
    /// - Throws: An `Error` if something fails.
    func post<Parameters: Encodable>(
        _ path: String,
        parameters: Parameters,
        encoder: any ParameterEncoder,
        headers: [String: String]
    ) async throws -> Request
}

extension HTTPClient {
    /// Makes a get request to the given `path`.
    ///
    /// - Parameters:
    ///   - path: The path of the resource.
    ///   - parameters: The query parameters to send in the request.
    ///   - headers: The headers value to be added to the request.
    /// - Returns: The serialized `Value`.
    /// - Throws: An `Error` if something fails.
    func get(
        _ path: String,
        parameters: [String: String] = [:],
        headers: [String: String] = [:]
    ) async throws -> Request {

        try await get(path, parameters: parameters, headers: parameters)
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
    func post<Parameters: Encodable>(
        _ path: String,
        parameters: Parameters,
        encoder: any ParameterEncoder = JSONStringEncoder(),
        headers: [String: String] = [:]
    ) async throws -> Request {
        
        try await post(path, parameters: parameters, encoder: encoder, headers: headers)
    }
}
