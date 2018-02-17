//
//  Manufacturer+CoreDataProperties.swift
//  
//
//  Created by Ahmad Ansari on 16/02/2018.
//
//

import Foundation
import CoreData


extension Manufacturer {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Manufacturer> {
        return NSFetchRequest<Manufacturer>(entityName: "Manufacturer")
    }

    @NSManaged public var id: Int32
    @NSManaged public var name: String?
    @NSManaged public var models: NSSet?

}

// MARK: Generated accessors for models
extension Manufacturer {

    @objc(addModelsObject:)
    @NSManaged public func addToModels(_ value: Model)

    @objc(removeModelsObject:)
    @NSManaged public func removeFromModels(_ value: Model)

    @objc(addModels:)
    @NSManaged public func addToModels(_ values: NSSet)

    @objc(removeModels:)
    @NSManaged public func removeFromModels(_ values: NSSet)

}
