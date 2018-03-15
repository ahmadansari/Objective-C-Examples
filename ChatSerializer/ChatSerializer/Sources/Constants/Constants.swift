//
//  Constants.swift
//  ChatSerializer
//
//  Created by VentureDive on 3/13/18.
//  Copyright © 2018 Ahmad Ansari. All rights reserved.
//

import Foundation

struct Constants {
    
    //MARK: - Logger Constants
    static let loggerFormat = "$D[HH:mm:ss]$d $L: $M"
    
    //Date Format
    static let dateDisplayFormat    = "hh:mm a, dd MMM"
    
    //MARK: - Regex Patterns
    static let mentionsRegexPattern = "@(.+?)([^A-Za-z0-9]|($))"
    static let linksTitleRegexPattern = "<title(?:.*?)>(.+?)</title>"
}

struct Keys {
    static let pattern = "pattern"
    static let image = "image"
    static let fileExtension = "fileExtension"
    static let chatHistory = "chatHistory"
    
    //Segue
    static let chatBoardSegue = "chatBoardSegue"
}
