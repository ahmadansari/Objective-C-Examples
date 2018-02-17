//
//  Model+CoreDataClass.swift
//  
//
//  Created by Ahmad Ansari on 16/02/2018.
//
//

import Foundation
import CoreData

@objc(Model)
public class Model: NSManagedObject {
    
    //Entity Name
    static let entityName = "Model"
    
    //MVVM
    lazy var viewModel : ModelVM = {
        return ModelVM.init(model: self)
    }()
    
    //Saving Model Objects
    class func saveModels(manufacturerId:Int32,
                          models: NSDictionary,
                          completion:@escaping (_ error: Bool) -> Void) {
        let managedObjectContext : NSManagedObjectContext = DatabaseContext.sharedContext.managedObjectContext
        let writerManagedObjectContext : NSManagedObjectContext = DatabaseContext.sharedContext.writerManagedObjectContext
        let temporaryContext =  NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        temporaryContext.parent = managedObjectContext
        temporaryContext.perform {
            if (models.count > 0) {
                let request : NSFetchRequest = Manufacturer.fetchRequest()
                let allManufacturers : [Manufacturer] = try! temporaryContext.fetch(request)
                
                let allKeys = models.allKeys
                for key in allKeys {
                    let name = models.value(forKey: key as! String) as? String
                    
                    var manufacturer : Manufacturer? = allManufacturers.filter{$0.id == manufacturerId}.first
                    if(manufacturer == nil) {
                        manufacturer = NSEntityDescription.insertNewObject(forEntityName: Manufacturer.entityName, into: temporaryContext) as? Manufacturer
                        manufacturer?.id = manufacturerId
                    }
                    
                    let allModels = manufacturer?.models?.allObjects as? [Model]
                    
                    var model = allModels?.filter{$0.name == name}.first
                    if (model == nil) {
                        model = NSEntityDescription.insertNewObject(forEntityName: Model.entityName, into: temporaryContext) as? Model
                    }
                    
                    model?.name = name
                    manufacturer?.addToModels(model!)
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
