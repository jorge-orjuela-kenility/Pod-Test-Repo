//
// Created by TruVideo on 07/10/24.
// Copyright © 2024 TruVideo. All rights reserved.
//

import Combine
import CoreData
import TruvideoSdkFoundationTesting
import XCTest

@testable import TruvideoSdkFoundation

final class NSManagedObjectExtensionTest: XCTestCase {
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
    
    func testThatFindOrCreateShouldRetrieveExistingObject() async throws {
        // Given
        let context = persistentContainer.viewContext
        let name = "Test User"
        let predicate = NSPredicate(format: "name == %@", name)
        let user: UserManagedObject = UserManagedObject(context: context)

        // When
        user.id = UUID()
        user.name = name
        user.age = 20
        user.email = "test@email.com"
        
        let managedObject: UserManagedObject = try await UserManagedObject.findOrCreate(
            matching: predicate,
            in: context
        )
        
        // Then
        XCTAssertEqual(managedObject.name, user.name)
        XCTAssertEqual(managedObject.id, user.id)
    }
    
    func testThatFindOrCreateShouldCreateANewObject() async throws {
        // Given
        let context = persistentContainer.viewContext
        let predicate = NSPredicate(format: "name == %@", "Non-Existing User")
        
        // When
        let newUser: UserManagedObject = try await UserManagedObject.findOrCreate(matching: predicate, in: context)
        
        // Then
        XCTAssertNotNil(newUser)
        XCTAssertEqual(newUser.name, "")
    }

    func testThatFindOrCreateShouldFailWithError() async {
        // Given
        var contextError: TruVideoFoundationError!
        let context = persistentContainer.viewContext
        let predicate = NSPredicate(format: "name == %@", "")
        
        // When
        do {
            _ = try await UserManagedObject.findOrCreate(matching: predicate, in: context)
        } catch {
            contextError = error as? TruVideoFoundationError 
        }
        
        // Then
        XCTAssertEqual(contextError.kind, ErrorReason.CoreDataKitErrorReason.invalidEntityName)
    }
}
