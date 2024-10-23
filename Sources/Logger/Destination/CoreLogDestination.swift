//
// Created by TruVideo on 03/10/24.
// Copyright © 2024 TruVideo. All rights reserved.
//

import Foundation

@_implementationOnly import shared

/// A public enumeration representing different module metadata key values used for logging purposes in the SDK.
///
/// The `ModuleMetadataKey` enum provides a set of predefined cases, each corresponding to a specific module within
/// the SDK.
public enum Module {
    /// Represents the core module of the SDK.
    ///
    /// This case is used for logging and tracking activities related to the fundamental components of the SDK,
    /// such as initialization, configuration, and core logic that affects multiple parts of the system.
    case core

    /// Represents the camera module of the SDK.
    ///
    /// This case is used for logging and tracking activities related to camera operations, such as capturing
    /// photos or videos, accessing camera settings, or handling camera-related functionalities.
    case camera

    /// Represents the image module of the SDK.
    ///
    /// This case is used for logging and tracking activities related to image processing and manipulation,
    /// such as applying filters, resizing, or encoding/decoding image files.
    case image

    /// Represents the media module of the SDK.
    ///
    /// This case is used for logging and tracking activities related to media management, which may include
    /// handling audio, video, and image files. It serves as a general-purpose category for non-specific
    /// media operations.
    case media

    /// Represents the video module of the SDK.
    ///
    /// This case is used for logging and tracking activities related to video processing and playback, including
    /// encoding/decoding video files, streaming, or applying video-specific operations such as frame extraction.
    case video

    /// Returns the corresponding `TruvideoSdkLogModule` for each `ModuleMetadataKey` case.
    var module: TruvideoSdkLogModule {
        switch self {
        case .core:
            return .core

        case .camera:
            return .camera

        case .image:
            return .image

        case .media:
            return .media

        case .video:
            return .video
        }
    }
}

public struct ModuleMetadataKey: MetadataKey {
    /// The type of the storage data associated with the key.
    public typealias DataType = Module
}

/// A metadata key used for storing and retrieving tag information, conforming to the `MetadataKey` protocol.
///
/// `TagMetadataKey` is a specific implementation of the `MetadataKey` protocol designed to work with tag-related
/// metadata. It defines the data type associated with the key as `String`, meaning that this key is intended
/// to store and retrieve string-based tag information.
///
/// This key can be used in any system that requires structured access to metadata, ensuring type safety
/// when working with tag data.
public struct TagMetadataKey: MetadataKey {
    /// The type of the storage data associated with the key.
    public typealias DataType = String
}

/// `CoreLogDestination` is a simple implementation of `LogDestination` for directing
/// `Logger` outputs to the commons module.
public final class CoreLogDestination: LogDestination {
    // MARK: - Private Properties

    private let logger: LogService

    // MARK: - Properties

    /// The label identifying this destination
    public let label: String

    /// Get or set the configured log level.
    public var logLevel: Logger.LogLevel = .info

    /// Get or set the entire metadata storage as a dictionary.
    public var metadata = Logger.Metadata()

    // MARK: - Lazy Properties

    /// Returns the current SDK version.
    private lazy var version: String = {
        let bundle = Bundle(for: CoreLogDestination.self)

        guard
            /// The version properties file.
            let versionFile = bundle.path(forResource: "version", ofType: "properties"),

            /// The content raw string.
            let contents = try? String(contentsOfFile: versionFile) else {

            return ""
        }

        let lines = contents.components(separatedBy: .newlines)

        for line in lines {
            let components = line.components(separatedBy: "=")

            guard components.count == 2 && components[0] == "version" else { continue }

            return components[1]
        }

        return ""
    }()

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

    // MARK: Initializers

    /// Initializes a new instance with a given label and logger service.
    ///
    /// This initializer configures an object with a specified label and a logging service. The logger is used to track
    /// and record activities related to this instance. The logger service defaults to the common logging service
    /// provided by the SDK if no custom logger is provided. The logging service is also started automatically as part
    /// of this initialization process.
    ///
    /// - Parameters:
    ///   - label: A `String` that serves as a descriptive label for the object being initialized.
    ///   - logger: A `LogService` instance used for logging purposes.
    init(label: String, logger: LogService) {
        self.label = label
        self.logger = logger

        logger.start()
    }

    /// Initializes a new instance with a given label.
    ///
    /// This initializer configures an object with a specified label and a logging service. The logger is used to track
    /// and record activities related to this instance.
    ///
    /// - Parameter label: A `String` that serves as a descriptive label for the object being initialized.
    public convenience init(label: String) {
        self.init(label: label, logger: TruvideoSdkCommonKt.sdk_common.log)
    }

    // MARK: LogDestination

    // swiftlint:disable function_parameter_count
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

        let message = TruvideoSdkLog(
            tag: metadata?[TagMetadataKey.self] ?? source,
            message: message.description,
            severity: level.severity,
            module: metadata?[ModuleMetadataKey.self]?.module ?? Module.core.module,
            moduleVersion: version
        )

        logger.add(log: message)
    }
    // swiftlint:enable function_parameter_count
}

private extension Logger.LogLevel {
    // MARK: - Computed Properties

    /// A computed property that maps the current log level to its corresponding `TruvideoSdkLogSeverity` value.
    ///
    /// - Returns: The corresponding `TruvideoSdkLogSeverity` value for the current log level.
    var severity: TruvideoSdkLogSeverity {
        switch self {
        case .critical, .warning:
            return .warning

        case .debug:
            return .debug

        case .error:
            return .error

        default:
            return .info
        }
    }
}
