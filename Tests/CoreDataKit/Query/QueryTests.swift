//
// Created by TruVideo on 04/10/24.
// Copyright © 2024 TruVideo. All rights reserved.
//

import Combine
import CoreData
import TruvideoSdkFoundationTesting
import XCTest

@testable import TruvideoSdkFoundation

final class QueryTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()
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
    
    // MARK: Test
    
    func testThatRange() throws {
        // Given
        let results: [UserManagedObject]
        let sut = try persistentContainer.newQuery(of: UserManagedObject.self)
        
        // When
        try seed()
                
        results = try sut[0...1].array()
        
        // Then
        XCTAssertEqual(results.count, 2)
    }
    
    func testThatFetch() throws {
        // Given
        let results: [UserManagedObject]
        let sut = try persistentContainer.newQuery(of: UserManagedObject.self)
        
        // When
        try seed()
        
        results = try sut.array()
        
        // Then
        XCTAssertEqual(results.count, 3)
    }
    
    func testThatFetchWithRange() throws {
        // Given
        let results: [UserManagedObject]
        let sut = try persistentContainer.newQuery(of: UserManagedObject.self)
        
        // When
        try seed()
        
        results = try sut[0..<1].array()
        
        // Then
        XCTAssertEqual(results.count, 1)
    }
    
    func testThatQueryWithExistingRange() throws {
        // Given
        let range = 0..<10
        let upperRange = 2..<5
        let expectedRange = (range.lowerBound + upperRange.lowerBound)..<upperRange.upperBound
        var sut = try persistentContainer.newQuery(of: UserManagedObject.self)[range]
        
        // When
        sut = sut[upperRange]
        
        // Then
        XCTAssertEqual(sut.range, expectedRange)
    }
    
    func testThatQueryWitAExcludePredicate() throws {
        // Given
        let predicate = NSPredicate(format: "age > %d", 30)
        let results: [UserManagedObject]
        let sut = try persistentContainer.newQuery(of: UserManagedObject.self)
        
        // When
        try seed()
        
        results = try sut
            .exclude(predicate)
            .array()
        
        // Then
        XCTAssertEqual(results.count, 2)
    }
    
    func testThatQueryWithExcludePredicates() throws {
        // Given
        let predicates = [NSPredicate(format: "age > %d", 26), NSPredicate(format: "name BEGINSWITH[cd] %@", "B")]
        let results: [UserManagedObject]
        let sut = try persistentContainer.newQuery(of: UserManagedObject.self)
        
        // When
        try seed()
        
        results = try sut
            .exclude(predicates)
            .orderBy(NSSortDescriptor(key: "name", ascending: true))
            .array()
        
        // Then
        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(results.first?.name, "Alice")
        XCTAssertEqual(results.last?.name, "Charlie")
    }
    
    func testThatFilterWithAQueryPredicate() throws {
        // Given
        let predicate = QueryPredicate<UserManagedObject>(predicate: NSPredicate(format: "name BEGINSWITH[cd] %@", "A"))
        let results: [UserManagedObject]
        let sut = try persistentContainer.newQuery(of: UserManagedObject.self)
        
        // When
        try seed()
        
        results = try sut
            .filter(predicate)
            .array()
        
        // Then
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.name, "Alice")
    }
    
    func testThatQueryFilterWithAPredicate() throws {
        // Given
        let predicate = NSPredicate(format: "age > %d", 30)
        let results: [UserManagedObject]
        let sut = try persistentContainer.newQuery(of: UserManagedObject.self)
        
        // When
        try seed()
        
        results = try sut
            .filter(predicate)
            .array()
        
        // Then
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.name, "Charlie")
    }
    
    func testThatQueryFilterWithExistingPredicate() throws {
        // Given
        let results: [UserManagedObject]
        let sut = try persistentContainer.newQuery(of: UserManagedObject.self)
        
        // When
        try seed()
        
        results = try sut
            .filter(NSPredicate(format: "age > %d", 29))
            .filter(NSPredicate(format: "name == %@", "Bob"))
            .array()
        
        // Then
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.name, "Bob")
    }
    
    func testThatQueryFilterWithPredicates() throws {
        // Given
        let filters = [NSPredicate(format: "age > %d", 29), NSPredicate(format: "name == %@", "Bob")]
        let results: [UserManagedObject]
        let sut = try persistentContainer
            .newQuery(of: UserManagedObject.self)
            .filter(filters)
        
        // When
        try seed()
        
        results = try sut.array()
        
        // Then
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.name, "Bob")
    }
    
    func testThatQueryRangeWithSortDescriptor() throws {
        // Given
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        let results: [UserManagedObject]
        let sut = try persistentContainer.newQuery(of: UserManagedObject.self)
        
        // When
        try seed()
        
        results = try sut
            .range(0..<2)
            .orderBy(sortDescriptor)
            .array()
        
        // Then
        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(results[0].name, "Alice")
        XCTAssertEqual(results[1].name, "Bob")
    }
    
    func testThatArray() throws {
        // Given
        let results: [UserManagedObject]
        let sut = try persistentContainer.newQuery(of: UserManagedObject.self)
        
        // When
        try seed()
        
        results = try sut.array()
        
        // Then
        XCTAssertEqual(results.count, 3)
    }
    
    func testThatDelete() throws {
        // Given
        let sut = try persistentContainer.newQuery(of: UserManagedObject.self)
        
        // When
        try seed()
        
        try sut.delete()
        
        // Then
        XCTAssertTrue(try sut.array().isEmpty)
    }
    
    func testThatCount() throws {
        // Given
        let sut = try persistentContainer.newQuery(of: UserManagedObject.self)
        
        // When
        try seed()
        
        // Then
        XCTAssertEqual(try sut.count(), 3)
    }
    
    func testThatExists() throws {
        // Given
        let sut = try persistentContainer.newQuery(of: UserManagedObject.self)
        
        // When
        try seed()
        
        // Then
        XCTAssertTrue(try sut.exists())
    }
    
    func testThatFirstUsingSortDescriptor() throws {
        // Given
        let result: UserManagedObject?
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: false)
        let sut = try persistentContainer.newQuery(of: UserManagedObject.self)
        
        // When
        let seeds = try seed()
        
        result = try sut
            .orderBy(sortDescriptor)
            .first()
        
        // Then
        XCTAssertEqual(result, seeds.last)
    }
    
    func testThatLast() throws {
        // Given
        let result: UserManagedObject?
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        let sut = try persistentContainer.newQuery(of: UserManagedObject.self)
        
        // When
        let seeds = try seed()
        
        result = try sut
            .orderBy(sortDescriptor)
            .last()
        
        // Then
        XCTAssertEqual(result, seeds.last)
    }
    
    func testThatObjectShouldReturnTheObjectInTheSpecifiedIndex() throws {
        // Given
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        let sut = try persistentContainer.newQuery(of: UserManagedObject.self)
        
        // When
        let seeds = try seed()
        let result = try sut
            .orderBy(sortDescriptor)
            .object(2)
        
        // Then
        XCTAssertEqual(result, seeds.last)
    }
    
    func testThatObserveChangesWithAsyncSequenceObserver() throws {
        // Given
        let expectation = expectation(description: #function)
        let context = persistentContainer.newBackgroundContext()
        let sut = try persistentContainer.newQuery(of: UserManagedObject.self)
        let firstUser = UserManagedObject(context: persistentContainer.viewContext)
        let secondUser = UserManagedObject(context: persistentContainer.viewContext)
        
        // When
        Task {
            var changeEvents: [[UserManagedObject]] = []
            
            for try await snapshot in sut.observe() {
                changeEvents.append(snapshot.elements)
                
                if !changeEvents.isEmpty {
                    break
                }
            }
            
            XCTAssertGreaterThanOrEqual(changeEvents.count, 1)
            expectation.fulfill()
        }
        
        firstUser.name = "Alice"
        firstUser.email = "alice@example.com"
        
        try context.save()
        
        secondUser.name = "Bob"
        secondUser.email = "bob@example.com"
        
        // Then
        waitForExpectations(timeout: 10)
    }
    
    func testThatObserveChangesWithAnyPublisher() async throws {
        // Given
        let expectation = expectation(description: #function)
        var changeEvents: [[UserManagedObject]] = []
        let sut = try persistentContainer.newQuery(of: UserManagedObject.self)
        
        // When
        sut.observe()
            .sink { snapshot in
                guard changeEvents.isEmpty else { return }
                
                changeEvents.append(snapshot.elements)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        try seed()
        
        // Then
        await fulfillment(of: [expectation], timeout: 10)
        XCTAssertFalse(changeEvents.isEmpty)
    }
    
    func testThatObserveChangesWithAnyPublisherOnDelete() async throws {
        // Given
        let expectation = expectation(description: #function)
        var changeEvents: [[UserManagedObject]] = []
        let context = persistentContainer.newBackgroundContext()
        let sut = try persistentContainer.newQuery(of: UserManagedObject.self)
        
        // When
        let user = UserManagedObject(context: context)
        
        user.name = "Alice"
        user.email = "alice@example.com"

        try context.save()
        
        sut.observe()
            .sink { snapshot in
                guard changeEvents.isEmpty else { return }
                
                changeEvents.append(snapshot.elements)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        context.delete(user)
        
        try context.save()
        
        // Then
        await fulfillment(of: [expectation], timeout: 10)
        XCTAssertFalse(changeEvents.isEmpty)
    }

    func testThatObserveChangesWithAnyPublisherOnUpdate() async throws {
        // Given
        let expectation = expectation(description: #function)
        var changeEvents: [[UserManagedObject]] = []
        let context = persistentContainer.newBackgroundContext()
        let sut = try persistentContainer.newQuery(of: UserManagedObject.self)
        
        // When
        let user = UserManagedObject(context: context)
        user.name = "Alice"
        user.email = "alice@example.com"

        try context.save()
        
        sut.observe()
            .sink { snapshot in
                guard changeEvents.isEmpty else { return }
                
                changeEvents.append(snapshot.elements)
                expectation.fulfill()
            }
            .store(in: &cancellables)
                
        user.name = "Brian"

        try context.save()

        // Then
        await fulfillment(of: [expectation], timeout: 10)
        XCTAssertFalse(changeEvents.isEmpty)
    }

    func testThatOrderByKeyPath() throws {
        // Given
        let results: [UserManagedObject]
        let sut = try!persistentContainer.newQuery(of: UserManagedObject.self)
        
        // When
        try seed()
        
        results = try sut
            .orderBy(\.name, ascending: true)
            .array()

        // Then
        XCTAssertEqual(results[0].name, "Alice")
        XCTAssertEqual(results[1].name, "Bob")
        XCTAssertEqual(results[2].name, "Charlie")
    }
    
    func testThatOrderBy() throws {
        // Given
        let results: [UserManagedObject]
        let sortDescriptor = Attribute(\UserManagedObject.name).ascending()
        let sut = try persistentContainer.newQuery(of: UserManagedObject.self)
        
        // When
        try seed()
        
        results = try sut
            .orderBy(sortDescriptor)
            .array()
        
        // Then
        XCTAssertEqual(results[0].name, "Alice")
        XCTAssertEqual(results[1].name, "Bob")
        XCTAssertEqual(results[2].name, "Charlie")
    }
    
    func testThatOrderByWithSortDescriptors() throws {
        // Given
        let results: [UserManagedObject]
        let sut = try persistentContainer.newQuery(of: UserManagedObject.self)
        let sortDescriptors = [
            NSSortDescriptor(key: "name", ascending: false),
            NSSortDescriptor(key: "age",ascending: true)
        ]

        // When
        try seed()
        
        results = try sut
            .orderBy(sortDescriptors)
            .array()
        
        // Then
        XCTAssertEqual(results[0].name, "Charlie")
        XCTAssertEqual(results[1].name, "Bob")
        XCTAssertEqual(results[2].name, "Alice")
    }
    
    func testThatHashableConformance() throws {
        // Given
        let sut = try persistentContainer.newQuery(of: UserManagedObject.self)
        let rhs = try persistentContainer.newQuery(of: UserManagedObject.self)
        
        // When, Then
        XCTAssertEqual(sut.context, rhs.context)
        XCTAssertEqual(sut.entityName, rhs.entityName)
        XCTAssertEqual(sut.predicate, rhs.predicate)
        XCTAssertEqual(sut.entityName, rhs.entityName)
        XCTAssertEqual(sut.sortDescriptors, rhs.sortDescriptors)
        XCTAssertEqual(sut.range, rhs.range)
    }
    
    // MARK: Private methods
    
    @discardableResult
    private func seed() throws -> [UserManagedObject] {
        let context = persistentContainer.newBackgroundContext()
        let firstUser = UserManagedObject(context: context)
        
        firstUser.name = "Alice"
        firstUser.age = 25
        firstUser.email = "alice@example.com"
        
        let secondUser = UserManagedObject(context: context)
        
        secondUser.name = "Bob"
        secondUser.age = 30
        secondUser.email = "bob@example.com"
        
        let thirdUser = UserManagedObject(context: context)
        
        thirdUser.name = "Charlie"
        thirdUser.age = 35
        thirdUser.email = "charlie@example.com"
        
        try context.save()
        
        return [
            persistentContainer.viewContext.object(with: firstUser.objectID) as! UserManagedObject,
            persistentContainer.viewContext.object(with: secondUser.objectID) as! UserManagedObject,
            persistentContainer.viewContext.object(with: thirdUser.objectID) as! UserManagedObject
        ]
    }
}
