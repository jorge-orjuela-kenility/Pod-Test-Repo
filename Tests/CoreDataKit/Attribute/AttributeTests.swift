//
// Created by TruVideo on 08/10/24.
// Copyright © 2024 TruVideo. All rights reserved.
//

import CoreData
import TruvideoSdkFoundationTesting
import XCTest

@testable import TruvideoSdkFoundation

final class AttributeTests: XCTestCase {
    // MARK: Test

    func testAttributeInitializationWithKeyPath() {
        // Given
        let keyPath = \UserManagedObject.name
        
        // When
        let sut = Attribute(keyPath)
        
        // Then
        XCTAssertEqual(sut.expression.keyPath, "name")
    }
    
    func testAttributeInitializationWithStringKeyPath() {
        // Given
        let keyPath = "name"
        
        // When
        let sut = Attribute<String>(keyPath)
        
        // Then
        XCTAssertEqual(sut.expression.keyPath, keyPath)
    }

    func testAscendingSortDescriptor() {
        // Given
        let sut = Attribute<String>(\UserManagedObject.name)
        
        // When
        let sortDescriptor = sut.ascending()
        
        // Then
        XCTAssertEqual(sortDescriptor.key, "name")
        XCTAssertTrue(sortDescriptor.ascending)
    }
    
    func testDescendingSortDescriptor() {
        // Given
        let sut = Attribute<String>(\UserManagedObject.name)
        
        // When
        let sortDescriptor = sut.descending()
        
        // Then
        XCTAssertEqual(sortDescriptor.key, "name")
        XCTAssertFalse(sortDescriptor.ascending)
    }
    
    func testEqualAttributesPredicate() {
        // Given
        let sut = Attribute<String>(\UserManagedObject.name)
        let rhs = Attribute<String>(\UserManagedObject.email)
        
        // When
        let result = sut == rhs
        
        // Then
        XCTAssertFalse(result)
    }

    func testEqualPredicate() {
        // Given
        let sut = Attribute<String>(\UserManagedObject.name)
        let value = "Alice"
        
        // When
        let predicate = sut == value
        
        // Then
        XCTAssertEqual(predicate.predicateFormat, "name == \"Alice\"")
    }
    
    func testNotEqualPredicate() {
        // Given
        let sut = Attribute<String>(\UserManagedObject.name)
        let value = "Bob"
        
        // When
        let predicate = sut != value
        
        // Then
        XCTAssertEqual(predicate.predicateFormat, "name != \"Bob\"")
    }
    
    func testGreaterThanPredicate() {
        // Given
        let sut = Attribute<Int64>(\UserManagedObject.age)
        let value = Int64(25)
        
        // When
        let predicate = sut > value
        
        // Then
        XCTAssertEqual(predicate.predicateFormat, "age > 25")
    }
    
    func testGreaterThanOrEqualToPredicate() {
        // Given
        let sut = Attribute<Int64>(\UserManagedObject.age)
        let value = Int64(25)
        
        // When
        let predicate = sut >= value
        
        // Then
        XCTAssertEqual(predicate.predicateFormat, "age >= 25")
    }

    func testLessThanPredicate() {
        // Given
        let sut = Attribute<Int64>(\UserManagedObject.age)
        let value = Int64(30)
        
        // When
        let predicate = sut < value
        
        // Then
        XCTAssertEqual(predicate.predicateFormat, "age < 30")
    }

    func testLessThanOrEqualToPredicate() {
        // Given
        let sut = Attribute<Int64>(\UserManagedObject.age)
        let value = Int64(30)
        
        // When
        let predicate = sut <= value
        
        // Then
        XCTAssertEqual(predicate.predicateFormat, "age <= 30")
    }

    func testPatternMatchingPredicate() {
        // Given
        let attribute = Attribute<String>(\UserManagedObject.name)
        let pattern = "John%"
        
        // When
        let predicate = attribute ~= pattern
        
        // Then
        XCTAssertEqual(predicate.predicateFormat, "name LIKE \"John%\"")
    }

    func testContainmentPredicate() {
        // Given
        let attribute = Attribute<String>(\UserManagedObject.name)
        let values = ["John", "Jane", "Doe"]
        
        // When
        let predicate = attribute << values
        
        // Then
        XCTAssertEqual(predicate.predicateFormat, "name IN {\"John\", \"Jane\", \"Doe\"}")
    }

    func testRangePredicate() {
        // Given
        let sut = Attribute<Int64>(\UserManagedObject.age)
        let range = Int64(20)..<Int64(40)
        
        // When
        let predicate = sut << range
        
        // Then
        XCTAssertEqual(predicate.predicateFormat, "age BETWEEN {20, 40}")
    }
    
    func testBooleanNegationPredicate() {
        // Given
        let sut = Attribute<Bool>(\UserManagedObject.isActive)
        
        // When
        let predicate = !sut
        
        // Then
        XCTAssertEqual(predicate.predicateFormat, "isActive == 0")
    }
}
