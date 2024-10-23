//
// Created by TruVideo on 18/06/24.
// Copyright © 2024 TruVideo. All rights reserved.
//

import Foundation

/// A type that can encode any `Encodable` type into an `Output` type.
public protocol ParameterEncoder {
    /// A type representing the encoded `Parameters`.
    associatedtype Output
    
    /// Encode the provided `Encodable` parameters into an `Output` type.
    ///
    /// - Parameters:
    ///     - parameters: The `Encodable` parameter value.
    ///     - headers: The list of headers to append into the `Request`.
    /// - Returns: An `Output` type representing the encoded `Parameters`.
    /// - Throws: An `Error` when encoding fails.
    func encode<Parameters: Encodable>(_ parameters: Parameters?, headers: inout [String: String]) throws -> Output
}

/// A structure responsible for encoding `Encodable` parameters into a pretty-printed JSON string.
///
/// You create a `JSONStringEncoder` by providing an optional `JSONEncoder` instance. This structure
/// helps in converting `Encodable` parameters into a formatted JSON string that is human-readable.
///
/// The following example shows how to use `JSONStringEncoder` to encode a `User` object into a JSON string:
///
///     struct User: Encodable {
///         let name: String
///         let age: Int
///     }
///
///     // Create a User instance
///     let user = User(name: "John Doe", age: 30)
///
///     // Create an instance of JSONStringEncoder
///     let encoder = JSONStringEncoder()
///
///     do {
///         // Encode the User object into a JSON string
///         if let jsonString = try encoder.encode(user) {
///             print(jsonString)
///         } else {
///             print("Encoding returned nil.")
///         }
///     } catch {
///         print("Encoding failed with error: \(error)")
///     }
///
/// Example output:
///
///     {
///         "name" : "John Doe",
///         "age" : 30
///     }
public struct JSONStringEncoder: ParameterEncoder {
    // MARK: Properties

    /// The decoder to use when encoding the parameters.
    let encoder: JSONEncoder
    
    // MARK: Initializer

    /// Creates an instance using of the `JSONStringEncoder` with the values provided.
    ///
    /// - Parameter encoder: The encoder to use when encoding the parameters.
    init(encoder: JSONEncoder = .init()) {
        self.encoder = encoder
    }
    
    // MARK: ParameterEncoder
    
    /// Encode the provided `Encodable` parameters into an `Output` type.
    ///
    /// - Parameters:
    ///     - parameters: The `Encodable` parameter value.
    ///     - headers: The list of headers to append into the `Request`.
    /// - Returns: An `Output` type representing the encoded `Parameters`.
    /// - Throws: An `Error` when encoding fails.
    public func encode<Parameters: Encodable>(
        _ parameters: Parameters?,
        headers: inout [String: String]
    ) throws -> String {
        guard let parameters else { return "" }
        
        do {
            let data = try encoder.encode(parameters)
            
            if headers["Content-Type"] == nil {
                headers["Content-Type"] = "application/json"
            }
            
            return data.prettyPrintedJSON() ?? ""
        } catch {
            throw TruVideoFoundationError(kind: .NetworkErrorReason.parameterEncodingFailed, underlyingError: error)
        }
    }
}
