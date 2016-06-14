//
//  SumUpViewController.swift
//  MarketNote
//
//  Created by Riccardo Sibani on 09/06/16.
//  Copyright © 2016 Polleg. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class SumUpViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // MARK: - Imports
    private var dateUtils = DateUtils()
    private var expenseUtils = Expense()
    private var categoryUtils = Category()
    
    
    // MARK: - Components
    
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var ceilingProgressBar: UIProgressView!
    @IBOutlet weak var currentMonthAmountLabel: UILabel!
    @IBOutlet weak var categoryTable: UITableView!
    @IBOutlet weak var myScroll: UIScrollView!
    
    
    // MARK: - Properties
    
    struct Storyboard {
        static let ShowLoginSegue = "Show Log In"
        static let categoryCellIdentifier = "Expenses Per Category Cell"
    }
    
    private var categories = [String]()
    private var expensesPerCategory = [ExpensesPerCategory]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if PFUser.currentUser() == nil{
            performSegueWithIdentifier(Storyboard.ShowLoginSegue, sender: nil)
            print("Log In")
        } else {
            print("Logged")
        }
    }

    override func viewDidAppear(animated: Bool) {
        // set the bar again
        self.navigationController?.navigationBarHidden = false
        
        ceilingProgressBar.transform = CGAffineTransformMakeScale(1.0, 5.0)
        
        // set the delegate and datasource of the table inside the view (basically I am creating a TableViewController)
        categoryTable.delegate = self
        categoryTable.dataSource = self
        self.categoryTable.reloadData() // in order to avoid crashes
        
        
        // Set current month
        monthLabel.text = dateUtils.getStringCurrentMonth()
        
        // Set Partial Amount of the Month
        expenseUtils.getCurrentMonthExpenses(){ (total, error) -> Void in
            
            if error == nil {
                self.currentMonthAmountLabel.text = String (total) + " €"
                
                // set progress bar
                let currentUser = PFUser.currentUser()
                
                // check if monhtly ceiling is set
                if let monthlyCeiling = currentUser!["monthly"] {
                    let ceiling = (monthlyCeiling as! NSString).doubleValue
                    if total >= ceiling {
                        // full Bar in red
                        self.ceilingProgressBar.progressTintColor = UIColor(colorLiteralRed: 255, green: 0, blue: 0, alpha: 1)
                        self.ceilingProgressBar.progress = 1.0
                    } else {
                        // show % of the bar
                        self.ceilingProgressBar.progressTintColor = UIColor(colorLiteralRed:14.0/255, green:122.0/255, blue:254.0/255, alpha:1.0)
                        self.ceilingProgressBar.progress = Float (total/ceiling)
                    }
                } else {
                    // ProgressBar full ?
                }
            }
        }
        
        // Set CategoryTableView
        categoryUtils.getCategories(){ (categories) -> Void in
            
            self.expenseUtils.fetchExpenseGreaterThenGivenPeriod(self.dateUtils.getStartOfMonthDate()) { (expenses, error) -> Void in
                if let expenses = expenses {
                    self.expensesPerCategory = self.categoryUtils.filterByCategory(expenses, categories: categories)
                    self.categoryTable.reloadData()
                }
            }
        }
        
    }
    

    // MARK: - Buttons
    
    @IBAction func logoutButtonTapped(sender: AnyObject) {
        PFUser.logOut()
        performSegueWithIdentifier(Storyboard.ShowLoginSegue, sender: nil)
    }
    
    
    // MARK: - TableView
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return expensesPerCategory.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell =  categoryTable.dequeueReusableCellWithIdentifier(Storyboard.categoryCellIdentifier, forIndexPath: indexPath)
        
        let category = expensesPerCategory[indexPath.row].category
        let amount = String (expensesPerCategory[indexPath.row].amount)
        cell.textLabel?.text =  amount + " €    -    " + category
        return cell
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    // MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Storyboard.ShowLoginSegue {
            let loginSignUpVC = segue.destinationViewController as! LoginSignupViewController
            loginSignUpVC.hidesBottomBarWhenPushed = true
            loginSignUpVC.navigationItem.hidesBackButton = navigationItem.hidesBackButton
        }
    }

}
