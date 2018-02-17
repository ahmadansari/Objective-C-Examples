//
//  ATTableViewCells.swift
//  Automobile
//
//  Created by Ahmad Ansari on 17/02/2018.
//  Copyright © 2018 Ahmad Ansari. All rights reserved.
//

import UIKit

class ATDefaultCell: UITableViewCell {
    
    static let cellIdentifier = "defaultCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    class func register(forTableView tableView:UITableView ) -> Void {
        tableView.register(ATDefaultCell.self, forCellReuseIdentifier: ATDefaultCell.cellIdentifier)
    }
}

//MARK:- ATLoadMoreCell
class ATLoadMoreCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    static let cellIdentifier = "loadMoreCell"

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    class func register(forTableView tableView:UITableView ) -> Void {
        tableView.register(UINib.init(nibName: "ATLoadMoreCell", bundle: Bundle.main), forCellReuseIdentifier: ATLoadMoreCell.cellIdentifier)
    }
}
