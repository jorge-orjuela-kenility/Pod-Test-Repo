//
// Created by TruVideo on 03/10/24.
// Copyright © 2024 TruVideo. All rights reserved.
//

import Foundation

private let iSO8601DateFormatter: ISO8601DateFormatter = {
    ISO8601DateFormatter()
}()

// swiftlint:disable function_parameter_count
/// The base definiton for a logging destination system.
public protocol LogDestination {
    /// Get or set the configured log level.
    var logLevel: Logger.LogLevel { get set }

    /// Get or set the entire metadata storage as a dictionary.
    var metadata: Logger.Metadata { get set }

    /// Add, remove, or change the logging metadata.
    ///
    /// - parameter metadataKey: The key for the metadata item
    subscript(metadataKey _: String) -> Logger.Metadata.Value? { get set }

    /// This method is called when a `LogDestination` must emit a log message.
    ///
    /// - Parameters:
    ///    - level: The log level the message was logged at.
    ///    - message: The message to log. To obtain a `String` representation call `message.description`.
    ///    - metadata: The metadata associated to this log message.
    ///    - source: The source where the log message originated, for example the logging module.
    ///    - file: The file the log message was emitted from.
    ///    - function: The function the log line was emitted from.
    ///    - line: The line the log message was emitted from.
    func log(
        level: Logger.LogLevel,
        message: Logger.Message,
        metadata: Logger.Metadata?,
        source: String,
        file: String,
        function: String,
        line: UInt
    )
}

extension LogDestination {
    /// This method is called when a `LogDestination` must emit a log message.
    ///
    /// - Parameters:
    ///    - level: The log level the message was logged at.
    ///    - message: The message to log. To obtain a `String` representation call `message.description`.
    ///    - metadata: The metadata associated to this log message.
    ///    - source: The source where the log message originated, for example the logging module.
    ///    - file: The file the log message was emitted from.
    ///    - function: The function the log line was emitted from.
    ///    - line: The line the log message was emitted from.
    func log(
        level: Logger.LogLevel,
        message: Logger.Message,
        metadata: Logger.Metadata?,
        source: String? = nil,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) {

        log(
            level: level,
            message: message,
            metadata: metadata,
            source: source ?? Logger.currentModule(fileID: file),
            file: file,
            function: function,
            line: line
        )
    }
}

/// The helper methods for `LogDestination` where `Self` is of type `StreamLogDestination`.
extension LogDestination where Self == StreamLogDestination {
    /// Factory that makes a `StreamLogDestination` to directs its output to `stdout`.
    ///
    /// - Parameter label: An identifier of the creator.
    static func standardOutput(label: String) -> StreamLogDestination {
        StreamLogDestination(label: label, stream: StdioOutputStream.stdout)
    }

    /// Factory that makes a `StreamLogDestination` to directs its output to `stderr`.
    ///
    /// - Parameter label: An identifier of the creator.
    static func standardError(label: String) -> StreamLogDestination {
        StreamLogDestination(label: label, stream: StdioOutputStream.stderr)
    }
}

/// A pseudo-`LogDestination` that can be used to send messages to multiple other `LogDestination`s.
///
/// ### Effective Logger.Level
///
/// When first initialized the multiplex log destination' log level is automatically set to the minimum of all the
/// passed in log destination. This ensures that each of the handlers will be able to log at their appropriate level
/// any log events they might be interested in.
public struct MultiplexLogDestination: LogDestination {
    // MARK: - Private Properties

    private var destinations: [LogDestination]
    private var effectiveLogLevel: Logger.LogLevel

    // MARK: - Computed Properties

    /// Get or set the configured log level.
    public var logLevel: Logger.LogLevel {
        get {
            effectiveLogLevel
        }

        set {
            foreach { $0.logLevel = newValue }
            effectiveLogLevel = newValue
        }
    }

    /// Get or set the entire metadata storage as a dictionary.
    public var metadata: Logger.Metadata {
        get {
            destinations.reduce(into: [:]) { metadata, destination in
                metadata.merge(destination.metadata, uniquingKeysWith: { val, _ in val })
            }
        }

        set {
            foreach { $0.metadata = newValue }
        }
    }

    // MARK: - Subscripts

    /// Add, remove, or change the logging metadata.
    ///
    /// - Parameter metadataKey: The key for the metadata item
    public subscript(metadataKey metadataKey: String) -> Logger.Metadata.Value? {
        get {
            for destination in destinations {
                guard let value = destination[metadataKey: metadataKey] else {
                    return nil
                }
                return value
            }

            return nil
        }

        set {
            foreach { $0[metadataKey: metadataKey] = newValue }
        }
    }

    // MARK: Initializer

    /// Creates a `MultiplexLogDestination`.
    ///
    /// - Parameter destinations: An array of `LogDestination`s, each of which will receive the
    ///                           log messages sent to this `Logger`.
    public init(destinations: [LogDestination]) {
        assert(!destinations.isEmpty, "MultiplexLogDestination.destinations MUST NOT be empty")
        self.destinations = destinations
        self.effectiveLogLevel = destinations.map(\.logLevel).min() ?? .debug
    }

    // MARK: LogDestination

    /// This method is called when a `LogDestination` must emit a log message.
    ///
    /// - Parameters:
    ///    - level: The log level the message was logged at.
    ///    - message: The message to log. To obtain a `String` representation call `message.description`.
    ///    - metadata: The metadata associated to this log message.
    ///    - source: The source where the log message originated, for example the logging module.
    ///    - file: The file the log message was emitted from.
    ///    - function: The function the log line was emitted from.
    ///    - line: The line the log message was emitted from.
    public func log(
        level: Logger.LogLevel,
        message: Logger.Message,
        metadata: Logger.Metadata?,
        source: String,
        file: String,
        function: String,
        line: UInt
    ) {

        for destination in destinations {
            destination.log(
                level: level,
                message: message,
                metadata: metadata,
                source: source,
                file: file,
                function: function,
                line: line
            )
        }
    }

    // MARK: Private methods

    private mutating func foreach(_ body: (inout LogDestination) -> Void) {
        for index in destinations.indices {
            body(&destinations[index])
        }
    }
}

/// `StreamLogDestination` is a simple implementation of `LogDestination` for directing
/// `Logger` outputs to either `stderr` or `stdout` via the factory methods.
///
///  ##Formats
///          - $I = Ignore
///     - $L = Level
///     - $M = Message
///     - $m = Metadata
///     - $F = File name
///     - $f = Function name
///     - $l = Function line
///     - $D = Date
///     - $E =Emoji
///     - $S = Source
public struct StreamLogDestination: LogDestination {
    // MARK: - Properties

    /// The label identifying this destination
    public let label: String

    /// A type that can be the target of text-streaming operations.
    public let stream: TextOutputStream

    /// Custom date formatter.
    public var dateFormatter: DateFormatter?

    /// Output format pattern.
    public var format = """
    [$E $L]:
         Date: $D
         File: $F
         Function: $f
         Line: $l
         Metadata: {$m}
         Source: $S
         Message: $M

    """

    /// Get or set the configured log level.
    public var logLevel: Logger.LogLevel = .info

    /// Get or set the entire metadata storage as a dictionary.
    public var metadata = Logger.Metadata()

    // MARK: - Subscripts

    /// Add, remove, or change the logging metadata.
    ///
    /// - Parameter metadataKey: The key for the metadata item
    public subscript(metadataKey metadataKey: String) -> Logger.Metadata.Value? {
        get {
           metadata[metadataKey]
        }

        set {
            metadata[metadataKey] = newValue
        }
    }

    // MARK: - Static Properties

    /// Factory that makes a `StreamLogDestination` to directs its output to `stdout`.
    ///
    /// - Parameter label: An identifier of the creator.
    public static func standardOutput(label: String) -> StreamLogDestination {
        StreamLogDestination(label: label, stream: StdioOutputStream.stdout)
    }

    /// Factory that makes a `StreamLogDestination` to directs its output to `stderr`.
    ///
    /// - Parameter label: An identifier of the creator.
    public static func standardError(label: String) -> StreamLogDestination {
        StreamLogDestination(label: label, stream: StdioOutputStream.stderr)
    }

    // MARK: LogDestination

    /// This method is called when a `LogDestination` must emit a log message.
    ///
    /// - Parameters:
    ///    - level: The log level the message was logged at.
    ///    - message: The message to log. To obtain a `String` representation call `message.description`.
    ///    - metadata: The metadata associated to this log message.
    ///    - source: The source where the log message originated, for example the logging module.
    ///    - file: The file the log message was emitted from.
    ///    - function: The function the log line was emitted from.
    ///    - line: The line the log message was emitted from.
    public func log(
        level: Logger.LogLevel,
        message: Logger.Message,
        metadata: Logger.Metadata?,
        source: String,
        file: String,
        function: String,
        line: UInt
    ) {

        var stream = stream
        let message = formatMessage(
            level: level,
            message: message,
            metadata: self.metadata.merging(metadata ?? .init(), uniquingKeysWith: { val, _ in val }),
            source: source,
            file: file,
            function: function,
            line: line
        )

        stream.write(message)
    }

    // MARK: Private methods

    private func formatMessage(
        level: Logger.LogLevel,
        message: Logger.Message,
        metadata: Logger.Metadata,
        source: String,
        file: String,
        function: String,
        line: UInt
    ) -> String {

        var text = "====== \(label) =======\n\n"
            let components = ("$I" + format).components(separatedBy: "$")

            for component in components {
                let trimmedComponent = component.trimmingCharacters(in: .whitespacesAndNewlines)
                if trimmedComponent.isEmpty {
                    text += component
                    continue
                }

                text += processComponent(
                    component,
                    level: level,
                    message: message,
                    metadata: metadata,
                    source: source,
                    file: file,
                    function: function,
                    line: line
                )
            }

            return text
    }

    private func processComponent(
        _ component: String,
        level: Logger.LogLevel,
        message: Logger.Message,
        metadata: Logger.Metadata,
        source: String,
        file: String,
        function: String,
        line: UInt
    ) -> String {

        guard let char = component.first else {
            return component
        }

        let remaining = component.dropFirst()
        let formatHandlers: [Character: String] = [
            "E": level.emoji,
            "D": (dateFormatter ?? iSO8601DateFormatter).string(for: Date()) ?? "",
            "I": "",
            "d": "",
            "z": "",
            "F": file,
            "f": function,
            "L": "\(level.rawValue)",
            "l": "\(line)",
            "M": "\(message)",
            "m": metadata.prettify(),
            "S": source
        ]

        guard let value = formatHandlers[char] else {
            return component
        }

        return value.appending(remaining)
    }
}

private extension Logger.LogLevel {
    /// Returns the color for the current `LogLevel`.
    var emoji: String {
        switch self {
        case .critical:
            return "❌"

        case .debug:
            return "⚙️"

        case .error:
            return "🐛"

        case .info:
            return "ℹ️"

        case .notice:
            return "🌐"

        case .warning:
            return "⚠️"

        default:
            return "✅"
        }
    }
}

private extension Logger.Metadata {
    /// Returns a prettified string.
    func prettify() -> String {
        self.lazy.sorted(by: { $0.key < $1.key }).map { "\($0):\($1)" }.joined(separator: ", ")
    }
}

private struct StdioOutputStream: TextOutputStream {
    let file: UnsafeMutablePointer<FILE>

    // MARK: - Static Properties

    static let stderr = StdioOutputStream(file: Darwin.stderr)
    static let stdout = StdioOutputStream(file: Darwin.stdout)

    // MARK: TextOutputStream

    /// Appends the given string to the stream.
    mutating func write(_ string: String) {
        var contiguous = string
        contiguous.makeContiguousUTF8()

        contiguous.utf8.withContiguousStorageIfAvailable { bytes in
            flockfile(file)
            defer {
                funlockfile(file)
            }

            if let baseAddress = bytes.baseAddress {
                _ = fwrite(baseAddress, 1, bytes.count, self.file)
            }
        }
    }
}
// swiftlint:enable function_parameter_count
