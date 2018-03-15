//
//  Chat.swift
//  ChatSerializer
//
//  Created by VentureDive on 3/13/18.
//  Copyright © 2018 Ahmad Ansari. All rights reserved.
//

import Foundation

struct Chat: Codable {
    var displayName:String?
    var messages:[Message]?
    
    init(name:String? = nil, messages:[Message]? = nil) {
        self.displayName = name
        self.messages = messages
    }
}

//MARK: - Chat Utility Methods
extension Chat {
    func lastMessage() -> Message? {
        var message:Message? = nil
        if let messages = self.messages {
            if messages.isEmpty == false {
                if let sortedMessages:[Message] = self.messages?.sorted(by: {$0.date?.compare($1.date!) == .orderedDescending}) {
                    message = sortedMessages.first
                }
            }
        }
        return message;
    }
}

//MARK: - JSON Serialization
extension Chat: JSONSerialization {
    
    func encodeJSON(formatting:JSONEncoder.OutputFormatting? = .sortedKeys) -> String? {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = formatting!
        do {
            let jsonData = try jsonEncoder.encode(self)
            let jsonString = String(data: jsonData, encoding: .utf8)
            SLog.debug("JSON String : " + jsonString!)
            return jsonString
        }
        catch {
        }
        return nil
    }
    
    func decodeJSON(jsonData:Data) -> Any? {
        do {
            // Decode data to object
            let jsonDecoder = JSONDecoder()
            let chat = try jsonDecoder.decode(Chat.self, from: jsonData)
            SLog.debug("Chat : \(chat)")
            return chat
        }
        catch {
        }
        return nil
    }
}
