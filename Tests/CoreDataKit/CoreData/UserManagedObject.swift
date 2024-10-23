//
// Created by TruVideo on 4/10/24.
// Copyright © 2024 TruVideo. All rights reserved.
//

import CoreData
import Foundation

@testable import TruvideoSdkFoundation

public final class UserManagedObject: NSManagedObject, CoreDataQueryable  {
    @NSManaged public var id: UUID
    @NSManaged public var age: Int64
    @NSManaged public var email: String
    @NSManaged public var name: String
    @NSManaged public var isActive: Bool
    
    // MARK: Static Properties
    
    public static var idAttribute: TruvideoSdkFoundation.Attribute<UUID> {
        Attribute(\UserManagedObject.id)
    }
}
