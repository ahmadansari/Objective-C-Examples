//
//  Protocols.swift
//  ChatSerializer
//
//  Created by VentureDive on 3/13/18.
//  Copyright © 2018 Ahmad Ansari. All rights reserved.
//

import Foundation

//MARK: - JSONSerialization Protocol
protocol JSONSerialization {
    
//    func encodeJSON() -> String?
    func encodeJSON(formatting:JSONEncoder.OutputFormatting?) -> String?
    func decodeJSON(jsonData:Data) -> Any?
}
