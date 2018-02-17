//
//  ATViewController.swift
//  Automobile
//
//  Created by Ahmad Ansari on 17/02/2018.
//  Copyright © 2018 Ahmad Ansari. All rights reserved.
//

import UIKit
import Localize_Swift
import CoreData
import MBProgressHUD

/*
 *  ATViewController is the template controller for views that use UITableView
 *  along with NSFetchedResultscontroller to display Core Data objects. This class
 *  defines all common utility methods and leaves implementation for child classes
 *  to be provided. Also it hides all FRC boilerplate code so that child controllers
 *  do not get messy.
 */
class ATViewController: UIViewController {
    
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>!
    
    @IBOutlet weak var tableView:UITableView!
    
    //Paging
    var currentPage : Int = NSNotFound
    var totalPageCount : Int = NSNotFound
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationController?.navigationBar.prefersLargeTitles = true
        ATDefaultCell.register(forTableView: self.tableView)
        ATLoadMoreCell.register(forTableView: self.tableView)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(self.onTapRefreshButton))
        self.initializeFetchedResultsController()
        self.requestNextPage()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onTapRefreshButton(_ sender:UIBarButtonItem) {
        self.requestCurrentPage()
    }
    
    func reloadData() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }


    //MARK: - Methods to be Overridden
    //MARK: - Pagging
    func nextPageCounter() -> Int {
        var nextPage = self.currentPage
        if (self.currentPage == NSNotFound) {
            nextPage = 0
        } else {
            if(self.currentPage >= self.totalPageCount) {
                self.currentPage = self.totalPageCount
                nextPage = self.currentPage
            } else {
                nextPage = self.currentPage + 1
            }
        }
        return nextPage
    }
    
    func requestNextPage() {
        fatalError("Parent Method Called: Failed to Request Next Page")
    }
    
    func requestCurrentPage() {
        fatalError("Parent Method Called: Failed to Request Current Page")
    }
    
    //MARK: - FRC Initialization
    func initializeFetchedResultsController() {
        fatalError("Parent Method Called: Failed to initialize FetchedResultsController")
    }
}

//MARK: - Table View Methods
extension ATViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if (self.isLastRow(indexPath: indexPath)) {
            self.requestNextPage()
        }
    }
}

extension ATViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController.sections else {
            SLog.error("No sections in fetchedResultsController")
            return 0
        }
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects + 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: ATLoadMoreCell.cellIdentifier) as! ATDefaultCell
        return cell
    }
    
    func isLastRow(indexPath:IndexPath) -> Bool {
        var isLast = false
        if let count = self.fetchedResultsController.fetchedObjects?.count {
            isLast = (indexPath.row == count)
        }
        return isLast
    }
}

//MARK: - Fetched Results Controller Methods
extension ATViewController : NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        case .move:
            break
        case .update:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
}
