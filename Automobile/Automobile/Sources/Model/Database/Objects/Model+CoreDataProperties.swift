//
//  Model+CoreDataProperties.swift
//  
//
//  Created by Ahmad Ansari on 16/02/2018.
//
//

import Foundation
import CoreData


extension Model {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Model> {
        return NSFetchRequest<Model>(entityName: "Model")
    }

    @NSManaged public var name: String?
    @NSManaged public var manufacturer: Manufacturer?

}
