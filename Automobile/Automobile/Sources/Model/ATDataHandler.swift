//
//  ATDataHandler.swift
//  Automobile
//
//  Created by Ahmad Ansari on 16/02/2018.
//  Copyright © 2018 Ahmad Ansari. All rights reserved.
//

import Foundation

class ATDataHandler: NSObject {
    
    // Make init private for singleton
    private override init() { }
    
    // MARK: Default Handler
    static let defaultHandler = ATDataHandler()
    
    //MARK: Local Variables
    let manufacturerService = ATManufacturerService()
    let modelService = ATModelService()
    
    func requestManufacturers(page:Int,
                              completion:@escaping (_ paggingInfo:[String:Any?],_ error: Bool) -> Void) {
        self.manufacturerService.getManufacturers(page: page) { (response, error) in
            if(error == false) {
                if let jsonValue = response as? NSDictionary {
                    let manufacturers = jsonValue[ATKeys.wkda] as! NSDictionary
                    
                    let paggingInfo = [ATKeys.page: jsonValue[ATKeys.page],
                                       ATKeys.pageSize: jsonValue[ATKeys.pageSize],
                                       ATKeys.totalPageCount: jsonValue[ATKeys.totalPageCount],
                                       ]
                    Manufacturer.saveManufacturers(manufacturers,
                                                   completion: { (error) in
                                                    completion(paggingInfo, error)
                    })
                }
            } else {
                completion([:], true)
            }
        }
    }
    
    func requestModels(forManufacturer manufacturerId:Int32,
                       page:Int,
                       completion:@escaping (_ paggingInfo:[String:Any?],_ error: Bool) -> Void) {
        self.modelService.getModels(manufacturerId: manufacturerId,
                                    page: page) { (response, error) in
                                        if(error == false) {
                                            if let jsonValue = response as? NSDictionary {
                                                let models = jsonValue[ATKeys.wkda] as! NSDictionary
                                                let paggingInfo = [ATKeys.page: jsonValue[ATKeys.page],
                                                                   ATKeys.pageSize: jsonValue[ATKeys.pageSize],
                                                                   ATKeys.totalPageCount: jsonValue[ATKeys.totalPageCount],
                                                                   ]
                                                Model.saveModels(manufacturerId: manufacturerId,
                                                                 models: models,
                                                                 completion: { (error) in
                                                                    completion(paggingInfo, error)
                                                })
                                            }
                                        } else {
                                            completion([:], true)
                                        }
        }
    }
}
