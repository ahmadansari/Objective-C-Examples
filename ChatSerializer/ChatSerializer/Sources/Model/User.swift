//
//  Chat.swift
//  ChatSerializer
//
//  Created by VentureDive on 3/13/18.
//  Copyright © 2018 Ahmad Ansari. All rights reserved.
//

import Foundation

struct Chat {
    var displayName:String?
    var messages:[Message]?
    
    init(name:String? = nil, messages:[Message]? = nil) {
        self.displayName = name
        self.messages = messages
    }
}
