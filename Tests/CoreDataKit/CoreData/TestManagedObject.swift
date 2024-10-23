//
// Created by TruVideo on 09/10/24.
// Copyright © 2024 TruVideo. All rights reserved.
//

import CoreData
import Foundation

@testable import TruvideoSdkFoundation

class TestManagedObject: NSManagedObject, CoreDataQueryable {
    @NSManaged public var id: UUID

    // MARK: CoreDataQueryable

    public static var idAttribute: TruvideoSdkFoundation.Attribute<UUID> {
        Attribute(\TestManagedObject.id)
    }
}
