//
//  Manufacturer+CoreDataClass.swift
//  
//
//  Created by Ahmad Ansari on 16/02/2018.
//
//

import Foundation
import CoreData

@objc(Manufacturer)
public class Manufacturer: NSManagedObject {
    
    //Entity Name
    static let entityName = "Manufacturer"
    
    //MVVM
    lazy var viewModel : ManufacturerViewModel = {
        return ManufacturerViewModel.init(manufacturer: self)
    }()
    
    //Saving Manufacturers Objects
    class func saveManufacturers(_ manufacturers: NSDictionary,
                                 completion:@escaping (_ error: Bool) -> Void) {
        let managedObjectContext : NSManagedObjectContext = DatabaseContext.sharedContext.managedObjectContext
        let writerManagedObjectContext : NSManagedObjectContext = DatabaseContext.sharedContext.writerManagedObjectContext
        let temporaryContext =  NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        temporaryContext.parent = managedObjectContext
        temporaryContext.perform {
            if (manufacturers.count > 0) {
                let request : NSFetchRequest = Manufacturer.fetchRequest()
                let allManufacturers : [Manufacturer] = try! temporaryContext.fetch(request)
                
                let allKeys = manufacturers.allKeys
                for key in allKeys {
                    let id = Int32(key as! String)
                    let name = manufacturers.value(forKey: key as! String)
                    
                    let filteredResults : [Manufacturer]? = allManufacturers.filter{$0.id == id}
                    
                    var manufacturer : Manufacturer?
                    if (filteredResults?.isEmpty == false) {
                        manufacturer = filteredResults?.first
                    } else {
                        manufacturer = NSEntityDescription.insertNewObject(forEntityName: Manufacturer.entityName, into: temporaryContext) as? Manufacturer
                    }
                    
                    manufacturer?.id = id!
                    manufacturer?.name = name as? String
                }
            }
            
            DatabaseContext.sharedContext.saveContext(managedObjectContext: temporaryContext)
            managedObjectContext.perform {
                DatabaseContext.sharedContext.saveContext(managedObjectContext: managedObjectContext)
                completion(false)
                writerManagedObjectContext.perform {
                    DatabaseContext.sharedContext.saveContext(managedObjectContext: writerManagedObjectContext)
                }
            }
        }
    }
    
}
