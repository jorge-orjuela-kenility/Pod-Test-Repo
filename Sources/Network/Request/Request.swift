//
// Created by TruVideo on 18/06/24.
// Copyright © 2024 TruVideo. All rights reserved.
//

import Foundation

/// A representation of an HTTP response containing data and status code.
///
/// The `URLResponse` struct encapsulates the data returned by an HTTP request and the associated status code.
/// It is used to model the result of an HTTP request, including the raw data and the HTTP response code.
public struct URLResponse: Equatable {
    /// The data returned from the HTTP request.
    ///
    /// This is the raw data received from the server in response to an HTTP request.
    /// You may need to decode or parse this data depending on the type of content returned (e.g., JSON, XML, etc.).
    public let data: Data?
    
    /// The HTTP status code of the response.
    public let statusCode: Int
    
    /// The URL hit in the server.
    public let url: URL
    
    // MARK: Initializer
    
    /// Initializes a new `URLResponse` instance.
    ///
    /// This initializer takes the raw data and status code from an HTTP response and encapsulates them into
    /// a structured response model.
    ///
    /// - Parameters:
    ///   - url: The URL hit in the server.
    ///   - statusCode: The HTTP status code returned by the server.
    ///   - data: The data returned from the HTTP request, as a `Data` object.
    public init(url: URL, statusCode: Int, data: Data?) {
        self.data = data
        self.statusCode = statusCode
        self.url = url
    }
}

/// An actor that represents an HTTP request and manages its state, response, and associated tasks.
public actor Request {
    // MARK: Private Properties
    
    private let dataTask: Task<URLResponse?, Error>
    private var responseSerializers: [() -> Void] = []
    
    // MARK: Properties
    
    /// The `Response` received from the server so far.
    private(set) var response: URLResponse?
    
    // MARK: - Public Properties

    /// `UUID` providing a unique identifier for the `Request`.
    public let id: UUID
    
    /// The `Request`'s interceptor.
    public let requestInterceptor: RequestInterceptor?
    
    /// Current `URLRequest` created on behalf of the `Request`.
    public let url: URL

    /// `Error` returned from the `Core` internally, from the network request directly.
    public fileprivate(set) var error: TruVideoFoundationError?
    
    /// `State` of the `Request`.
    public private(set) var state: State = .initialized
    
    // MARK: - Computed Properties
    
    /// The data returned by the server.
    var data: Data? {
        response?.data
    }
    
    // MARK: - Types

    /// Enum representing the current state of a request.
    public enum State {
        /// `State` set when `cancel()` is called
        case cancelled

        /// `State` set when all response serialization completion closures have been cleared on the `Request` and
        /// enqueued on their respective queues.
        case finished

        /// Initial state of the `Request`.
        case initialized

        /// `State` set when the `Request` is resumed.
        case resumed
        
        /// Determines whether `self` can be transitioned to the provided `State`.
        func canTransitionTo(_ state: State) -> Bool {
            switch (self, state) {
            case (.initialized, _):
                return true

            case (_, .initialized), (.cancelled, _), (.finished, _):
                return false

            case (.resumed, .cancelled):
                return true

            case (.resumed, .resumed):
                return false

            case (_, .finished):
                return true
            }
        }
    }

    // MARK: Initializer

    /// Creates a new instance of the `Request`.
    ///
    /// - Parameters:
    ///    - id: `UUID` used for the `Hashable` and `Equatable` implementations. `UUID()` by default.
    ///    - url: The URL to be accessed by the HTTP task.
    ///    - requestInterceptor: The `Request`'s interceptor.
    ///    - dataTask: The underliying async task.
    public init(
        id: UUID = UUID(),
        url: URL,
        requestInterceptor: RequestInterceptor?,
        dataTask: @Sendable @escaping () async throws -> URLResponse?
    ) {

        self.id = id
        self.requestInterceptor = requestInterceptor
        self.url = url
        self.dataTask = Task(priority: .userInitiated, operation: dataTask)
    }
   
    // MARK: Instance methods
    
    /// Cancels the request.
    ///
    /// - Returns: The current instance of the `Request`.
    @discardableResult
    func cancel() -> Self {
        guard state.canTransitionTo(.cancelled) else { return self }
        
        state = .cancelled
        dataTask.cancel()
        
        return self
    }
    
    /// Resumes the request.
    ///
    /// - Returns: The current instance of the `Request`.
    @discardableResult
    func resume() -> Self {
        guard state.canTransitionTo(.resumed) else { return self }
        
        Task {
            state = .resumed
            
            do {
                response = try await dataTask.value
                
                didFinish(error: nil)
            } catch {
                didFinish(error: error)
            }
        }
        
        return self
    }
   
    // swiftlint:disable identifier_name
    /// Serializes the response to a specified type.
    ///
    /// - Parameters:
    ///   - of: The type to serialize the response to.
    ///   - decoder: The JSON decoder to use. Defaults to a new instance.
    /// - Returns: The serialized response.
    func serializingResponse<Value: Decodable>(
       of: Value.Type,
       decoder: JSONDecoder = .init()
    ) async throws -> Response<Value> {
        
        let task = response(serializer: DecodableResponseSerializer<Value>())
        
        return await task.value
    }
    // swiftlint:enable identifier_name
    
    // MARK: Private methods
    
    private func appendResponseSerializer(_ serializer: @escaping () -> Void) {
        responseSerializers.append(serializer)
        resume()
    }
    
    private func didFinish(error: Error?) {
        guard state.canTransitionTo(.finished) else { return }
        
        if let error {
            self.error = error.asFoundationError(or: TruVideoFoundationError(kind: .unknown, underlyingError: error))
        }
                
        responseSerializers.forEach { $0() }
        state = .finished
    }
    
    private func response<Serializer: ResponseSerializer>(
       serializer: Serializer
    ) -> Task<Response<Serializer.SerializedObject>, Never> {
        
        Task {
            await withCheckedContinuation { [self] continuation in
                appendResponseSerializer {
                    let result = Result {
                        try serializer.serialize(response: self.response, data: self.data, error: self.error)
                    }
                        .mapError {
                            $0.asFoundationError(
                                or: TruVideoFoundationError(
                                    kind: .NetworkErrorReason.responseSerializationFailed,
                                    underlyingError: $0
                                )
                            )
                        }
                    
                    let response = Response<Serializer.SerializedObject>(response: self.response, result: result)

                    continuation.resume(returning: response)
                }
            }
        }
    }
}
