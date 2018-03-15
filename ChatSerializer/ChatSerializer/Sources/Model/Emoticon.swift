//
//  Emoticon.swift
//  ChatSerializer
//
//  Created by VentureDive on 3/13/18.
//  Copyright © 2018 Ahmad Ansari. All rights reserved.
//

import Foundation

struct Emoticon:Codable {
    var pattern:String?
    var image:String?
    var fileExtension:String?
    
    func isAnimated() -> Bool {
        var animated = false
        if let ext = fileExtension {
            animated = (ext.lowercased() == "gif")
        }
        return animated
    }
}

//MARK: - Object Construction
extension Emoticon {
    static func generateEmoticonPlist() {
        if let path = Bundle.main.path(forResource: "EmoticonsRaw", ofType: "txt") {
            do {
                let data = try String(contentsOfFile: path, encoding: .utf8)
                let allValues = data.components(separatedBy: .newlines)
                let emoticons = NSMutableArray()
                for string in allValues {
                    if string.isEmpty == false {
                        let patternIndex = string.index(before: string.index(of: "-")!)
                        let pattern = String("(\(string[...patternIndex]))")
                        
                        var imageIndex:String.Index? = nil
                        if let atIndex = string.index(of: "@") {
                            imageIndex = string.index(before: atIndex)
                        } else {
                            if let dotIndex = string.index(of: ".") {
                                imageIndex = string.index(before: dotIndex)
                            }
                        }
                        var image:String = ""
                        if let imageIndex = imageIndex {
                            image = String(string[...imageIndex])
                        }
                        
                        let extIndex = string.index(after: string.index(of: ".")!)
                        let fileExtension = String(string[extIndex...])
                        
                        let emoticon = NSMutableDictionary()
                        emoticon.setValue(pattern, forKey: Keys.pattern)
                        emoticon.setValue(image, forKey: Keys.image)
                        emoticon.setValue(fileExtension, forKey: Keys.fileExtension)
                        emoticons.add(emoticon)
                        SLog.debug(string+": saved")
                    } else {
                        SLog.debug(string+": skipped")
                    }
                }
                print (emoticons)
                
                let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
                let docuDir = paths.firstObject as! String
                let path = docuDir + "/Emoticons.plist"
                let filemanager = FileManager.default
                if(!filemanager.fileExists(atPath: path)) {
                    let created = filemanager.createFile(atPath: path, contents: nil, attributes: nil)
                    if(created) {
                        let succeeded = emoticons.write(toFile: path, atomically: true)
                        SLog.debug(succeeded)
                    }
                }
            } catch {
                SLog.error(error)
            }
        }
    }
    
    static func emoticonsFromString(string:String?) -> [String]? {
        if let string = string {
            do {
                let pattern = Emoticons.getEmoticonsRegexPattern()
                let emoticonsRegex = try NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options.caseInsensitive)
                let inputRange = NSRange(location: 0, length: string.utf16.count)
                let emoticonsMatches = emoticonsRegex.matches(in: string, options: [], range: inputRange)
                if emoticonsMatches.count > 0 {
                    var emoticons = [String]()
                    for match in emoticonsMatches {
                        if let swiftRange = Range(match.range, in: string) {
                            let name = string[swiftRange]
                            emoticons.append(String(name))
                        }
                    }
                    return emoticons
                } else {
                    SLog.debug("no emoticons")
                }
            } catch {
                SLog.error("Invalid Regex Pattern")
            }
        }
        return nil
    }
}

//MARK:- Emoticons
class Emoticons:NSObject {
    
    var allEmoticons:[Emoticon]?
    
    // MARK: Shared Object
    static let shared = Emoticons()
    
    // Make init private for singleton
    private override init() {
        let path = Bundle.main.path(forResource: "Emoticons", ofType: "plist")
        let data : NSArray = NSArray.init(contentsOfFile: path!)!
        if (data.count > 0) {
            self.allEmoticons = [Emoticon]()
            for case let emoticonData as NSDictionary in data {
                var emoticon = Emoticon()
                emoticon.image = emoticonData.value(forKey: Keys.image) as? String
                emoticon.pattern = emoticonData.value(forKey: Keys.pattern) as? String
                emoticon.fileExtension = emoticonData.value(forKey: Keys.fileExtension) as? String
                self.allEmoticons?.append(emoticon)
            }
        }
    }
    
    class func getEmoticonsRegexPattern() -> String {
        var regexPattern = ""
        if let emoticons = Emoticons.shared.allEmoticons {
            regexPattern = emoticons.flatMap{("([(]"+$0.pattern!+"[)])")}.joined(separator: "|")
        }
        return regexPattern
    }
    
    func emoticonWithPattern(pattern:String) -> Emoticon? {
        var emoticon:Emoticon? = nil
        if let emoticons = Emoticons.shared.allEmoticons {
            let filteredEmoticons = emoticons.filter({$0.pattern == pattern})
            emoticon = filteredEmoticons.first
        }
        return emoticon
    }
}

