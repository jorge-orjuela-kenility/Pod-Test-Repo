//
// Created by TruVideo on 07/10/24.
// Copyright © 2024 TruVideo. All rights reserved.
//

import Combine
import CoreData
import TruvideoSdkFoundationTesting
import XCTest

@testable import TruvideoSdkFoundation

final class PredicateOperatorsTest: XCTestCase {
    // MARK: Test

    func testPredicateEqualityOperator() throws {
        // Given
        let sut: QueryPredicate = (\UserManagedObject.name == "John")
        let persistentContainer = try! NSPersistentContainer.load("Model", in: .module)
        var query = try! persistentContainer.newQuery(of: UserManagedObject.self)
        let user = UserManagedObject(context: persistentContainer.viewContext)

        // When
        user.name = "Charlie"
        user.age = 35
        user.email = "charlie@example.com"
        
        try persistentContainer.viewContext.save()

        query = query.filter(sut)
        
        let results = try! query.array()
        
        // Then
        XCTAssertNil(results.first)
    }
    
    func testPredicateInequalityOperator() throws {
        // Given
        let sut: QueryPredicate = (\UserManagedObject.name != "John")
        let persistentContainer = try! NSPersistentContainer.load("Model", in: .module)
        var query = try! persistentContainer.newQuery(of: UserManagedObject.self)
        let user = UserManagedObject(context: persistentContainer.viewContext)
        
        // When
        user.name = "Charlie"
        user.age = 35
        user.email = "charlie@example.com"
        
        try persistentContainer.viewContext.save()

        query = query.filter(sut)
        
        let results = try! query.array()
        
        // Then
        XCTAssertNotNil(results.first)
    }
    
    func testPredicateGreaterThanOperator() throws {
        // Given
        let sut: QueryPredicate = (\UserManagedObject.age > 35)
        let persistentContainer = try! NSPersistentContainer.load("Model", in: .module)
        var query = try! persistentContainer.newQuery(of: UserManagedObject.self)
        let user = UserManagedObject(context: persistentContainer.viewContext)
        
        // When
        user.name = "Charlie"
        user.age = 35
        user.email = "charlie@example.com"
        
        try persistentContainer.viewContext.save()

        query = query.filter(sut)
        
        let results = try! query.array()
        
        // Then
        XCTAssertNil(results.first)
    }
    
    func testPredicateGreaterThanOrEqualOperator() throws {
        // Given
        let sut: QueryPredicate = (\UserManagedObject.age >= 35)
        let persistentContainer = try! NSPersistentContainer.load("Model", in: .module)
        var query = try! persistentContainer.newQuery(of: UserManagedObject.self)
        let user = UserManagedObject(context: persistentContainer.viewContext)

        // When
        user.name = "Charlie"
        user.age = 35
        user.email = "charlie@example.com"
        
        try persistentContainer.viewContext.save()

        query = query.filter(sut)
        
        let results = try! query.array()
        
        // Then
        XCTAssertNotNil(results.first)
    }
    
    func testPredicateLessThanOperator() throws {
        // Given
        let sut: QueryPredicate = (\UserManagedObject.age < 35)
        let persistentContainer = try! NSPersistentContainer.load("Model", in: .module)
        var query = try! persistentContainer.newQuery(of: UserManagedObject.self)
        let user = UserManagedObject(context: persistentContainer.viewContext)
        
        // When
        user.name = "Charlie"
        user.age = 35
        user.email = "charlie@example.com"
        
        try persistentContainer.viewContext.save()

        query = query.filter(sut)

        let results = try! query.array()
        
        // Then
        XCTAssertNil(results.first)
    }
    
    func testPredicateLessThanOrEqualOperator() throws {
        // Given
        let sut: QueryPredicate = (\UserManagedObject.age <= 35)
        let persistentContainer = try! NSPersistentContainer.load("Model", in: .module)
        let context = persistentContainer.viewContext
        var query = try! persistentContainer.newQuery(of: UserManagedObject.self)
        let user = UserManagedObject(context: context)

        user.name = "Charlie"
        user.age = 35
        user.email = "charlie@example.com"
        
        // When
        try context.save()

        query = query.filter(sut)

        let results = try! query.array()
        
        // Then
        XCTAssertNotNil(results.first)
    }
    
    func testPredicateLikeOperator() throws {
        // Given
        let sut: QueryPredicate = (\UserManagedObject.name ~= "Char*")
        let persistentContainer = try! NSPersistentContainer.load("Model", in: .module)
        var query = try! persistentContainer.newQuery(of: UserManagedObject.self)
        let user = UserManagedObject(context: persistentContainer.viewContext)
        
        // When
        user.name = "Charlie"
        user.age = 35
        user.email = "charlie@example.com"
        
        try persistentContainer.viewContext.save()

        query = query.filter(sut)

        let results = try! query.array()
        
        // Then
        XCTAssertNotNil(results.first)
    }
    
    func testPredicateInArrayOperator() throws {
        // Given
        let sut: QueryPredicate = (\UserManagedObject.name << ["Alice", "Bob"])
        let persistentContainer = try! NSPersistentContainer.load("Model", in: .module)
        var query = try! persistentContainer.newQuery(of: UserManagedObject.self)
        let firstUser = UserManagedObject(context: persistentContainer.viewContext)
        let secondUser = UserManagedObject(context: persistentContainer.viewContext)

        // When
        firstUser.name = "Alice"
        firstUser.age = 30
        firstUser.email = "alice@example.com"
        
        secondUser.name = "Bob"
        secondUser.age = 25
        secondUser.email = "bob@example.com"

        try persistentContainer.viewContext.save()

        query = query.filter(sut)
        
        let results = try! query.array()
        
        // Then
        XCTAssertEqual(results.count, 2)
    }
    
    func testPredicateInRange() throws {
        // Given
        let halfOpenRange: Range<Int64> = 1..<40
        let sut: QueryPredicate = (\UserManagedObject.age << halfOpenRange)
        let persistentContainer = try! NSPersistentContainer.load("Model", in: .module)
        var query = try! persistentContainer.newQuery(of: UserManagedObject.self)
        let firstUser = UserManagedObject(context: persistentContainer.viewContext)
        let secondUser = UserManagedObject(context: persistentContainer.viewContext)

        // When
        firstUser.name = "Charlie"
        firstUser.age = 35
        firstUser.email = "charlie@example.com"
        
        secondUser.name = "David"
        secondUser.age = 40
        secondUser.email = "david@example.com"
        
        try persistentContainer.viewContext.save()

        query = query.filter(sut)
        
        let results = try! query.array()
        
        // Then
        XCTAssertEqual(results.count, 1)
    }
    
    func testPredicateAndOperator() throws {
        // Given
        let firstPredicate: QueryPredicate = (\UserManagedObject.name == "Eve")
        let secondPredicate: QueryPredicate = (\UserManagedObject.age == 28)
        let thirdPredicate: QueryPredicate<UserManagedObject> = .init(booleanLiteral: true)
        let combinedPredicate = firstPredicate && secondPredicate && thirdPredicate
        let persistentContainer = try! NSPersistentContainer.load("Model", in: .module)
        let context = persistentContainer.viewContext
        var query = try! persistentContainer.newQuery(of: UserManagedObject.self)
        let firstUser = UserManagedObject(context: context)

        // When
        firstUser.name = "Eve"
        firstUser.age = 28
        firstUser.email = "eve@example.com"
        
        try context.save()

        query = query.filter(combinedPredicate)

        let results = try! query.array()
        
        // Then
        XCTAssertNotNil(results.first)
    }
    
    func testPredicateOrOperator() throws {
        // Given
        let firstPredicate: QueryPredicate = (\UserManagedObject.name == "Eve")
        let secondPredicate: QueryPredicate = (\UserManagedObject.age == 40)
        let combinedPredicate = firstPredicate || secondPredicate
        let persistentContainer = try! NSPersistentContainer.load("Model", in: .module)
        var query = try! persistentContainer.newQuery(of: UserManagedObject.self)
        let firstUser = UserManagedObject(context: persistentContainer.viewContext)
        let secondUser = UserManagedObject(context: persistentContainer.viewContext)
        
        // When
        firstUser.name = "Eve"
        firstUser.age = 28
        firstUser.email = "eve@example.com"
        
        secondUser.name = "Frank"
        secondUser.age = 40
        secondUser.email = "frank@example.com"
        
        try persistentContainer.viewContext.save()

        query = query.filter(combinedPredicate)
        
        let results = try! query.array()
        
        // Then
        XCTAssertEqual(results.count, 2)
    }
    
    func testPredicateNotOperator() throws {
        // Given
        let predicate: QueryPredicate = !(\UserManagedObject.name == "Grace")
        let persistentContainer = try! NSPersistentContainer.load("Model", in: .module)
        var query = try! persistentContainer.newQuery(of: UserManagedObject.self)
        let user = UserManagedObject(context: persistentContainer.viewContext)

        // When
        user.name = "Grace"
        user.age = 22
        user.email = "grace@example.com"
        
        try persistentContainer.viewContext.save()

        query = query.filter(predicate)
        
        let results = try! query.array()
        
        // Then
        XCTAssertNil(results.first)
    }
}
