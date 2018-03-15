//
//  Mention.swift
//  ChatSerializer
//
//  Created by VentureDive on 3/13/18.
//  Copyright © 2018 Ahmad Ansari. All rights reserved.
//

import Foundation

class Mention: NSObject {
        
    static func mentionsFromString(string:String?) -> [String]? {
        if let string = string {
            do {
                let mentionsRegex = try NSRegularExpression(pattern: Constants.mentionsRegexPattern, options: NSRegularExpression.Options.caseInsensitive)
                let matches = mentionsRegex.matches(in: string, options: [], range: NSRange(location: 0, length: string.utf16.count))
                if matches.count > 0 {
                    var mentions = [String]()
                    for match in matches {
                        let range = match.range(at:1)
                        if let swiftRange = Range(range, in: string) {
                            let name = string[swiftRange]
                            mentions.append(String(name))
                        }
                    }
                    return mentions
                } else {
                    SLog.debug("no matches")
                }
            } catch {
                SLog.error("Invalid Regex Pattern")
            }
        }
        return nil
    }
}
