//
//  JSONViewController.swift
//  ChatSerializer
//
//  Created by VentureDive on 3/14/18.
//  Copyright © 2018 Ahmad Ansari. All rights reserved.
//

import UIKit

class JSONViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    var formattedText:String?
    
    static func instance() -> JSONViewController {
        let storyBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let viewController : UIViewController = storyBoard.instantiateViewController(withIdentifier: "JSONViewController")
        return viewController as! JSONViewController;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = "JSON"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.onTapCancelButton(_:)))
        
        self.textView.text = formattedText ?? ""        
        self.textView.contentOffset = CGPoint.zero
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

//MARK: - IBActions
extension JSONViewController {
    @IBAction func onTapCancelButton(_ sender:UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

