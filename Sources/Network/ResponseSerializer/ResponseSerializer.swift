//
// Created by TruVideo on 18/06/24.
// Copyright © 2024 TruVideo. All rights reserved.
//

import Foundation

/// Type representing an empty value.
public struct Empty: Codable {
    /// Static instance used for all `Empty` responses.
    public static let value = Empty()
}

/// The type to which all data response serializers must conform in order to serialize a response.
public protocol ResponseSerializer {
    /// The type of serialized object to be created.
    associatedtype SerializedObject

    /// HTTP response codes for which empty response bodies are considered appropriate.
    var emptyResponseCodes: Set<Int> { get }

    /// Serialize the response `Data` into the provided type..
    ///
    /// - Parameters:
    ///   - response: `URLResponse` received from the server, if any.
    ///   - data: `Data` returned from the server, if any.
    ///   - error: `Error` produced by the  or the underlying `http` client during the request.
    /// - Returns: The `SerializedObject`.
    /// - Throws: Any `Error` produced during serialization.
    func serialize(response: URLResponse?, data: Data?, error: Error?) throws -> SerializedObject
}

extension ResponseSerializer {
    /// The HTTP response codes for which empty responses are allowed. `[204, 205]` by default.
    public static var defaultEmptyResponseCodes: Set<Int> {
        [204, 205]
    }
}

/// A response serializer that decodes data into a `Decodable` type.
///
/// You create a `DecodableResponseSerializer` by providing the `Decodable` type you want to deserialize,
/// an optional `JSONDecoder`, and an optional set of HTTP response codes for which empty responses are allowed.
///
/// The following example shows how to use `DecodableResponseSerializer` to decode JSON data into a `User` object:
///
///     struct User: Decodable {
///         let id: Int
///         let name: String
///         let email: String
///     }
///
///     // Simulate a server response
///     let jsonData = """
///     {
///         "id": 1,
///         "name": "John Doe",
///         "email": "john.doe@example.com"
///     }
///     """.data(using: .utf8)!
///
///     // Create an instance of the response serializer
///     let serializer = DecodableResponseSerializer<User>()
///
///     do {
///         // Deserialize the response data into a User object
///         let user = try serializer.serialize(response: response, data: jsonData, error: nil)
///         print("User ID: \(user.id), Name: \(user.name), Email: \(user.email)")
///     } catch {
///         print("Failed to serialize response: \(error)")
///     }
///
/// This example defines a `User` struct conforming to `Decodable`, simulates a server response with JSON data,
/// creates an instance of `DecodableResponseSerializer`, and uses it to deserialize the response data into a `User` object.
public struct DecodableResponseSerializer<T: Decodable>: ResponseSerializer {
    // MARK: - Properties

    /// The decoder to use when deserializing the response.
    let decoder: JSONDecoder
    
    // MARK: - Public Properties
    
    /// The HTTP response codes for which empty responses are allowed
    public let emptyResponseCodes: Set<Int>
    
    // MARK: Initializer

    /// Creates an instance using of the `DecodableResponseSerializer`
    /// with the values provided.
    ///
    /// - Parameters:
    ///   - decoder: The decoder to use when deserializing the response.
    ///   - emptyResponseCodes: The HTTP response codes for which empty responses are allowed. `[204, 205]` by default.
    public init(
        decoder: JSONDecoder = JSONDecoder(),
        emptyResponseCodes: Set<Int> = DecodableResponseSerializer.defaultEmptyResponseCodes
    ) {
                        
        self.decoder = decoder
        self.emptyResponseCodes = emptyResponseCodes
    }
    
    // MARK: ResponseSerializerProtocol
    
    /// Serialize the response `Data` into the provided type..
    ///
    /// - Parameters:
    ///   - response: `URLResponse` received from the server, if any.
    ///   - data: `Data` returned from the server, if any.
    ///   - error: `Error` produced by the  or the underlying `http` client during the request.
    /// - Returns: The `SerializedObject`.
    /// - Throws: Any `Error` produced during serialization.
    public func serialize(response: URLResponse?, data: Data?, error: Error?) throws -> T {
        if let error { throw error }

        guard let data = data, !data.isEmpty else {
            let statusCode = response?.statusCode
            
            guard statusCode.map({ emptyResponseCodes.contains(Int($0)) }) == true else {
                throw TruVideoFoundationError(
                    kind: .NetworkErrorReason.responseSerializationFailed,
                    failureReason: "Status code \(String(describing: statusCode)),"
                        .appending(" is not a valid code for an empty response.")
                )
            }
            
            guard let empty = Empty.value as? T else {
                throw TruVideoFoundationError(
                    kind: .NetworkErrorReason.responseSerializationFailed,
                    failureReason: "Invalid empty type \(T.self)."
                )
            }

            return empty
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw TruVideoFoundationError(kind: .NetworkErrorReason.responseSerializationFailed, underlyingError: error)
        }
    }
}
