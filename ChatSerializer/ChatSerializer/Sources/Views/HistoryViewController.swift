//
//  HistoryViewController.swift
//  ChatSerializer
//
//  Created by Ahmad Ansari on 10/03/2018.
//  Copyright © 2018 Ahmad Ansari. All rights reserved.
//

import UIKit

class HistoryViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var newChatButton: UIBarButtonItem!
    var editChatButton: UIBarButtonItem!
    
    var chatHistory:[Chat]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = "Chat History"
        
        newChatButton = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(self.onTapNewChatButton(_:)))
        editChatButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(self.onTapEditChatButton(_:)))
        navigationItem.rightBarButtonItems = [newChatButton, editChatButton]
        
        self.loadChatHistory()
        if chatHistory.isEmpty == true {
            self.startNewChatRequest()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadChatHistory()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onTapEditChatButton(_ sender:UIButton) {
        if self.tableView.isEditing == true {
            self.tableView.isEditing = false
            self.editChatButton.title = "Edit"
            self.editChatButton.style = .plain
        } else {
            self.tableView.isEditing = true
            self.editChatButton.title = "Done"
            self.editChatButton.style = .done
        }
    }
    
    @IBAction func onTapNewChatButton(_ sender:UIButton) {
        self.startNewChatRequest()
    }
    
    
    //MARK: - Methods
    func loadChatHistory() {
        self.chatHistory = ChatHandler.defaultHandler.chatHistory
        self.reloadData()
    }

    func reloadData() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func startNewChat(displayName:String) {
        let chat = ChatHandler.defaultHandler.createChat(displayName: displayName)
        self.loadChatHistory()
        self.performSegue(withIdentifier: Keys.chatBoardSegue, sender: chat)
    }
    
    func startNewChatRequest() {
        let alertController = UIAlertController(title: "Start New Chat", message: "",  preferredStyle: .alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter Display Name"
        }
        
        let saveAction = UIAlertAction(title: "Save", style: UIAlertActionStyle.default, handler: { alert -> Void in
            if let name = alertController.textFields![0].text {
                if name.isEmpty == true {
                    Utility.defaultUtility.displayErrorAlert(messageText: "Invalid Display Name",
                                                             delegate: self)
                } else {
                    SLog.debug("DisplayName: "+name)
                    self.startNewChat(displayName: name)
                }
            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler:nil)
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }

}

//MARK: - Navigation
extension HistoryViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Keys.chatBoardSegue {
            if segue.destination is ChatBoardViewController {
                let chatViewController = segue.destination as! ChatBoardViewController
                chatViewController.chat = sender as! Chat
            }
        }
    }
}


//MARK: - Table View Methods
extension HistoryViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let chat = self.chatHistory[indexPath.row]
        self.performSegue(withIdentifier: Keys.chatBoardSegue, sender: chat)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let chat = self.chatHistory[indexPath.row]
            ChatHandler.defaultHandler.removeChatToHistory(chat: chat)
            self.loadChatHistory()
        }
    }
}

extension HistoryViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.chatHistory.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "historyTableCell")!
        let chat = self.chatHistory[indexPath.row]
        cell.textLabel?.text = chat.displayName
        cell.detailTextLabel?.attributedText = chat.lastMessage()?.formattedMessage()
        return cell
    }
}

