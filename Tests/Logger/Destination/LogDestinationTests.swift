//
// Created by TruVideo on 17/09/24.
// Copyright © 2024 TruVideo. All rights reserved.
//

import TruvideoSdkFoundationTesting
import XCTest

@testable import TruvideoSdkFoundation

class LogDestinationTest: XCTestCase {

    // MARK: Tests

    func testThatMultiplexLogDestinationShouldLogValuesToAllDestinations() {
        // Given
        let firstDestination = LogDestinationMock()
        let secondDestination = LogDestinationMock()
        let sut = MultiplexLogDestination(
            destinations: [
                firstDestination,
                secondDestination
            ]
        )

        // When
        sut.log(
            level: .error,
            message: "error test",
            metadata: ["bar": "foo"],
            source: "Some test failed",
            file: #file,
            function: #function,
            line: #line
        )

        // Then
        XCTAssertNotNil(firstDestination.records.first?.file)
        XCTAssertEqual(firstDestination.records.first?.level, .error)
        XCTAssertEqual(firstDestination.records.first?.metadata, ["bar": "foo"])
        XCTAssertEqual(firstDestination.records.first?.message, "error test")
        XCTAssertEqual(firstDestination.records.first?.function, #function)
        
        XCTAssertNotNil(secondDestination.records.first?.file)
        XCTAssertEqual(secondDestination.records.first?.level, .error)
        XCTAssertEqual(secondDestination.records.first?.metadata, ["bar": "foo"])
        XCTAssertEqual(secondDestination.records.first?.message, "error test")
        XCTAssertEqual(secondDestination.records.first?.function, #function)
    }

    func testThatLogLevelShouldReturnTheMinLevelOfTheDestinations() {
        // Given, When
        let firstDestination = LogDestinationMock()
        let secondDestination = LogDestinationMock()
        let sut = MultiplexLogDestination(
            destinations: [
                firstDestination,
                secondDestination
            ]
        )

        // Then
        XCTAssertEqual(sut.logLevel, .info)
    }

    func testThatLogLevelShouldSetANewLogLevel() {
        // Given, When
        let firstDestination = LogDestinationMock()
        let secondDestination = LogDestinationMock()
        var sut = MultiplexLogDestination(
            destinations: [
                firstDestination,
                secondDestination
            ]
        )

        sut.logLevel = .notice

        // Then
        XCTAssertEqual(sut.logLevel, .notice)
    }

    func testThatMetadataShouldReturnTheCombinedMetadataValuesFromAllDestinations() {
        // Given
        let firstDestination = LogDestinationMock()
        let secondDestination = LogDestinationMock()
        let sut = MultiplexLogDestination(
            destinations: [
                firstDestination,
                secondDestination
            ]
        )

        // When
        firstDestination.metadata["bar"] = "some test foo"
        secondDestination.metadata["foo"] = "some test bar"

        // Then
        XCTAssertEqual(
            sut.metadata,
            [
                "bar": "some test foo",
                "foo": "some test bar"
            ]
        )
    }

    func testThatSubscriptShouldSetMetadataValueForMultiplexAndChildrenDestinations() {
        // Given
        let expectedMetadata: Logger.Metadata = ["response": "The test failed for some reason"]
        let firstDestination = LogDestinationMock()
        let secondDestination = LogDestinationMock()
        var sut = MultiplexLogDestination(
            destinations: [
                firstDestination,
                secondDestination
            ]
        )

        // When
        sut[metadataKey: "response"] = "The test failed for some reason"

        // Then
        XCTAssertEqual(sut.metadata, expectedMetadata)
        XCTAssertEqual(firstDestination.metadata, expectedMetadata)
        XCTAssertEqual(secondDestination.metadata, expectedMetadata)
    }

    func testThatSubscriptShouldReturnAValueIfExists() {
        // Given
        let firstDestination = LogDestinationMock()
        let secondDestination = LogDestinationMock()
        let sut = MultiplexLogDestination(
            destinations: [
                firstDestination,
                secondDestination
            ]
        )

        // When
        firstDestination.metadata["bar"] = "some test foo"
        secondDestination.metadata["foo"] = "some test bar"

        // Then
        XCTAssertEqual(sut[metadataKey: "bar"], "some test foo")
    }

    func testThatSubscriptShouldReturnNilIfValueIsNotFound() {
        // Given
        let firstDestination = LogDestinationMock()
        let secondDestination = LogDestinationMock()
        let sut = MultiplexLogDestination(
            destinations: [
                firstDestination,
                secondDestination
            ]
        )

        // When
        firstDestination.metadata["bar"] = "some test foo"
        secondDestination.metadata["foo"] = "some test bar"

        // Then
        XCTAssertNil(sut[metadataKey: "response"])
    }

    func testThatFormattedMessageShouldReturnANoticeMessage() {
        // Given
        let mockStdioOutputStream = StdioOutputStreamMock()
        var sut = StreamLogDestination(label: "label test", stream: mockStdioOutputStream)
        let dateString = dateFormatter.string(from: Date())
        let expectedMessage = "====== label test =======\n\n[🌐 NOTICE]:\n     Date: \(dateString)\n     File: \(#fileID)\n     Function: \(#function)\n     Line: 100\n     Metadata: {bar:some test failed, foo:some test failed}\n     Source: TruvideoSdkFoundationTests\n     Message: This is a test for the notice level\n"

        // When
        sut.dateFormatter = dateFormatter
        sut.metadata = ["bar": "some test failed", "foo": "some test failed"]

        sut.log(
            level: .notice,
            message: "This is a test for the notice level",
            metadata: ["bar": "some test bar", "foo": "some test foo"],
            line: 100
        )

        // Then
        XCTAssertEqual(mockStdioOutputStream.message, expectedMessage)
    }

    func testThatFormattedMessageShouldReturnANoticeMessageWithiSO8601DateFormatter() {
        // Given
        let mockStdioOutputStream = StdioOutputStreamMock()
        let sut = StreamLogDestination(label: "label test", stream: mockStdioOutputStream)
        let expectedMessage = "====== label test =======\n[🌐 NOTICE]:\nFile: \(#file)\nFunction: testThatFormattedMessageShouldReturnANoticeMessageWithiSO8601DateFormatter()\nLine: 217\nMetadata: {bar:foo}\nSource: Its a test\nMessage: This is a test for the notice level"

        // When
        sut.log(
            level: .notice,
            message: "This is a test for the notice level",
            metadata: ["bar": "foo"],
            source: "Its a test",
            file: #file,
            function: "testThatFormattedMessageShouldReturnANoticeMessageWithiSO8601DateFormatter()",
            line: 217
        )

        // Then
        XCTAssertEqual(mockStdioOutputStream.formattedMessage, expectedMessage)
    }

    func testThatMessageFormatForCriticalLogLevel() {
        // Given
        let mockStdioOutputStream = StdioOutputStreamMock()
        var sut = StreamLogDestination(label: "label test", stream: mockStdioOutputStream)
        let expectedMessage = "====== label test =======\n\n[❌ CRITICAL]:\n     Function: testThatFormatMessageShouldReturnACriticalMessage()\n     Metadata: {bar:foo}\n     Source: Its a test\n     Message: This is a test for the notice level\n\n"

        // When
        sut.format = "[$E $L]:\n     Function: $f\n     Metadata: {$m}\n     Source: $S\n     Message: $M\n\n"

        sut.log(
            level: .critical,
            message: "This is a test for the notice level",
            metadata: ["bar": "foo"],
            source: "Its a test",
            file: "LoggingTests/LogDestinationTest.swift",
            function: "testThatFormatMessageShouldReturnACriticalMessage()",
            line: 219
        )

        // Then
        XCTAssertEqual(mockStdioOutputStream.message, expectedMessage)
    }

    func testThatMessageFormatForDebugLogLevel() {
        // Given
        let mockStdioOutputStream = StdioOutputStreamMock()
        var sut = StreamLogDestination(label: "label test", stream: mockStdioOutputStream)
        let expectedMessage = "====== label test =======\n\n[⚙️ DEBUG]:\n     Function: testThatFormatMessageShouldReturnADebugMessage()\n     Metadata: {}\n     Source: Its a test\n     Message: This is a test for the notice level\n\n"

        // When
        sut.format = "[$E $L]:\n     Function: $f\n     Metadata: {$m}\n     Source: $S\n     Message: $M\n\n"

        sut.log(
            level: .debug,
            message: "This is a test for the notice level",
            metadata: nil,
            source: "Its a test",
            file: "LoggingTests/LogDestinationTest.swift",
            function: "testThatFormatMessageShouldReturnADebugMessage()",
            line: 243
        )

        // Then
        XCTAssertEqual(mockStdioOutputStream.message, expectedMessage)
    }

    func testThatMessageFormatForErrorLogLevel() {
        // Given
        let mockStdioOutputStream = StdioOutputStreamMock()
        var sut = StreamLogDestination(label: "label test", stream: mockStdioOutputStream)
        let expectedMessage = "====== label test =======\n\n[🐛 ERROR]:\n     Function: testThatFormatMessageShouldReturnAErrorMessage()\n     Metadata: {bar:foo}\n     Source: Its a test\n     Message: This is a test for the notice level\n\n"

        // When
        sut.format = "[$E $L]:\n     Function: $f\n     Metadata: {$m}\n     Source: $S\n     Message: $M\n\n"

        sut.log(
            level: .error,
            message: "This is a test for the notice level",
            metadata: ["bar": "foo"],
            source: "Its a test",
            file: "LoggingTests/LogDestinationTest.swift",
            function: "testThatFormatMessageShouldReturnAErrorMessage()",
            line: 267
        )

        // Then
        XCTAssertEqual(mockStdioOutputStream.message, expectedMessage)
    }

    func testThatMessageFormatForWarningLogLevel() {
        // Given
        let mockStdioOutputStream = StdioOutputStreamMock()
        var sut = StreamLogDestination(label: "label test", stream: mockStdioOutputStream)
        let expectedMessage = "====== label test =======\n\n[⚠️ WARNING]:\n     Function: testThatFormatMessageSouldReturnAWarningMessage()\n     Metadata: {bar:foo}\n     Source: Its a test\n     Message: This is a test for the notice level\n\n"

        // When
        sut.format = "[$E $L]:\n     Function: $f\n     Metadata: {$m}\n     Source: $S\n     Message: $M\n\n"

        sut.log(
            level: .warning,
            message: "This is a test for the notice level",
            metadata: ["bar": "foo"],
            source: "Its a test",
            file: "LoggingTests/LogDestinationTest.swift",
            function: "testThatFormatMessageSouldReturnAWarningMessage()",
            line: 291
        )

        // Then
        XCTAssertEqual(mockStdioOutputStream.message, expectedMessage)
    }

    func testThatMessageFormatForInfoLogLevel() {
        // Given
        let mockStdioOutputStream = StdioOutputStreamMock()
        var sut = StreamLogDestination(label: "label test", stream: mockStdioOutputStream)
        let expectedMessage = "====== label test =======\n\n[ℹ️ INFO]:\n     Function: testThatFormatMessageSouldReturnAInfoMessage()\n     Metadata: {bar:foo}\n     Source: Its a test\n     Message: This is a test for the notice level\n\n"

        // When
        sut.format = "[$E $L]:\n     Function: $f\n     Metadata: {$m}\n     Source: $S\n     Message: $M\n\n"

        sut.log(
            level: .info,
            message: "This is a test for the notice level",
            metadata: ["bar": "foo"],
            source: "Its a test",
            file: "LoggingTests/LogDestinationTest.swift",
            function: "testThatFormatMessageSouldReturnAInfoMessage()",
            line: 315
        )

        // Then
        XCTAssertEqual(mockStdioOutputStream.message, expectedMessage)
    }

    func testThatMessageFormatSouldReturnTheDefaultMessage() {
        // Given
        let mockStdioOutputStream = StdioOutputStreamMock()
        var sut = StreamLogDestination(label: "label test", stream: mockStdioOutputStream)
        let expectedMessage = "====== label test =======\n\n[✅ TRACE]:\n     Function: testThatFormatMessageSouldReturnADefaultMessage()\n     Metadata: {bar:some test bar, foo:some test foo}\n     Source: Its a test\n     Message: This is a test for the notice level\n\n"

        // When
        sut.format = "[$E $L]:\n     Function: $f\n     Metadata: {$m}\n     Source: $S\n     Message: $M\n\n"

        sut.log(
            level: .trace,
            message: "This is a test for the notice level",
            metadata: ["bar": "some test bar", "foo": "some test foo"],
            source: "Its a test",
            file: "LoggingTests/LogDestinationTest.swift",
            function: "testThatFormatMessageSouldReturnADefaultMessage()",
            line: 339
        )

        // Then
        XCTAssertEqual(mockStdioOutputStream.message, expectedMessage)
    }

    func testThatMessageFormatWithDateAndLevelEmoji() {
        // Given
        let mockStdioOutputStream = StdioOutputStreamMock()
        var sut = StreamLogDestination(label: "label test", stream: mockStdioOutputStream)
        let yyMMddHH = dateFormatter.string(from: Date())

        // When
        sut.dateFormatter = dateFormatter
        sut.format = "[$E] - Date: $D"

        sut.log(
            level: .debug,
            message: "This is a test for the debug level",
            metadata: ["bar": "some test bar", "foo": "some test foo"],
            source: "Its a test",
            file: "LoggingTests/LogDestinationTest.swift",
            function: "testThatFormatMessageWithDateAndLevelEmoji()",
            line: 364
        )

        // Then
        XCTAssertEqual(mockStdioOutputStream.message, "====== label test =======\n\n[⚙️] - Date: \(yyMMddHH)")
    }

    func testThatFormatMessageWithoutVariables() {
        // Given
        let mockStdioOutputStream = StdioOutputStreamMock()
        var sut = StreamLogDestination(label: "label test", stream: mockStdioOutputStream)

        // When
        sut.format = ""

        sut.log(
            level: .critical,
            message: "This is a test for the notice level",
            metadata: ["bar": "foo"],
            source: "Its a test",
            file: "LoggingTests/LogDestinationTest.swift",
            function: #function,
            line: #line
        )

        // Then
        XCTAssertEqual(mockStdioOutputStream.message, "====== label test =======\n\n")
    }

    func testThatFormatMessageWithWeirdFormat() {
        // Given
        let mockStdioOutputStream = StdioOutputStreamMock()
        var sut = StreamLogDestination(label: "label test", stream: mockStdioOutputStream)

        // When
        sut.format = "[$R]:"

        sut.log(
            level: .critical,
            message: "This is a test for the notice level",
            metadata: ["bar": "foo"],
            source: "Its a test",
            file: "LoggingTests/LogDestinationTest.swift",
            function: #function,
            line: #line
        )

        // Then
        XCTAssertEqual(mockStdioOutputStream.message, "====== label test =======\n\n[R]:")
    }

    func testThatStreamLogDestinationShouldGetMetadata() {
        // Given
        let mockStdioOutputStream = StdioOutputStreamMock()
        var sut = StreamLogDestination(label: "label test", stream: mockStdioOutputStream)

        // When
        sut.metadata = ["foo": "some test foo"]

        // Then
        XCTAssertEqual(sut.logLevel, .info)
        XCTAssertEqual(sut[metadataKey: "foo"], "some test foo")
    }

    func testThatStreamLogDestinationHasAStandarOutput() {
        // Given
        let sut = StreamLogDestination.standardOutput(label: "bar")

        // When, Then
        XCTAssertEqual(sut.label, "bar")
    }

    func testThatStreamLogDestinationHasAStandarError() {
        // Given
        let sut = StreamLogDestination.standardError(label: "bar")

        // When, Then
        XCTAssertEqual(sut.label, "bar")
    }
}

private var dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    dateFormatter.locale = Locale(identifier: "en_US")

    return dateFormatter
}()

private extension StdioOutputStreamMock {
    /// Returns the message formatted for comparison.
    var formattedMessage: String {
        let split = message?.components(separatedBy: "\n")
        let filterSplit = split?.filter { !$0.isEmpty }.map { $0.trimmingCharacters(in: .whitespaces) }

        return filterSplit?.filter { !$0.contains("Date:") }.joined(separator: "\n") ?? ""
    }
}
