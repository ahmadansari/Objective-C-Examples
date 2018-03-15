//
//  MessageCell.swift
//  ChatSerializer
//
//  Created by VentureDive on 3/14/18.
//  Copyright © 2018 Ahmad Ansari. All rights reserved.
//

import UIKit

class MessageCell: UITableViewCell {
    static let cellIdentifier = "messageCell"
    
    class func register(forTableView tableView:UITableView?) -> Void {
        guard tableView != nil else { return }
        tableView?.register(UINib.init(nibName: "MessageCell", bundle: Bundle.main), forCellReuseIdentifier: MessageCell.cellIdentifier)
    }
    
    func configure(displayName:String, message:Message) {
        let titleText = NSMutableAttributedString.init(string: displayName)
        if let dateString = message.formattedDate() {
            titleText.append(NSAttributedString(string:", "))
            titleText.append(dateString)
        }
        self.textLabel?.attributedText = titleText
        self.detailTextLabel?.attributedText = message.formattedMessage()
        self.detailTextLabel?.sizeToFit()
    }
}
