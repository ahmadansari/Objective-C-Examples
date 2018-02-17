//
//  ATUtility.swift
//  Automobile
//
//  Created by Ahmad Ansari on 16/02/2018.
//  Copyright © 2018 Ahmad Ansari. All rights reserved.
//

import Foundation
import UIKit
import SwiftyBeaver

//Swift Logger
let SLog = SwiftyBeaver.self

class ATUtility : NSObject {
    
    // Make init private for singleton
    private override init() {
    }
    
    // MARK: Default Context
    static let defaultUtility = ATUtility()
    
    func configureSwiftLogger() {
        // add console log destinations
        let console = ConsoleDestination()  // log to Xcode Console
        
        // log format : console output to short time, log level & message
        console.format = ATConstants.loggerFormat

        // add the destinations to SwiftyBeaver
        SLog.addDestination(console)
    }    
    
    func UIColorFromHex(_ rgbValue:UInt32)->UIColor{
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:1.0)
    }
}
