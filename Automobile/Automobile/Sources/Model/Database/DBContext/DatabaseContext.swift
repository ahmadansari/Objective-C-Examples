//
//  DatabaseContext.swift
//  Automobile
//
//  Created by Ahmad Ansari on 16/02/2018.
//  Copyright © 2018 Ahmad Ansari. All rights reserved.
//

import Foundation
import CoreData

final class DatabaseContext : NSObject {
    
    // Make init private for singleton
    private override init() { }
    
    // MARK: Default Handler
    static let sharedContext = DatabaseContext()
    
    lazy var managedObjectContext : NSManagedObjectContext = {
        var managedContext : NSManagedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType)
        managedContext.parent = self.writerManagedObjectContext
        return managedContext
    }()
    
    lazy var writerManagedObjectContext : NSManagedObjectContext = {
        var writerContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.privateQueueConcurrencyType)
        var persistentCoordinator : NSPersistentStoreCoordinator! = self.persistentStoreCoordinator
        if let coordinator = persistentCoordinator
        {
            writerContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        }else {
            abort()
        }
        writerContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return writerContext
    }()
    
    lazy var managedObjectModel : NSManagedObjectModel = {
        let path = Bundle.main.path(forResource: ATConstants.XCDataModelFile, ofType: ATConstants.XCDataModelType)
        let momURL = URL.init(fileURLWithPath:path!)
        return NSManagedObjectModel.init(contentsOf: momURL)!
    }()
    
    lazy var persistentStoreCoordinator : NSPersistentStoreCoordinator = {
        
        let directoryPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last
        var storeURL = directoryPath?.appendingPathComponent(ATConstants.XCDataSQLiteFile)
        
        //Lightweight Migration Options
        var options : [String : AnyObject] = [NSMigratePersistentStoresAutomaticallyOption:NSNumber(value:true), NSInferMappingModelAutomaticallyOption:NSNumber(value:true)]
        
        var coordinator : NSPersistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
        do
        {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: options)
            SLog.debug("store loaded successfully")
        } catch let error as NSError {
            SLog.error("Error: \(error)")
        }
        return coordinator
    }()
    
    func saveContext(managedObjectContext:NSManagedObjectContext) -> Void
    {
        if (managedObjectContext.hasChanges)
        {
            do {
                try managedObjectContext.save()
                SLog.debug("MOC Saved")
            } catch let error as NSError {
                SLog.error("MOC Save Error: \(error)")
            }
        }
    }
    
    func saveContext() -> Void
    {
        let managedContext : NSManagedObjectContext = self.managedObjectContext
        let writerContext : NSManagedObjectContext = self.writerManagedObjectContext
        managedContext.perform ({ () -> Void in
            if (managedContext.hasChanges)
            {
                do {
                    try managedContext.save()
                } catch let error as NSError {
                    SLog.error("MOC Save Error: \(error)")
                }
            }
            
            writerContext.perform({ () -> Void in
                if (writerContext.hasChanges)
                {
                    do {
                        try writerContext.save()
                    } catch let error as NSError {
                        SLog.error("MOC Save Error: \(error)")
                    }
                }
            })
        })
    }
}
