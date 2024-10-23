//
// Created by TruVideo on 08/10/24.
// Copyright © 2024 TruVideo. All rights reserved.
//

import XCTest

final class DataExtensionTests: XCTestCase {
    // MARK: Test

    func testPrettyPrintedJSON() {
        // Given
        let json = """
        {"name":"John","age":30,"city":"New York"}
        """
        
        let expectedPrettyPrintedString = """
        {
          "name" : "John",
          "age" : 30,
          "city" : "New York"
        }
        """
        
        let jsonData = json.data(using: .utf8)!
        
        // When
        let prettyPrintedString = jsonData.prettyPrintedJSON()
        
        // Then
        XCTAssertEqual(prettyPrintedString?.trimmingCharacters(in: .whitespacesAndNewlines), expectedPrettyPrintedString.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
    func testPrettyPrintedJSONWithInvalidData() {
        // Given
        let invalidJsonData = "Invalid JSON".data(using: .utf8)!
        
        // When
        let prettyPrintedString = invalidJsonData.prettyPrintedJSON()
        
        // Then
        XCTAssertNil(prettyPrintedString)
    }
}
