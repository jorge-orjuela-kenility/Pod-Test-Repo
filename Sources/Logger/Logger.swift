//
// Created by TruVideo on 17/09/24.
// Copyright © 2024 TruVideo. All rights reserved.
//

import Foundation

/// A protocol that defines a key used for accessing stored metadata, ensuring type safety and flexibility.
///
/// The `MetadataKey` protocol is used to represent a metadata key that can be used to read and write associated
/// data in a type-safe way. It defines an associated type, `DataType`, which represents the type of data stored
/// under this key. It also provides a static property `name`, which serves as the identifier for the metadata key.
///
/// This protocol is designed to enforce type safety when dealing with stored metadata, ensuring that the correct
/// data type is associated with each key.
public protocol MetadataKey: Hashable {
    /// The type of the storage data associated with the key.
    ///
    /// This associated type represents the type of data that is stored and retrieved using the metadata key.
    /// By default, the `DataType` is set to `Self`, but it can be overridden to represent any data type.
    ///
    /// Example:
    /// If a key is designed to store `String` values, the `DataType` would be `String`.
    associatedtype DataType: Hashable = Self

    /// A key name to read or write stored data.
    ///
    /// This static property provides a unique identifier or name for the key, which is used to access stored data.
    /// The name is typically used as the identifier in storage mechanisms (e.g., dictionaries or databases).
    static var name: String { get }
}

extension MetadataKey {
    /// A key name to read or write stored data.
    ///
    /// This static property provides a unique identifier or name for the key, which is used to access stored data.
    /// The name is typically used as the identifier in storage mechanisms (e.g., dictionaries or databases).
    public static var name: String {
        String(describing: Self.self)
    }
}

/// A `Logger` is the central . Its central function is to emit log messages using one of the methods
/// corresponding to a log level.
///
/// `Logger`s are value types with respect to the ``logLevel`` and the ``metadata`` (as well as the immutable `label`
/// and the selected ``LogDestination``). Therefore, `Logger`s are suitable to be passed around between
/// libraries if you want to preserve metadata across libraries.
///
/// The most basic usage of a `Logger` is
///
/// ```swift
/// logger.info("Hello World!")
/// ```
public struct Logger {
    // MARK: - Private Properties

    private var destination: LogDestination

    // MARK: - Properties

    /// An identifier of the creator of this `Logger`.
    public let label: String

    // MARK: - Computed Properties

    /// Get or set the log level configured for this `Logger`.
    public var logLevel: Logger.LogLevel {
        get {
            destination.logLevel
        }

        set {
            destination.logLevel = newValue
        }
    }

    // MARK: - Subscripts

    /// Add, change, or remove a logging metadata item.
    ///
    /// - parameter metadataKey: The key for the metadata item
    public subscript(metadataKey: String) -> Logger.Metadata.Value? {
        get {
            destination[metadataKey: metadataKey]
        }

        set {
            destination[metadataKey: metadataKey] = newValue
        }
    }

    // MARK: Initializer

    /// Construct  a `Logger` given a `label` identifying the creator of the `Logger`..
    ///
    /// - Parameters:
    ///   - label: An identifier of the creator of this `Logger`.
    ///   - destination: The log destination,
    public init(label: String, destination: (String) -> LogDestination) {
        self.destination = destination(label)
        self.label = label
    }

    // MARK: Instance methods

    /// Log a message passing with the ``Logger/Level/critical`` log level.
    ///
    /// `.critical` messages will always be logged.
    ///
    /// - parameters:
    ///    - message: The message to be logged. `message` can be used with any string interpolation literal.
    ///    - metadata: One-off metadata to attach to this log message.
    ///    - source: The source this log messages originates from. Defaults
    ///              to the module emitting the log message (on Swift 5.3 or
    ///              newer and the folder name containing the log emitting file on Swift 5.2 or
    ///              older).
    ///    - file: The file this log message originates from (there's usually no need to pass it explicitly as it
    ///            defaults to `#fileID` (on Swift 5.3 or newer and `#file` on Swift 5.2 or older).
    ///    - function: The function this log message originates from (there's usually no need to pass it explicitly as
    ///                it defaults to `#function`).
    ///    - line: The line this log message originates from (there's usually no need to pass it explicitly as it
    ///            defaults to `#line`).
    public func critical(
        _ message: @autoclosure () -> Logger.Message,
        metadata: @autoclosure () -> Logger.Metadata? = nil,
        source: @autoclosure () -> String? = nil,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) {

        log(
            level: .critical,
            message(),
            metadata: metadata(),
            source: source(),
            file: file,
            function: function,
            line: line
        )
    }

    /// Log a message passing with the ``Logger/Level/debug`` log level.
    ///
    /// If `.debug` is at least as severe as the `Logger`'s ``logLevel``, it will be logged,
    /// otherwise nothing will happen.
    ///
    /// - parameters:
    ///    - message: The message to be logged. `message` can be used with any string interpolation literal.
    ///    - metadata: One-off metadata to attach to this log message.
    ///    - source: The source this log messages originates from. Defaults
    ///              to the module emitting the log message (on Swift 5.3 or
    ///              newer and the folder name containing the log emitting file on Swift 5.2 or
    ///              older).
    ///    - file: The file this log message originates from (there's usually no need to pass it explicitly as it
    ///            defaults to `#fileID` (on Swift 5.3 or newer and `#file` on Swift 5.2 or older).
    ///    - function: The function this log message originates from (there's usually no need to pass it explicitly as
    ///                it defaults to `#function`).
    ///    - line: The line this log message originates from (there's usually no need to pass it explicitly as it
    ///            defaults to `#line`).
    public func debug(
        _ message: @autoclosure () -> Logger.Message,
        metadata: @autoclosure () -> Logger.Metadata? = nil,
        source: @autoclosure () -> String? = nil,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) {

        log(
            level: .debug,
            message(),
            metadata: metadata(),
            source: source(),
            file: file,
            function: function,
            line: line
        )
    }

    /// Log a message passing with the ``Logger/Level/error`` log level.
    ///
    /// If `.error` is at least as severe as the `Logger`'s ``logLevel``, it will be logged,
    /// otherwise nothing will happen.
    ///
    /// - Parameters:
    ///    - message: The message to be logged. `message` can be used with any string interpolation literal.
    ///    - metadata: One-off metadata to attach to this log message.
    ///    - source: The source this log messages originates from. Defaults
    ///              to the module emitting the log message (on Swift 5.3 or
    ///              newer and the folder name containing the log emitting file on Swift 5.2 or
    ///              older).
    ///    - file: The file this log message originates from (there's usually no need to pass it explicitly as it
    ///            defaults to `#fileID` (on Swift 5.3 or newer and `#file` on Swift 5.2 or older).
    ///    - function: The function this log message originates from (there's usually no need to pass it explicitly as
    ///                it defaults to `#function`).
    ///    - line: The line this log message originates from (there's usually no need to pass it explicitly as it
    ///            defaults to `#line`).
    public func error(
        _ message: @autoclosure () -> Logger.Message,
        metadata: @autoclosure () -> Logger.Metadata? = nil,
        source: @autoclosure () -> String? = nil,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) {

        log(
            level: .error,
            message(),
            metadata: metadata(),
            source: source(),
            file: file,
            function: function,
            line: line
        )
    }

    /// Log a message passing with the ``Logger/Level/info`` log level.
    ///
    /// - Parameters:
    ///    - message: The message to be logged. `message` can be used with any string interpolation literal.
    ///    - metadata: One-off metadata to attach to this log message.
    ///    - source: The source this log messages originates from. Defaults
    ///              to the module emitting the log message (on Swift 5.3 or
    ///              newer and the folder name containing the log emitting file on Swift 5.2 or
    ///              older).
    ///    - file: The file this log message originates from (there's usually no need to pass it explicitly as it
    ///            defaults to `#fileID` (on Swift 5.3 or newer and `#file` on Swift 5.2 or older).
    ///    - function: The function this log message originates from (there's usually no need to pass it explicitly as
    ///                it defaults to `#function`).
    ///    - line: The line this log message originates from (there's usually no need to pass it explicitly as it
    ///            defaults to `#line`).
    public func info(
        _ message: @autoclosure () -> Logger.Message,
        metadata: @autoclosure () -> Logger.Metadata? = nil,
        source: @autoclosure () -> String? = nil,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) {

        log(level: .info, message(), metadata: metadata(), source: source(), file: file, function: function, line: line)
    }

    /// Log a message passing the log level as a parameter.
    ///
    /// If the `logLevel` passed to this method is more severe than the `Logger`'s ``logLevel``, it will be logged,
    /// otherwise nothing will happen.
    ///
    /// - Parameters:
    ///    - level: The log level to log `message` at. For the available log levels, see `Logger.Level`.
    ///    - message: The message to be logged. `message` can be used with any string interpolation literal.
    ///    - metadata: One-off metadata to attach to this log message.
    ///    - source: The source this log messages originates from. Defaults
    ///              to the module emitting the log message (on Swift 5.3 or
    ///              newer and the folder name containing the log emitting file on Swift 5.2 or
    ///              older).
    ///    - file: The file this log message originates from (there's usually no need to pass it explicitly as it
    ///            defaults to `#fileID` (on Swift 5.3 or newer and `#file` on Swift 5.2 or older).
    ///    - function: The function this log message originates from (there's usually no need to pass it explicitly as
    ///                it defaults to `#function`).
    ///    - line: The line this log message originates from (there's usually no need to pass it explicitly as it
    ///            defaults to `#line`).
    public func log(
        level: Logger.LogLevel,
        _ message: @autoclosure () -> Logger.Message,
        metadata: @autoclosure () -> Logger.Metadata? = nil,
        source: @autoclosure () -> String? = nil,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) {

        destination.log(
            level: level,
            message: message(),
            metadata: metadata(),
            source: source() ?? Logger.currentModule(fileID: file),
            file: file,
            function: function,
            line: line
        )
    }

    /// Log a message passing with the ``Logger/Level/notice`` log level.
    ///
    /// - Parameters:
    ///    - message: The message to be logged. `message` can be used with any string interpolation literal.
    ///    - metadata: One-off metadata to attach to this log message.
    ///    - source: The source this log messages originates from. Defaults
    ///              to the module emitting the log message (on Swift 5.3 or
    ///              newer and the folder name containing the log emitting file on Swift 5.2 or
    ///              older).
    ///    - file: The file this log message originates from (there's usually no need to pass it explicitly as it
    ///            defaults to `#fileID` (on Swift 5.3 or newer and `#file` on Swift 5.2 or older).
    ///    - function: The function this log message originates from (there's usually no need to pass it explicitly as
    ///                it defaults to `#function`).
    ///    - line: The line this log message originates from (there's usually no need to pass it explicitly as it
    ///            defaults to `#line`).
    public func notice(
        _ message: @autoclosure () -> Logger.Message,
        metadata: @autoclosure () -> Logger.Metadata? = nil,
        source: @autoclosure () -> String? = nil,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) {

        log(
            level: .notice,
            message(),
            metadata: metadata(),
            source: source(),
            file: file,
            function: function,
            line: line
        )
    }

    /// Log a message passing with the ``Logger/Level/trace`` log level.
    ///
    /// If `.trace` is at least as severe as the `Logger`'s ``logLevel``, it will be logged,
    /// otherwise nothing will happen.
    ///
    /// - Parameters:
    ///    - message: The message to be logged. `message` can be used with any string interpolation literal.
    ///    - metadata: One-off metadata to attach to this log message
    ///    - source: The source this log messages originates from. Defaults
    ///              to the module emitting the log message (on Swift 5.3 or
    ///              newer and the folder name containing the log emitting file on Swift 5.2 or
    ///              older).
    ///    - file: The file this log message originates from (there's usually no need to pass it explicitly as it
    ///            defaults to `#fileID` (on Swift 5.3 or newer and `#file` on Swift 5.2 or older).
    ///    - function: The function this log message originates from (there's usually no need to pass it explicitly as
    ///                it defaults to `#function`).
    ///    - line: The line this log message originates from (there's usually no need to pass it explicitly as it
    ///            defaults to `#line`).
    public func trace(
        _ message: @autoclosure () -> Logger.Message,
        metadata: @autoclosure () -> Logger.Metadata? = nil,
        source: @autoclosure () -> String? = nil,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) {

        log(
            level: .trace,
            message(),
            metadata: metadata(),
            source: source(),
            file: file,
            function: function,
            line: line
        )
    }

    /// Log a message passing with the ``Logger/Level/warning`` log level.
    ///
    /// If `.warning` is at least as severe as the `Logger`'s ``logLevel``, it will be logged,
    /// otherwise nothing will happen.
    ///
    /// - Parameters:
    ///    - message: The message to be logged. `message` can be used with any string interpolation literal.
    ///    - metadata: One-off metadata to attach to this log message.
    ///    - source: The source this log messages originates from. Defaults
    ///              to the module emitting the log message (on Swift 5.3 or
    ///              newer and the folder name containing the log emitting file on Swift 5.2 or
    ///              older).
    ///    - file: The file this log message originates from (there's usually no need to pass it explicitly as it
    ///            defaults to `#fileID` (on Swift 5.3 or newer and `#file` on Swift 5.2 or older).
    ///    - function: The function this log message originates from (there's usually no need to pass it explicitly as
    ///                it defaults to `#function`).
    ///    - line: The line this log message originates from (there's usually no need to pass it explicitly as it
    ///            defaults to `#line`).
    public func warning(
        _ message: @autoclosure () -> Logger.Message,
        metadata: @autoclosure () -> Logger.Metadata? = nil,
        source: @autoclosure () -> String? = nil,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) {

        log(
            level: .warning,
            message(),
            metadata: metadata(),
            source: source(),
            file: file,
            function: function,
            line: line
        )
    }
}

extension Logger {
    /// `Metadata` is a typealias for `[String: Logger.MetadataValue]` the type of the metadata storage.
    public typealias Metadata = [String: MetadataValue]

    /// The log level.
    public struct LogLevel: Codable, Hashable, RawRepresentable {
        // MARK: - Properties

        /// The priority value.
        public let priority: Int

        /// The corresponding value of the raw type.
        public let rawValue: String

        // MARK: - Static Properties

        /// Appropriate for critical error conditions that usually require immediate
        /// attention.
        ///
        /// When a `critical` message is logged, the logging backend (`LogDestination`) is free to perform
        /// more heavy-weight operations to capture system state (such as capturing stack traces) to facilitate
        /// debugging.
        public static let critical = LogLevel(rawValue: "CRITICAL", priority: 6)

        /// Appropriate for messages that contain information normally of use only when
        /// debugging a program.
        public static let debug = LogLevel(rawValue: "DEBUG", priority: 1)

        /// Appropriate for error conditions.
        public static let error = LogLevel(rawValue: "ERROR", priority: 5)

        /// Appropriate for informational messages.
        public static let info = LogLevel(rawValue: "INFO", priority: 2)

        /// Appropriate for conditions that are not error conditions, but that may require
        /// special handling.
        public static let notice = LogLevel(rawValue: "NOTICE", priority: 3)

        /// Appropriate for messages that contain information normally of use only when
        /// tracing the execution of a program.
        public static let trace = LogLevel(rawValue: "TRACE")

        /// Appropriate for messages that are not error conditions, but more severe than
        /// `.notice`.
        public static let warning = LogLevel(rawValue: "WARNING", priority: 4)

        // MARK: Initializers

        /// Creates a new instance with the specified raw value.
        ///
        /// - Parameter rawValue: The raw value to use for the new instance.
        public init(rawValue: String) {
            self.priority = 0
            self.rawValue = rawValue
        }

        /// Creates a new instance with the specified raw value.
        ///
        /// - Parameters:
        ///    - rawValue: The raw value to use for the new instance.
        ///    - priority: The priority of this `LogLevel`.
        public init(rawValue: String, priority: Int) {
            self.priority = priority
            self.rawValue = rawValue
        }
    }

    /// `Logger.Message` represents a log message's text. It is usually created using string literals.
    ///
    /// Example creating a `Logger.Message`:
    ///
    ///     let world: String = "world"
    ///     let logMessage: Logger.Message = "Hello \(world)"
    ///
    public struct Message: ExpressibleByStringLiteral,
                           Equatable,
                           CustomStringConvertible,
                           ExpressibleByStringInterpolation {

        // MARK: - Private Properties

        private var value: String

        // MARK: - Computed Properties

        /// A textual representation of this instance.
        public var description: String {
            value
        }

        // MARK: Initializer

        /// Creates an instance initialized to the given string value.
        ///
        /// - Parameter value: The value of the new instance.
        public init(stringLiteral value: String) {
            self.value = value
        }
    }

    /// A logging metadata value. `Logger.MetadataValue` is string, array, and dictionary literal convertible.
    public enum MetadataValue {
        /// A metadata value which is an array of `Logger.MetadataValue`s.
        case array([Metadata.Value])

        /// A metadata value which is a dictionary from `String` to `Logger.MetadataValue`.
        case dictionary(Metadata)

        /// A custom metadata value.
        case custom(AnyHashable)

        /// A metadata value which is a `String`.
        case string(String)
    }
}

extension Logger {
    static func currentModule(fileID: String = #fileID) -> String {
        let utf8All = fileID.utf8
        guard let slashIndex = utf8All.firstIndex(of: UInt8(ascii: "/")) else {
            return "n/a"
        }

        return String(fileID[..<slashIndex])
    }
}

extension Logger.LogLevel: Comparable {

    // MARK: Comparable

    /// Returns a Boolean value indicating whether the value of the first
    /// argument is less than that of the second argument.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func < (lhs: Logger.LogLevel, rhs: Logger.LogLevel) -> Bool {
        lhs.priority < rhs.priority
    }
}

extension Logger.Metadata {
    // MARK: - Subcripts

    /// Add, change, or remove a logging metadata item.
    ///
    /// - parameter metadataKey: The tag key for the metadata item.
    public subscript<K: MetadataKey>(_ metadataKey: K.Type) -> K.DataType? {
        get {
            guard
                /// The metadata value.
                let value = self[metadataKey.name],

                /// The value should be a `LoggerMetadataValue.custom` otherwise its ignored.
                case let .custom(customValue) = value else {

                return nil
            }

            return customValue as? K.DataType
        }

        set {
            self[metadataKey.name] = .custom(newValue)
        }
    }
}

extension Logger.MetadataValue: CustomStringConvertible {

    // MARK: CustomStringConvertible

    /// A textual representation of this instance.
    public var description: String {
        switch self {
        case let .dictionary(dict):
            return dict.mapValues(\.description).description

        case let .array(list):
            return list.map(\.description).description

        case let .custom(value):
            return value.description

        case let .string(str):
            return str
        }
    }
}

extension Logger.MetadataValue: Equatable {

    // MARK: Equatable

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: Logger.Metadata.Value, rhs: Logger.Metadata.Value) -> Bool {
        switch (lhs, rhs) {
        case let (.array(lhs), .array(rhs)):
            return lhs == rhs

        case let (.dictionary(lhs), .dictionary(rhs)):
            return lhs == rhs

        case let (.string(lhs), .string(rhs)):
            return lhs == rhs

        default:
            return false
        }
    }
}

extension Logger.MetadataValue: ExpressibleByDictionaryLiteral {

    // MARK: ExpressibleByDictionaryLiteral

    /// Creates an instance initialized with the given key-value pairs.
    public init(dictionaryLiteral elements: (String, Logger.Metadata.Value)...) {
        self = .dictionary(.init(uniqueKeysWithValues: elements))
    }
}

extension Logger.MetadataValue: ExpressibleByArrayLiteral {

    // MARK: ExpressibleByArrayLiteral

    /// Creates an instance initialized with the given array elements.
    public init(arrayLiteral elements: Logger.Metadata.Value...) {
        self = .array(elements)
    }
}

extension Logger.MetadataValue: ExpressibleByStringLiteral {

    // MARK: ExpressibleByStringLiteral

    /// Creates an instance initialized to the given string value.
    ///
    /// - Parameter value: The value of the new instance.
    public init(stringLiteral value: String) {
        self = .string(value)
    }
}

extension Logger.MetadataValue: ExpressibleByStringInterpolation {}
