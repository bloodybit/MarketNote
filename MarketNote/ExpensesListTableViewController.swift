//
//  ExpensesListTableViewController.swift
//  MarketNote
//
//  Created by Riccardo Sibani on 10/06/16.
//  Copyright © 2016 Polleg. All rights reserved.
//

import UIKit
import Parse

class ExpensesListTableViewController: UITableViewController {
    
    // MARK: - Imports
    private var expenseUtils = Expense()
    
    // MARK: - Properties
    private var expensesByDateArray = [ExpensesByDate]()
    struct Storyboard {
        static let CellIdentifier = "Expenses Cell"
        static let ModifyExpenseSegue = "Modify Expense"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.reloadData() // in order to avoid crashes
        
        if traitCollection.forceTouchCapability == .Available {
            // this device support 3D touch
            registerForPreviewingWithDelegate(self, sourceView: tableView) // extension of uiviewcontroller which implement the delegate in ios9
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBarHidden = false
        
        fetchAllExpenses()
        
        self.tableView.reloadData() // In order to avoid crash
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return expensesByDateArray.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return expensesByDateArray[section].expense.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return expensesByDateArray[section].day
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.CellIdentifier, forIndexPath: indexPath) as! ExpensesListTableViewCell
        
        let expense = expensesByDateArray[indexPath.section].expense[indexPath.row]
        cell.ExpenseTitleLabel.text = expense["title"] as? String
        cell.categoryLabel.text = expense["category"] as? String
        cell.amountLabel.text = expense["amount"] as? String
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedExpense = expensesByDateArray[indexPath.section].expense[indexPath.row]
        
        self.performSegueWithIdentifier(Storyboard.ModifyExpenseSegue, sender: selectedExpense)
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            var expenseToDelete = self.expensesByDateArray[indexPath.section]
            expenseToDelete.expense[indexPath.row].deleteInBackgroundWithBlock({ (success, error) -> Void in
                if error == nil {
                    self.expensesByDateArray[indexPath.section].expense.removeAtIndex(indexPath.row)
                    print("Deleted")
                    // reload tableView in ExpensesListViewController
                    tableView.reloadData()
                } else {
                    print("Not deleted")
                }
            })
        }
    }
    
    
    // Methods
    func fetchAllExpenses() {
        expenseUtils.fetchExpenses(){ (expenses, error) -> Void in
            if let expenses = expenses where error == nil {
                self.expensesByDateArray = self.expenseUtils.getExpensesByDate(expenses)
                self.tableView.reloadData()
            }
        }
    }
    
    
    // MARK: - Segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Storyboard.ModifyExpenseSegue {
            if let modifyExpenceVC = segue.destinationViewController as? ManageExpenseViewController {
                modifyExpenceVC.selectedExpense = sender as? PFObject
            }
        }
    }

}

// MARK: - 3D Touch
extension ExpensesListTableViewController : UIViewControllerPreviewingDelegate {
    
    // peek
    func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        guard let indexPath = tableView.indexPathForRowAtPoint(location), cell = tableView.cellForRowAtIndexPath(indexPath) else {
            return nil
        }
        
        let identifier = "AddExpenseViewController"
        guard let detailVC = storyboard?.instantiateViewControllerWithIdentifier(identifier) as? ManageExpenseViewController else {
            return nil
        }
        
        let selectedExpense = expensesByDateArray[indexPath.section].expense[indexPath.row]
        detailVC.selectedExpense = selectedExpense
        detailVC.expensesListViewController = self
        
        previewingContext.sourceRect = cell.frame
        
        return detailVC
    }
    
    // pop
    func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController) {
        self.showViewController(viewControllerToCommit, sender: self)
    }
}