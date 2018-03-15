//
//  Message.swift
//  ChatSerializer
//
//  Created by VentureDive on 3/13/18.
//  Copyright © 2018 Ahmad Ansari. All rights reserved.
//

import Foundation
import UIKit
import SwiftGifOrigin

struct Message: Codable {
    
    var originalMessage: String?
    var links:[Link]?
    var mentions:[String]?
    var emoticons:[String]?
    var date:Date?
    
    init(message:String? = nil,
         links:[Link]? = nil,
         mentions:[String]? = nil,
         emoticons:[String]? = nil,
         date:Date? = nil) {
        self.originalMessage = message
        self.links = links
        self.mentions = mentions
        self.emoticons = emoticons
        self.date = date
    }
}

//MARK: - JSON Serialization
extension Message: JSONSerialization {
    
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
    
    //    func encodeJSON() -> String? {
    //        return self.encodeJSON(formatting: .sortedKeys)
    //    }
    
    func decodeJSON(jsonData:Data) -> Any? {
        do {
            // Decode data to object
            let jsonDecoder = JSONDecoder()
            let message = try jsonDecoder.decode(Message.self, from: jsonData)
            SLog.debug("Message : \(message)")
            return message
        }
        catch {
        }
        return nil
    }
}

//MARK: - Object Construction
extension Message {
    static func messageWithString(string:String?) -> Message? {
        var message:Message? = nil
        if (string?.isEmpty == false) {
            message = Message.init(message:string)
            message?.date = Date.init()
            message?.emoticons = Emoticon.emoticonsFromString(string: string)
            message?.mentions = Mention.mentionsFromString(string: string)            
            message?.links = Link.linksWithString(string: string)
        }
        return message
    }
}

//MARK: - Message Formatting
extension Message {
    
    func formattedDate() -> NSAttributedString? {
        var dateString:NSMutableAttributedString? = nil
        if let date = self.date {
            let formatter = DateFormatter()
            formatter.timeZone = TimeZone(abbreviation: "GMT+0:00")
            formatter.dateFormat = Constants.dateDisplayFormat
            let string = formatter.string(from: date as Date)
            
            let attributes = [NSAttributedStringKey.foregroundColor:UIColor.gray,
                              NSAttributedStringKey.font:UIFont.systemFont(ofSize: 10),
                              ]
            dateString = NSMutableAttributedString.init(string: string, attributes: attributes)
        }
        return dateString
    }
    
    func formattedMessage() -> NSAttributedString?  {
        if let message = self.originalMessage {
            var fullString = NSMutableAttributedString.init(string: message)
            self.performMentionsFormatting(string: &fullString)
            self.performLinksFormatting(string: &fullString)
            self.performEmoticonsFormatting(string: &fullString)
            return fullString
        }
        return nil
    }
    
    func performEmoticonsFormatting(string:inout NSMutableAttributedString) {
        let message = string.string
        do {
            let regexPattern = Emoticons.getEmoticonsRegexPattern()
            let emoticonsRegex = try NSRegularExpression(pattern: regexPattern, options: NSRegularExpression.Options.caseInsensitive)
            let inputRange = NSRange(location: 0, length: message.utf16.count)
            let emoticonsMatches = emoticonsRegex.matches(in: message, options: [], range: inputRange)
            
            for match in emoticonsMatches.reversed() {
                let pattern =  string.attributedSubstring(from: match.range).string
                let emoticon = Emoticons.shared.emoticonWithPattern(pattern: pattern)
                let emoticonAttachment = NSTextAttachment()
                
                var emoticonImage:UIImage? = nil
                if emoticon?.isAnimated() == true {
                    emoticonImage = UIImage.gif(name: (emoticon?.image)!)
                } else {
                    emoticonImage = UIImage.init(named: (emoticon?.image)!)
                }
                if let image = emoticonImage {
                    emoticonAttachment.image = image
                    emoticonAttachment.image = image.resizedImage(newSize: CGSize.init(width: 20, height: 20))
                    let emoticonString = NSAttributedString(attachment: emoticonAttachment)
                    string.replaceCharacters(in: match.range, with: emoticonString)
                }
            }
        } catch {
            SLog.error("Invalid Regex Pattern")
        }
    }
    
    func performLinksFormatting(string:inout NSMutableAttributedString) {
        let message = string.string
        do {
            let inputRange = NSRange(location: 0, length: message.utf16.count)
            let types: NSTextCheckingResult.CheckingType = .link
            let detector = try NSDataDetector(types: types.rawValue)
            let linkMatches = detector.matches(in: message, options: .reportCompletion, range:inputRange)
            for match in linkMatches.reversed() {
                let pattern =  string.attributedSubstring(from: match.range).string
                let attributes = [NSAttributedStringKey.foregroundColor:UIColor.blue]
                let linkString = NSAttributedString.init(string: pattern, attributes: attributes)
                string.replaceCharacters(in: match.range, with: linkString)
            }
        } catch {
            SLog.error("Invalid Regex Pattern")
        }
    }
    
    
    func performMentionsFormatting(string:inout NSMutableAttributedString) {
        let message = string.string
        do {
            let regexPattern = Constants.mentionsRegexPattern
            let mentionsRegex = try NSRegularExpression(pattern: regexPattern, options: NSRegularExpression.Options.caseInsensitive)
            let inputRange = NSRange(location: 0, length: message.utf16.count)
            
            let mentionsMatches = mentionsRegex.matches(in: message, options: [], range: inputRange)
            
            for match in mentionsMatches.reversed() {
                let pattern =  string.attributedSubstring(from: match.range).string
                let attributes = [NSAttributedStringKey.foregroundColor:UIColor.red]
                let mentionString = NSAttributedString.init(string: pattern, attributes: attributes)
                string.replaceCharacters(in: match.range, with: mentionString)
            }
        } catch {
            SLog.error("Invalid Regex Pattern")
        }
    }
}
