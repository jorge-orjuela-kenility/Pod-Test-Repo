//
// Created by TruVideo on 08/10/24.
// Copyright © 2024 TruVideo. All rights reserved.
//

import XCTest

final class Optional_ExtensionTests: XCTestCase {
    // MARK: Test
    
    func testUnwrapWithValue() {
        // Given
        let optionalValue: Int? = 42
        
        // When
        let unwrappedValue = try! optionalValue.unwrap(or: NSError(domain: "", code: 1))
        
        // Then
        XCTAssertEqual(unwrappedValue, 42)
    }
    
    func testUnwrapWithNilValue() {
        // Given
        var expectedError: (any Error)?
        let optionalValue: Int? = nil
        
        // When
        do {
            _ = try optionalValue.unwrap(or: NSError(domain: "", code: 1, userInfo: [NSLocalizedDescriptionKey: "Value was nil"]))
        } catch {
            expectedError = error
        }
        
        // Then
        XCTAssertNotNil(expectedError)
        XCTAssertEqual(expectedError?.localizedDescription, "Value was nil")
    }
}
