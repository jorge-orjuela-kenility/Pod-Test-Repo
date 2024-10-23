//
// Created by TruVideo on 10/10/24.
// Copyright © 2024 TruVideo. All rights reserved.
//

import CoreData
import TruvideoSdkFoundationTesting
import XCTest

final class NSPersistenContainer_ExtensionTests: XCTestCase {
    // MARK: Test

    func testThatLoadShouldSucceed() throws {
        // When
        let sut = try NSPersistentContainer.load("Model", in: .module)
        
        // Then
        XCTAssertNotNil(sut)
    }
}
