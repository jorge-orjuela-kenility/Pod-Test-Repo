//
// Created by TruVideo on 07/10/24.
// Copyright © 2024 TruVideo. All rights reserved.
//

import Combine
import CoreData
import TruvideoSdkFoundationTesting
import XCTest

@testable import TruvideoSdkFoundation

final class NSManagedObjectContextExtensionTest: XCTestCase {
    private var persistentContainer: NSPersistentContainer!
    
    // MARK: Overriden methods
    
    override func setUpWithError() throws {
        persistentContainer = try NSPersistentContainer.load("Model", in: .module)
        
        try super.setUpWithError()
    }
    
    override func tearDownWithError() throws {
        persistentContainer = nil

        try super.tearDownWithError()
    }
    
    // MARK: Tests
    
    func testThatNSManagedObjectContextNewQuery() throws {
        // Given
        let sut = try persistentContainer
            .viewContext
            .newQuery(of: UserManagedObject.self)

        // When, Then
        XCTAssertNotNil(sut)
    }
    
    func testThatNSManagedObjectContextNewQueryShouldFail() throws {
        // Given
        var contextError: TruVideoFoundationError!

        // When
        do {
            _ = try persistentContainer
                .viewContext
                .newQuery(of: TestManagedObject.self)
        } catch let error as TruVideoFoundationError {
            contextError = error
        }

        // Then
        XCTAssertEqual(contextError.kind, .CoreDataKitErrorReason.invalidEntityName)
    }
    
    func testThatPerformAndSaveShouldSucceed() async throws {
        // Given
        let context = persistentContainer.viewContext
        
        // When
        try await context.performAndSave {
            let user = UserManagedObject(context: context)
            
            user.name = "Alice"
            user.age = 25
            user.email = "alice@example.com"
        }

        let results = try persistentContainer
            .newQuery(of: UserManagedObject.self)
            .array()

        // Then
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.name, "Alice")
    }
    
    func testThatPerformAndSaveShouldFailOnError() async {
        // Given
        let context = persistentContainer.viewContext
        var contextError: Error!
        
        // When
        do {
            try await context.performAndSave {
                throw NSError(domain: "", code: 0)
            }
        } catch {
            contextError = error
        }
        
        // Then
        XCTAssertNotNil(contextError)
    }
}
