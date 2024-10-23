//
// Created by TruVideo on 08/10/24.
// Copyright © 2024 TruVideo. All rights reserved.
//

import TruvideoSdkFoundationTesting
import XCTest

@testable import TruvideoSdkFoundation

final class StringExtensionsTests: XCTestCase {
    
    // MARK: Tests
    
    func testThatToDateShouldReturnADate() {
        // Given
        var dateComponents = DateComponents(year: 2024, month: 10, day: 8)
        let sut = "2024-10-08T00:00:00Z"

        // When
        dateComponents.timeZone = TimeZone(identifier: "UTC")
        
        let result = sut.toDate()

        // Then
        XCTAssertEqual(result, Calendar.current.date(from: dateComponents))
    }
}
