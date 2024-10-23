//
// Created by TruVideo on 18/06/24.
// Copyright © 2024 TruVideo. All rights reserved.
//

import Foundation

/// Type used to store all values associated with a serialized response of a `HTTPURLResponse`.
public struct Response<Success> {
    /// The server's response to the URL request.
    public let response: URLResponse?
    
    /// The result of response serialization.
    public let result: Result<Success, TruVideoFoundationError>
    
    // MARK: - Computed Properties
    
    /// Returns the associated error value if the result if it is a failure, `nil` otherwise.
    public var error: TruVideoFoundationError? {
        switch result {
        case let .failure(error):
            return error

        default:
            return nil
        }
    }

    /// Returns the associated value of the result if it is a success, `nil` otherwise.
    public var value: Success? {
        switch result {
        case let .success(value):
            return value

        default:
            return nil
        }
    }

    // MARK: Initializer

    /// Creates a `Response` instance with the specified parameters.
    ///
    /// - Parameters:
    ///    - response: The server's response to the URL request.
    ///    - result: The result of response serialization.
    public init(
        response: URLResponse?,
        result: Result<Success, TruVideoFoundationError>
    ) {

        self.response = response
        self.result = result
    }
    
    // MARK: Instance methods
    
    /// Returns the success value as a throwing expression.
    ///
    /// - Returns: The success value, if the instance represents a success.
    /// - Throws: The failure value, if the instance represents a failure.
    @discardableResult
    func get() async throws -> Success {
        switch result {
        case .failure(let error):
            throw error

        case .success(let value):
            return value
        }
    }
}

extension Response: CustomStringConvertible, CustomDebugStringConvertible {
    /// The textual representation used when written to an output stream, which includes whether the result was a
    /// success or failure.
    public var description: String {
        "\(result)"
    }

    /// The debug textual representation used when written to an output stream, which includes (if available) a summary
    /// of the `URLRequest`, the request's headers and body; the
    /// `HTTPURLResponse`'s status code and body; and the `Result` of serialization.
    public var debugDescription: String {
        let responseDescription = response.map { response in
            let body = response.data.map { data in
                String(data: data, encoding: .utf8)?
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .replacingOccurrences(of: "\n", with: "\n    ") ?? "None"
            } ?? "None"
            return """
            [Response]:
                [Status Code]: \(response.statusCode)
                [Body]: \(body)
            """
                .replacingOccurrences(of: "\n", with: "\n    ")
        } ?? "[Response]: None"

        return """
        \(responseDescription)
        [Result]: \(result)
        """
    }
}
