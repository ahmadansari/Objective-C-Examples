//
//  Link.swift
//  ChatSerializer
//
//  Created by VentureDive on 3/13/18.
//  Copyright © 2018 Ahmad Ansari. All rights reserved.
//

import Foundation


struct Link: Codable {
    var title:String?
    var url:URL?
    
    init(title:String? = nil,
         url:URL? = nil) {
        self.title = title
        self.url = url
    }
}

//MARK: - JSON Serializations
extension Link: JSONSerialization {
    
    func encodeJSON(formatting:JSONEncoder.OutputFormatting? = .sortedKeys) -> String? {
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = formatting!
        do {
            jsonEncoder.outputFormatting = .sortedKeys
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
            let link = try jsonDecoder.decode(Link.self, from: jsonData)
            SLog.debug("Link : \(link)")
            return link
        }
        catch {
        }
        return nil
    }
}

//MARK: - Object Construction
extension Link {
    static func linksWithString(string:String?) -> [Link]? {
        if let string = string {            
            let inputRange = NSRange(location: 0, length: string.utf16.count)
            let types: NSTextCheckingResult.CheckingType = .link
            let detector = try? NSDataDetector(types: types.rawValue)
            let linkMatches = detector?.matches(in: string, options: .reportCompletion, range:inputRange)
            if (linkMatches?.isEmpty == false) {
                var links = [Link]()
                for match in linkMatches! {
                    let title = Link.getWebPageTitle(forPath: match.url)
                    let link = Link(title:title, url:match.url)
                    links.append(link)
                }
                return links
            }
        }
        return nil
    }
    
    private static func getWebPageTitle(forPath url:URL?) -> String? {
        if let url = url {
            do {
                let htmlString = try String(contentsOf: url, encoding: .ascii)
                //print(contents)
                let webRegex = try NSRegularExpression(pattern: Constants.linksTitleRegexPattern, options: NSRegularExpression.Options.caseInsensitive)
                let matches = webRegex.matches(in: htmlString, options: [], range: NSRange(location: 0, length: htmlString.utf16.count))
                if matches.count > 0 {
                    var pageTitle:String? = nil
                    for match in matches {
                        let range = match.range(at:1)
                        if let swiftRange = Range(range, in: htmlString) {
                            let name = htmlString[swiftRange]
                            pageTitle = String(name).encodeHtmlString()
                            break
                        }
                    }
                    return pageTitle
                } else {
                    SLog.debug("no matches")
                }
            } catch {
                SLog.error(error)
            }
        } else {
            SLog.error("Invalid URL")
        }
        return nil
    }
}

