//
//  ATModelViewController.swift
//  Automobile
//
//  Created by Ahmad Ansari on 16/02/2018.
//  Copyright © 2018 Ahmad Ansari. All rights reserved.
//

import UIKit
import CoreData
import MBProgressHUD

class ATModelViewController : ATViewController {
    
    weak var manufacturer : Manufacturer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = "Models".localized()
        self.navigationItem.largeTitleDisplayMode = .never
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: - Pagging
    override func requestNextPage() {
        let nextPage = self.nextPageCounter()
        DispatchQueue.main.async {
            MBProgressHUD.showAdded(to: self.view, animated: true)
            let manufacturerId = (self.manufacturer?.id)!
            ATDataHandler.defaultHandler.requestModels(forManufacturer: manufacturerId, page: nextPage, completion: { (paggingInfo, error) in
                DispatchQueue.main.async {
                    MBProgressHUD.hide(for: self.view, animated: true)
                    if (error == false) {
                        self.currentPage = paggingInfo[ATKeys.page] as! Int
                        self.totalPageCount = paggingInfo[ATKeys.totalPageCount] as! Int
                        //Checking Count for Previously Saved Objects
                        if let count = self.fetchedResultsController.fetchedObjects?.count {
                            if(count >= paggingInfo[ATKeys.pageSize] as! Int) {
                                self.currentPage = count/ATConstants.defaultPageSize
                            }
                        }
                    } else {
                        self.currentPage = NSNotFound
                    }
                    self.reloadData()
                }
            })
        }
    }
    
    override func requestCurrentPage() {
        DispatchQueue.main.async {
            MBProgressHUD.showAdded(to: self.view, animated: true)
            ATDataHandler.defaultHandler.requestManufacturers(page: self.currentPage, completion: { (paggingInfo, error) in
                DispatchQueue.main.asyncAfter(deadline: .now()+0.1, execute: {
                    MBProgressHUD.hide(for: self.view, animated: true)
                    self.reloadData()
                })
            })
        }
    }
    
    //MARK: - Fetched Results Controller Methods
    override func initializeFetchedResultsController() {
        let request = NSFetchRequest<Model>(entityName: Model.entityName)
        let predicate = NSPredicate.init(format: "SELF.manufacturer.id == %d", (self.manufacturer?.id)!)
        request.predicate = predicate
        let nameSort = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [nameSort]
        let managedObjectContext = DatabaseContext.sharedContext.managedObjectContext
        let frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        self.fetchedResultsController = frc as! NSFetchedResultsController<NSFetchRequestResult>
        self.fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }
    
}


//MARK: - Table View Methods
extension ATModelViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        if (self.isLastRow(indexPath: indexPath) == false) {
            let model = self.fetchedResultsController?.object(at: indexPath) as! Model
           self.displayModelInfo(model: model)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:UITableViewCell?
        
        if (self.isLastRow(indexPath: indexPath)) {
            let loadCell : ATLoadMoreCell = self.tableView.dequeueReusableCell(withIdentifier: ATLoadMoreCell.cellIdentifier) as! ATLoadMoreCell
            
            if((self.currentPage == self.totalPageCount) && self.totalPageCount == 0) {
                loadCell.titleLabel?.text = "No Models Found".localized()
                loadCell.selectionStyle = UITableViewCellSelectionStyle.none
            } else {
                loadCell.titleLabel?.text = "Load More".localized()
                loadCell.selectionStyle = UITableViewCellSelectionStyle.default
            }
            
            cell = loadCell
        } else {
            let defaultCell : ATDefaultCell = self.tableView.dequeueReusableCell(withIdentifier: ATDefaultCell.cellIdentifier)! as! ATDefaultCell
            
            let model = self.fetchedResultsController?.object(at: indexPath) as! Model
            defaultCell.textLabel?.text = model.viewModel.name()
            
            if(indexPath.row%2 == 0) {
                defaultCell.backgroundColor = ATUtility.defaultUtility.UIColorFromHex(ATConstants.cellBackgroundColorEven)
            } else {
                defaultCell.backgroundColor = ATUtility.defaultUtility.UIColorFromHex(ATConstants.cellBackgroundColorOdd)
            }
            cell = defaultCell
        }
        return cell!
    }
}

//MARK: - Other Methods
extension ATModelViewController {
    func displayModelInfo(model:Model) {
        let title = model.manufacturer?.viewModel.name()
        let message = model.viewModel.name()
        
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Dismiss".localized(),
                                          style: .cancel,
                                          handler: nil)
        alertController.addAction(dismissAction)
        self.present(alertController, animated: true, completion: nil)
    }
}



