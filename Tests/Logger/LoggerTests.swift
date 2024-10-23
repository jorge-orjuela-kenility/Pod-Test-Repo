//
// Created by TruVideo on 17/09/24.
// Copyright © 2024 TruVideo. All rights reserved.
//

import TruvideoSdkFoundationTesting
import XCTest

@testable import TruvideoSdkFoundation

class LoggerTest: XCTestCase {
    private var logDestination: LogDestinationMock!
    
    // MARK: Overriden methods
    
    override func setUp() {
        logDestination = LogDestinationMock()
        
        super.setUp()
    }
    
    override func tearDown() {
        logDestination = nil
        
        super.tearDown()
    }

    // MARK: Tests

    func testThatCriticalLogParametersCorrectly() {
        // Given
        let sut = Logger(label: "foo") { _ in logDestination }

        // When
        sut.critical("critical test", metadata: ["response": "bar"])

        // Then
        XCTAssertEqual(logDestination.records.first?.level, .critical)
        XCTAssertEqual(logDestination.records.first?.metadata, ["response": "bar"])
        XCTAssertEqual(logDestination.records.first?.message, "critical test")
        XCTAssertEqual(logDestination.records.first?.source, "TruvideoSdkFoundationTests")
        XCTAssertEqual(logDestination.records.first?.file, #fileID)
        XCTAssertEqual(logDestination.records.first?.function, #function)
    }

    func testThatDebugLogParametersLogCorrectly() {
        // Given
        let sut = Logger(label: "foo") { _ in logDestination }

        // When
        sut.debug("debug test", metadata: ["response": "bar"])

        // Then
        XCTAssertEqual(logDestination.records.first?.level, .debug)
        XCTAssertEqual(logDestination.records.first?.metadata, ["response": "bar"])
        XCTAssertEqual(logDestination.records.first?.message, "debug test")
        XCTAssertEqual(logDestination.records.first?.source, "TruvideoSdkFoundationTests")
        XCTAssertEqual(logDestination.records.first?.file, #fileID)
        XCTAssertEqual(logDestination.records.first?.function, #function)
    }

    func testThatErrorLogParametersCorrectly() {
        // Given
        let sut = Logger(label: "foo") { _ in logDestination }

        // When
        sut.error("error test", metadata: ["response": "bar"])

        // Then
        XCTAssertEqual(logDestination.records.first?.level, .error)
        XCTAssertEqual(logDestination.records.first?.metadata, ["response": "bar"])
        XCTAssertEqual(logDestination.records.first?.message, "error test")
        XCTAssertEqual(logDestination.records.first?.source, "TruvideoSdkFoundationTests")
        XCTAssertEqual(logDestination.records.first?.file, #fileID)
        XCTAssertEqual(logDestination.records.first?.function, #function)
    }

    func testThatInfoLogParametersCorrectly() {
        // Given
        let sut = Logger(label: "foo") { _ in logDestination }

        // When
        sut.info("info test", metadata: ["response": "bar"])

        // Then
        XCTAssertEqual(logDestination.records.first?.level, .info)
        XCTAssertEqual(logDestination.records.first?.metadata, ["response": "bar"])
        XCTAssertEqual(logDestination.records.first?.message, "info test")
        XCTAssertEqual(logDestination.records.first?.source, "TruvideoSdkFoundationTests")
        XCTAssertEqual(logDestination.records.first?.file, #fileID)
        XCTAssertEqual(logDestination.records.first?.function, #function)
    }

    func testThatNoticeLogParametersCorrectly() {
        // Given
        let logDestination = LogDestinationMock(label: "")
        let sut = Logger(label: "foo") { _ in logDestination }

        // When
        sut.notice("notice test", metadata: ["response": "bar"])

        // Then
        XCTAssertEqual(logDestination.records.first?.level, .notice)
        XCTAssertEqual(logDestination.records.first?.metadata, ["response": "bar"])
        XCTAssertEqual(logDestination.records.first?.message, "notice test")
        XCTAssertEqual(logDestination.records.first?.source, "TruvideoSdkFoundationTests")
        XCTAssertEqual(logDestination.records.first?.file, #fileID)
        XCTAssertEqual(logDestination.records.first?.function, #function)
    }

    func testThatTraceLogParametersCorrectly() {
        // Given
        let sut = Logger(label: "foo") { _ in logDestination }

        // When
        sut.trace("trace test", metadata: ["response": "bar"])

        // Then
        XCTAssertEqual(logDestination.records.first?.level, .trace)
        XCTAssertEqual(logDestination.records.first?.metadata, ["response": "bar"])
        XCTAssertEqual(logDestination.records.first?.message, "trace test")
        XCTAssertEqual(logDestination.records.first?.source, "TruvideoSdkFoundationTests")
        XCTAssertEqual(logDestination.records.first?.file, #fileID)
        XCTAssertEqual(logDestination.records.first?.function, #function)
    }

    func testThatWarningLogsParametersCorrectly() {
        // Given
        let sut = Logger(label: "foo") { _ in logDestination }

        // When
        sut.warning("warning test", metadata: ["response": "bar"])

        // Then
        XCTAssertEqual(logDestination.records.first?.level, .warning)
        XCTAssertEqual(logDestination.records.first?.metadata, ["response": "bar"])
        XCTAssertEqual(logDestination.records.first?.message, "warning test")
        XCTAssertEqual(logDestination.records.first?.source, "TruvideoSdkFoundationTests")
        XCTAssertEqual(logDestination.records.first?.file, #fileID)
        XCTAssertEqual(logDestination.records.first?.function, #function)
    }

    func testThatDebugWithGivenFileName() {
        // Given
        let sut = Logger(label: "foo") { _ in logDestination }

        // When
        sut.debug("debug test", metadata: ["response": "bar"], file: "LoggingTestsLoggerTest.swift")

        // Then
        XCTAssertEqual(logDestination.records.first?.level, .debug)
        XCTAssertEqual(logDestination.records.first?.metadata, ["response": "bar"])
        XCTAssertEqual(logDestination.records.first?.message, "debug test")
        XCTAssertEqual(logDestination.records.first?.source, "n/a")
        XCTAssertEqual(logDestination.records.first?.file, "LoggingTestsLoggerTest.swift")
        XCTAssertEqual(logDestination.records.first?.function, #function)
    }

    func testThatDebugWithAGivenSource() {
        // Given
        let sut = Logger(label: "foo") { _ in logDestination }

        // When
        sut.debug("debug test", metadata: ["response": "bar"], source: "Some test source")

        // Then
        XCTAssertEqual(logDestination.records.first?.level, .debug)
        XCTAssertEqual(logDestination.records.first?.metadata, ["response": "bar"])
        XCTAssertEqual(logDestination.records.first?.message, "debug test")
        XCTAssertEqual(logDestination.records.first?.source, "Some test source")
        XCTAssertEqual(logDestination.records.first?.file, #fileID)
        XCTAssertEqual(logDestination.records.first?.function, #function)
    }

    func testThatLogLevelShouldReturnALevelFromYourDestination() {
        // Given
        let sut = Logger(label: "foo") { _ in logDestination }

        // When, Then
        XCTAssertEqual(sut.logLevel, .info)
    }

    func testThatLogLevelShouldSetTheLogLevelOfYourDestination() {
        // Given
        var sut = Logger(label: "foo") { _ in logDestination }
        
        // When
        sut.logLevel = .trace

        // Then
        XCTAssertEqual(logDestination.logLevel, .trace)
    }

    func testThatLogLevelCanBeInitialized() {
        // Given
        let sut = Logger.LogLevel(rawValue: "TEST", priority: 5)

        // When,Then
        XCTAssertEqual(sut.priority, 5)
        XCTAssertEqual(sut.rawValue, "TEST")
    }

    func testThatLogLevelCanBeInitializedJustWithRawValue() {
        // Given
        let sut = Logger.LogLevel(rawValue: "DEBUG")

        // When,Then
        XCTAssertEqual(sut.priority, 0)
        XCTAssertEqual(sut.rawValue, "DEBUG")
    }

    func testThatSubscriptShouldReturnAValueFoundInTheMetadataOfYourDestination() {
        // Given
        let sut = Logger(label: "foo") { _ in logDestination }
        
        // When
        logDestination.metadata = ["foo": "some test bar"]

        // Then
        XCTAssertEqual(sut["foo"], "some test bar")
    }

    func testThatSubscriptShoulSetTheValueOfTheMetadataOfYourDestination() {
        // Given
        var sut = Logger(label: "foo") { _ in logDestination }
        
        // When
        sut["foo"] = "some test bar"

        // Then
        XCTAssertEqual(logDestination.metadata, ["foo": "some test bar"])
    }

    func testThatDefaultDictionaryMetadataAreCorrect() {
        // Given
        var sut = Logger(label: "foo") { _ in logDestination }
        let expectedData: Logger.Metadata = [
            "simple_dictionary": ["bar": "buz"]
        ]

        // When
        sut["simple_dictionary"] = ["bar": "buz"]

        // Then
        XCTAssertEqual(logDestination.metadata, expectedData)
    }

    func testThatDictionaryMetadataWithNestedDictionaryAreCorrect() {
        // Given
        var sut = Logger(label: "foo") { _ in logDestination }
        let expectedData: Logger.Metadata = [
            "nested_dictionary": ["lkey": ["2key": ["3key": "3value"]]]
        ]

        // When
        sut["nested_dictionary"] = ["lkey": ["2key": ["3key": "3value"]]]

        // Then
        XCTAssertEqual(logDestination.metadata, expectedData)
    }

    func testThatDictionaryMetadataWithEmptyDictionaryAreCorrect() {
        // Given
        var sut = Logger(label: "foo") { _ in logDestination }
        let expectedData: Logger.Metadata = [
            "empty_dictionary": [:]
        ]

        // When
        sut["empty_dictionary"] = [:]

        // Then
        XCTAssertEqual(logDestination.metadata, expectedData)
    }

    func testThatDefaultListMetadataAreCorrect() {
        // Given
        var sut = Logger(label: "foo") { _ in logDestination }
        let expectedData: Logger.Metadata = [
            "simple_list": ["foo, buz"]
        ]

        // When
        sut["simple_list"] = ["foo, buz"]

        // Then
        XCTAssertEqual(logDestination.metadata, expectedData)
    }

    func testThatListMetadataWithNestedListAreCorrect() {
        // Given
        var sut = Logger(label: "foo") { _ in logDestination }
        let expectedData: Logger.Metadata = [
            "nested_list": ["l1str", ["l2str1", "l2str2"]]
        ]

        // When
        sut["nested_list"] = ["l1str", ["l2str1", "l2str2"]]

        // Then
        XCTAssertEqual(logDestination.metadata, expectedData)
    }

    func testThatListMetadataWithEmptyListAreCorrect() {
        // Given
        var sut = Logger(label: "foo") { _ in logDestination }
        let expectedData: Logger.Metadata = [
            "empty_list": []
        ]

        // When
        sut["empty_list"] = []

        // Then
        XCTAssertEqual(logDestination.metadata, expectedData)
    }
    
    func testThatLogLevelComparison() {
        // Given, When, Then
        XCTAssertEqual(
            [Logger.LogLevel.error, .info, .notice, .trace, .warning, .critical, .debug].sorted(),
            [.trace, .debug, .info, .notice, .warning, .error, .critical]
        )
    }
    
    // MARK: Metadata Tests
    
    func testThatSetMetadataKeyValue() {
        // Given
        var sut = Logger.Metadata()
        
        // When
        sut[TagMetadataKey.self] = "foo"
        
        // Then
        XCTAssertEqual(sut[TagMetadataKey.self], "foo")
    }
    
    // MARK: MetadataValue Tests
    
    func testThatMetadataValueDescriptionForArrayValue() {
        // Given, When
        let sut = Logger.Metadata.Value.array(["foo", "bar"])
        
        // Then
        XCTAssertEqual(sut.description, "[\"foo\", \"bar\"]")
    }
    
    func testThatMetadataValueDescriptionForDictionaryValue() {
        // Given, When
        let sut = Logger.Metadata.Value.dictionary(["foo": "bar", "xyz": "abc"])
        
        // Then
        XCTAssertNotNil(sut.description)
    }
    
    func testThatMetadataValueDescriptionStringValue() {
        // Given, When
        let sut = Logger.Metadata.Value.string("foo")
        
        // Then
        XCTAssertEqual(sut.description, "foo")
    }
    
    func testThatArrayMetadataValueComparisonShouldReturnTrue() {
        // Give, When, Then
        XCTAssertEqual(Logger.Metadata.Value.array(["foo"]), .array(["foo"]))
    }
    
    func testThatArrayMetadataValueComparisonShouldReturnFalse() {
        // Give, When, Then
        XCTAssertNotEqual(Logger.Metadata.Value.array(["foo"]), .array(["foo1"]))
    }
    
    func testThatDictionaryMetadataValueComparisonShouldReturnTrue() {
        // Give, When, Then
        XCTAssertEqual(Logger.Metadata.Value.dictionary(["foo": "bar"]), .dictionary(["foo": "bar"]))
    }
    
    func testThatDictionaryMetadataValueComparisonShouldReturnFalse() {
        // Give, When, Then
        XCTAssertNotEqual(Logger.Metadata.Value.dictionary(["foo": "bar"]), .dictionary(["foo": "bar1"]))
    }
    
    func testThatStringMetadataValueComparisonShouldReturnTrue() {
        // Give, When, Then
        XCTAssertEqual(Logger.Metadata.Value.string("foo"), .string("foo"))
    }
    
    func testThatStringMetadataValueComparisonShouldReturnFalse() {
        // Give, When, Then
        XCTAssertNotEqual(Logger.Metadata.Value.string("foo"), .string("foo1"))
    }
    
    func testThatMetadataValueComparisonShouldReturnFalseForDifferentTypesOfMetadata() {
        // Give, When, Then
        XCTAssertNotEqual(Logger.Metadata.Value.string("foo"), .dictionary(["foo": "bar"]))
    }
    
    // MARK: Message Tests
    
    func testThatMessageDescription() {
        // Give, When
        let sut = Logger.Message(stringLiteral: "foo")
        
        // Then
        XCTAssertEqual(sut.description, "foo")
    }
}
