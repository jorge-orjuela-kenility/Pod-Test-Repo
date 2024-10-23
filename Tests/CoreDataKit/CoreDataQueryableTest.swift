//
// Created by TruVideo on 07/10/24.
// Copyright © 2024 TruVideo. All rights reserved.
//

import Combine
import CoreData
import TruvideoSdkFoundationTesting
import XCTest

@testable import TruvideoSdkFoundation

final class CoreDataQueryableTest: XCTestCase {
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
        let context = persistentContainer.newBackgroundContext()
        let user = UserManagedObject(context: context)

        // When
        user.id = UUID()
        user.name = "Test User"
        user.age = 20
        user.email = "test@email.com"

        try context.save()
        
        let managedObject: UserManagedObject = try UserManagedObject.findOrCreate(
            user.id,
            in: persistentContainer.viewContext
        )
        
        // Then
        XCTAssertEqual(managedObject.name, user.name)
        XCTAssertEqual(managedObject.id, user.id)
    }
    
    func testThatFindOrCreateShouldCreateNewObject() async throws {
        // Given
        let context = persistentContainer.newBackgroundContext()
        
        // When
        let newUser: UserManagedObject = try UserManagedObject.findOrCreate(UUID(), in: context)
        
        // Then
        XCTAssertNotNil(newUser)
    }

    func testThatFindOrCreateShouldFailOnError() async {
        // Given
        var contextError: TruVideoFoundationError!
        
        // When
        do {
            _ = try TestManagedObject.findOrCreate(UUID(), in: persistentContainer.viewContext)
        } catch {
            contextError = error as? TruVideoFoundationError
        }
        
        // Then
        XCTAssertEqual(contextError.kind, .CoreDataKitErrorReason.invalidEntityName)
    }
}
