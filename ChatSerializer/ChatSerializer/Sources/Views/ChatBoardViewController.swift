//
//  ChatBoardViewController.swift
//  ChatSerializer
//
//  Created by Ahmad Ansari on 10/03/2018.
//  Copyright © 2018 Ahmad Ansari. All rights reserved.
//

import UIKit
import MBProgressHUD

class ChatBoardViewController: UIViewController {
    
    var chat:Chat!
    var messages:[Message]!
    
    @IBOutlet weak var tableView:UITableView!
    @IBOutlet weak var emoticonsButton:UIButton!
    @IBOutlet weak var textField:UITextField!
    @IBOutlet weak var bottomConstraint:NSLayoutConstraint!
    var serializeButton: UIBarButtonItem!
    
    var emojiKeyboardController:EmojiKeyboardViewController!
    var keyboardHeight:CGFloat = 0
    var emojiKeyboardHidden:Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.title = self.chat.displayName
        
        //Register Custom Cell
        MessageCell.register(forTableView: self.tableView)
        self.tableView.tableFooterView = UIView.init()

        //Start Keyboard Observing
        self.startObservingKeyboardChanges()

        serializeButton = UIBarButtonItem(title: "Serialize", style: .plain, target: self, action: #selector(self.onTapSerializeButton(_:)))
        navigationItem.rightBarButtonItem = serializeButton
        
        //let input = "Hi @John, check out this link:https://google.com, its (awesome)"
        //let input = "Olympics are starting soon;http://www.nbcolympics.com http://www.google.com. This is the long message, http://yahoo.com, @John, @Jack"
        
        //let input = "Hi @John, Twiter:https://twitter.com/jdorfman/status/430511497475670016"
        //let input = "http://yahoo.com"
        
        
        self.reloadData()
        
        self.emojiKeyboardController = EmojiKeyboardViewController.instance()
        self.emojiKeyboardController.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func sendMessage(text:String) {
        //print("Sent Message: " + message)
        DispatchQueue.main.async {
            MBProgressHUD.showAdded(to: self.view, animated: true)
            DispatchQueue.global().async {
                if let message = Message.messageWithString(string: text) {
                    self.chat.messages?.append(message)
                    ChatHandler.defaultHandler.saveChatToHistory(chat: self.chat)
                }
                DispatchQueue.main.async {
                    MBProgressHUD.hide(for: self.view, animated: true)
                    self.reloadData()
                }
            }
        }
    }
    
    func reloadData() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.scrollToBottom()
        }
    }
    
    func scrollToBottom() {
        if let messages = self.chat.messages {
            if messages.isEmpty == false {
                let lastIndexPath = IndexPath.init(row: messages.count - 1, section: 0)
                self.tableView.scrollToRow(at: lastIndexPath, at: .bottom, animated: true)
            }
        }
    }
}

//MARK: - IBActions
extension ChatBoardViewController {
    @IBAction func onTapSerializeButton(_ sender:UIButton) {
        self.view.endEditing(true)
        if let jsonString = self.chat.encodeJSON(formatting: JSONEncoder.OutputFormatting.prettyPrinted) {
            self.presentJSONController(formattedText: jsonString)
        }
    }
    
    @IBAction func onTapSendButton(_ sender:UIButton) {
        if let text = self.textField.text {
            if text.isEmpty == false {
                //Send Text Message
                self.sendMessage(text: text)
            }
        }
        self.textField.text = ""
    }
    
    @IBAction func onTapEmoticonsButton(_ sender:UIButton) {
        if emojiKeyboardHidden == true {
            self.setEmojiKeyboardHidden(hidden: false)
        } else {
            self.setEmojiKeyboardHidden(hidden: true)
        }
    }
    
}

//MARK: - Emoji Keyboard Delegate
extension ChatBoardViewController: EmojiKeyboardDelegate {
    func didSelectEmoji(emoticon: Emoticon) {
        if textField.isFirstResponder {
            textField.text?.append(emoticon.pattern!)
        }
    }
}

//MARK: - Navigation
extension ChatBoardViewController {
    func presentJSONController(formattedText:String) {
        let JSONController = JSONViewController.instance()
        JSONController.formattedText = formattedText
        let navController = UINavigationController.init(rootViewController: JSONController)
        self.present(navController, animated: true, completion: nil)
    }
}

//MARK: - Table View Methods
extension ChatBoardViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let message = self.chat.messages![indexPath.row]
        if let string = message.formattedMessage() {
            let height = string.height(withConstrainedWidth: (UIScreen.main.bounds.width * 0.75))
            return height + 40.0
        }
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view.endEditing(true)
        tableView.deselectRow(at: indexPath, animated: true)
        let message = self.chat.messages![indexPath.row]
        if let jsonString = message.encodeJSON(formatting: .prettyPrinted) {
            self.presentJSONController(formattedText: jsonString)
        }
    }
}

extension ChatBoardViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.chat.messages!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: MessageCell.cellIdentifier) as! MessageCell
        let message = self.chat.messages![indexPath.row]
        cell.configure(displayName: self.chat.displayName!, message: message)
        return cell
    }
}

//MARK: - Scroll View Delegates
extension ChatBoardViewController: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.textField.resignFirstResponder()
    }
}


//MARK: - Keyboard Handling
extension ChatBoardViewController {
    func startObservingKeyboardChanges() {
        
        // NotificationCenter observers
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardWillShow, object: nil, queue: nil) { [weak self] notification in
            self?.keyboardWillShow(sender: notification)
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardWillHide, object: nil, queue: nil) { [weak self] notification in
            self?.keyboardWillHide(sender: notification)
        }
    }
    
    
    func keyboardWillShow(sender: Notification) {
        guard let value = sender.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue else { return }
        keyboardHeight = value.cgRectValue.height
        self.bottomConstraint.constant = self.bottomConstraint.constant - keyboardHeight
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.view.layoutIfNeeded()
            self.reloadData()
            self.setEmojiKeyboardHidden(hidden: self.emojiKeyboardHidden)
        })
    }
    
    func keyboardWillHide(sender: Notification) {
        keyboardHeight = 0.0
        self.bottomConstraint.constant = 0
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.view.layoutIfNeeded()
            self.reloadData()
            self.setEmojiKeyboardHidden(hidden: self.emojiKeyboardHidden)
        })
    }
    
    func setEmojiKeyboardHidden(hidden:Bool) {
        if hidden == true {
            self.emojiKeyboardHidden = true
            self.emojiKeyboardController.view.isHidden = true
            UIApplication.shared.windows.last?.sendSubview(toBack: emojiKeyboardController.view)
            self.emoticonsButton.setImage(UIImage.init(named: "emoticons"), for: .normal)
            self.emojiKeyboardController.view.removeFromSuperview()
        } else {
            self.emojiKeyboardHidden = false
            self.emojiKeyboardController.view.isHidden = false
            self.emojiKeyboardController.view.frame = CGRect(x: 0, y: self.view.frame.size.height - keyboardHeight, width: self.view.frame.size.width, height: keyboardHeight)
            UIApplication.shared.windows.last?.addSubview(self.emojiKeyboardController.view)
            self.emoticonsButton.setImage(UIImage.init(named: "language"), for: .normal)
        }
    }
}
