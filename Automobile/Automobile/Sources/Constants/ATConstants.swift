//
//  ATConstants.swift
//  Automobile
//
//  Created by Ahmad Ansari on 16/02/2018.
//  Copyright © 2018 Ahmad Ansari. All rights reserved.
//

import Foundation

struct ATConstants {
    
    //MARK: - Logger Constants
    static let loggerFormat = "$D[HH:mm:ss]$d $L: $M"
    
    //MARK: - URLs
    static let defaultPageSize      = 15
    static let serviceKey           = "coding-puzzle-client-449cc9d" //wa_key
    static let baseURL              = "http://api-aws-eu-qa-1.auto1-test.com"
    static let manufacturerList     = "v1/car-types/manufacturer"
    static let mainTypes            = "v1/car-types/main-types"
    
    
    static let cellBackgroundColorEven:UInt32 = 0xFFEBDD
    static let cellBackgroundColorOdd:UInt32 = 0xFFFFFF
    static let barTintColor:UInt32 = 0xF38414
    
    
    //MARK: - Database Constants
    static let XCDataModelFile    = "ATModel"
    static let XCDataModelType    = "momd"
    static let XCDataStoreType    = "sqlite"
    static let XCDataSQLiteFile   = "ATModel.sqlite"
    
    //MARK: - Notification Names
    static let notifCoreDataResetPerformed = "CoreDataResetPerformed"
}


struct ATKeys {
    //MARK: - KEYS
    static let page             = "page"
    static let pageSize         = "pageSize"
    static let totalPageCount   = "totalPageCount"
    static let wkda             = "wkda"
    static let wa_key           = "wa_key"
    static let manufacturer     = "manufacturer"
}
