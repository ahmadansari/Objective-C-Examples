//
//  ATManufacturerViewController.swift
//  Automobile
//
//  Created by Ahmad Ansari on 15/02/2018.
//  Copyright © 2018 Ahmad Ansari. All rights reserved.
//

import UIKit
import MBProgressHUD
import CoreData

class ATManufacturerViewController: ATViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = "Manufacturers".localized()
        self.navigationController?.navigationBar.prefersLargeTitles = true
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
            ATDataHandler.defaultHandler.requestManufacturers(page: nextPage, completion: { (paggingInfo, error) in
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
                DispatchQueue.main.asyncAfter(deadline: .now()+0.1, execute: {
                    MBProgressHUD.hide(for: self.view, animated: true)
                    self.reloadData()
                })
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
        let request = NSFetchRequest<Manufacturer>(entityName: Manufacturer.entityName)
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

extension ATManufacturerViewController {

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        if (self.isLastRow(indexPath: indexPath) == false) {
            self.performSegue(withIdentifier: "modelViewSegue", sender: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:UITableViewCell?
        
        if (self.isLastRow(indexPath: indexPath)) {
            let loadCell : ATLoadMoreCell = self.tableView.dequeueReusableCell(withIdentifier: ATLoadMoreCell.cellIdentifier) as! ATLoadMoreCell
            
            if((self.currentPage == self.totalPageCount) && self.totalPageCount == 0) {
                loadCell.titleLabel?.text = "No Manufacturers Found".localized()
                loadCell.selectionStyle = UITableViewCellSelectionStyle.none
            } else {
                loadCell.titleLabel?.text = "Load More".localized()
                loadCell.selectionStyle = UITableViewCellSelectionStyle.default
            }
            cell = loadCell
        } else {
            let defaultCell : ATDefaultCell = self.tableView.dequeueReusableCell(withIdentifier: ATDefaultCell.cellIdentifier)! as! ATDefaultCell
            
            let manufacturer = self.fetchedResultsController?.object(at: indexPath) as! Manufacturer
            defaultCell.textLabel?.text = manufacturer.viewModel.name()
            
            if(indexPath.row%2 == 0) {
                defaultCell.backgroundColor = ATUtility.defaultUtility.UIColorFromHex(ATConstants.cellBackgroundColorEven)
            } else {
                defaultCell.backgroundColor = ATUtility.defaultUtility.UIColorFromHex(ATConstants.cellBackgroundColorOdd)
            }
            defaultCell.accessoryType = .disclosureIndicator
            cell = defaultCell
        }
        return cell!
    }
}

//MARK: - Navigation
extension ATManufacturerViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "modelViewSegue" {
            if segue.destination is ATModelViewController {
                let modelViewController = segue.destination as! ATModelViewController
                let manufacturer = self.fetchedResultsController?.object(at: sender as! IndexPath) as! Manufacturer
                modelViewController.manufacturer = manufacturer
            }
        }
    }
}


