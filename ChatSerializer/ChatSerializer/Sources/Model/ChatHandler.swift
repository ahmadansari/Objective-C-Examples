//
//  ChatHandler.swift
//  ChatSerializer
//
//  Created by VentureDive on 3/13/18.
//  Copyright © 2018 Ahmad Ansari. All rights reserved.
//

import Foundation

class ChatHandler : NSObject {
    
    // MARK: Default Handler
    static let defaultHandler = ChatHandler()
    
    // Make init private for singleton
    private override init() {
    }
    
    //Private Variables
    private let defaults : UserDefaults = UserDefaults.standard
    
    //MARK: Chat History
    var chatHistory : [Chat] {
        get {
            var history : [Chat]?
            let historyData = defaults.value(forKey: Keys.chatHistory)
            if let _ = historyData {
                history = try? PropertyListDecoder().decode([Chat].self, from: historyData as! Data)
            }
            
            if history == nil {
                history = [Chat]()
            }
            return history!
        }
        set {
            let historyData = try? PropertyListEncoder().encode(newValue)
            defaults.set(historyData, forKey: Keys.chatHistory)
            defaults.synchronize()
        }
    }
}

//MARK: - Handler Utility Methods
extension ChatHandler {
    func createChat(displayName:String) -> Chat {
        let chat = Chat.init(name: displayName, messages: [Message]())
        var chatHistory = ChatHandler.defaultHandler.chatHistory
        chatHistory.append(chat)
        ChatHandler.defaultHandler.chatHistory = chatHistory
        return chat
    }
    
    func saveChatToHistory(chat:Chat) {
        var chatHistory = ChatHandler.defaultHandler.chatHistory
        if let index = chatHistory.index(where: {$0.displayName == chat.displayName}) {
            chatHistory[index] = chat
        } else {
            chatHistory.append(chat)
        }
        ChatHandler.defaultHandler.chatHistory = chatHistory
    }
    
    func removeChatToHistory(chat:Chat) {
        var chatHistory = ChatHandler.defaultHandler.chatHistory
        if let index = chatHistory.index(where: {$0.displayName == chat.displayName}) {
            chatHistory.remove(at: index)
        }
        ChatHandler.defaultHandler.chatHistory = chatHistory
    }
    
    
}
