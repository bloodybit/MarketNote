//
//  Expense.swift
//  MarketNote
//
//  Created by Riccardo Sibani on 09/06/16.
//  Copyright © 2016 Polleg. All rights reserved.
//

import Foundation
import Parse

struct ExpensesPerPeriod {
    var period: [String]
    var amountExpenses: [Double]
}

struct ExpensesPerCategory {
    var category: String
    var amount: Double
}

struct ExpensesByDate {
    var day: String!
    var expense: [PFObject]
}

/*
 * This struct could have not been implemented but I did it for clarity
 * [ Use day and month in order to distinguish when coding
 */
struct ExpensesByDateMonth {
    var month: String!
    var expense: [PFObject]
}


class Expense {
    
    private var dateUtils = DateUtils()
    
    private var expenses = [PFObject]?()
    private var expensesGreaterThenGivenPeriod = [PFObject]?()
    
    func fetchExpenses(completion: (expenses: [PFObject]?, error: AnyObject?) -> Void) {
        if let user = PFUser.currentUser() {
            let expensesQuery = PFQuery(className: "Expense")
            expensesQuery.whereKey("userId", equalTo: user.objectId!)
            expensesQuery.findObjectsInBackgroundWithBlock({ (expenses, error) -> Void in
                if let expenses = expenses {
                    self.expenses = expenses
                    completion(expenses: expenses, error: nil)
                } else {
                    print("In fetchExpenses() Expense.swift \(error)")
                    completion(expenses: nil, error: "No Data or general Error")
                    let alert = UIAlertView(title: "Oops!", message: error?.localizedDescription, delegate: self, cancelButtonTitle: "OK")
                    alert.show()
                }
            })
        }
    }
    
    func fetchExpenseGreaterThenGivenPeriod(period : NSDate, completion: (expensesOfTheMonth: [PFObject]?, error: String?) -> Void) {
        if let user = PFUser.currentUser() {
            let expensesQuery = PFQuery(className: "Expense")
            expensesQuery.whereKey("userId", equalTo: user.objectId!)
            expensesQuery.whereKey("createdAt", greaterThan: period)
            expensesQuery.findObjectsInBackgroundWithBlock({ (expenses, error) -> Void in
                if let expenses = expenses {
                    self.expensesGreaterThenGivenPeriod = expenses
                    completion(expensesOfTheMonth: expenses, error: nil)
                } else {
                    print("In fetchExpenses() Expense.swift \(error)")
                    completion(expensesOfTheMonth: nil, error: "No Data or general Error")
                    
                    let alert = UIAlertView(title: "Oops!", message: error?.localizedDescription, delegate: self, cancelButtonTitle: "OK")
                    alert.show()
                }
            })
        }
    }
    
    
    func getCurrentMonthExpenses(completion: (totalAmountExpensesOfTheMonth: Double, error: String?) -> Void){
        
        fetchExpenseGreaterThenGivenPeriod(dateUtils.getStartOfMonthDate()) { (expenses, error) -> Void in
            
            var amount : Double = 0
            if let expenses = expenses{
                for expense in expenses {
                    amount += (expense["amount"] as! NSString).doubleValue
                }
                
                completion(totalAmountExpensesOfTheMonth: amount, error: nil)
            } else {
                completion(totalAmountExpensesOfTheMonth: 0.0, error: "No Expenses or General Error")
            }
            

        }
        
    }
    
    
    func filterBy(expenses: [PFObject], period: String!) -> ExpensesPerPeriod {
        
        var expensesStructForReturn = ExpensesPerPeriod(period: [], amountExpenses: [])
        
        var validExpenses = [PFObject]() // all the expenses after the starting date
        
        // earlier date to compute
        let startPeriod = getDateRange(period)
        
        // Get all the valid expenses
        validExpenses = getExpesesAfterDate(startPeriod, expenses: expenses)
        
        // now let's convert it in struct with days and amount of every expence through getExpensesByDate in ExpencesOperations
        let expensesPerDay = getExpensesByDate(validExpenses)
        
        for dailyExpenses in expensesPerDay {
            
            var dailyTotal = 0.0
            // calculate the total of the day
            for singleAmount in dailyExpenses.expense {
                if let singleAmount = singleAmount["amount"]{
                    dailyTotal += (singleAmount as! NSString).doubleValue
                }
                
            }
            expensesStructForReturn.period.append(dailyExpenses.day)
            expensesStructForReturn.amountExpenses.append(dailyTotal)
        }
        
        return expensesStructForReturn
    }
    
    func filterByMonths(expenses: [PFObject], period: String!) -> ExpensesPerPeriod {
        
        var expensesStructForReturn = ExpensesPerPeriod(period: [], amountExpenses: [])
        
        var validExpenses = [PFObject]() // all the expenses after the starting date
        
        // earlier date to compute
        let startPeriod = getDateRange(period)
        
        // select all the expenses after the startPeriod
        validExpenses = getExpesesAfterDate(startPeriod, expenses: expenses)
        
        // Now let's convert it in struct with months and amount of every expence through getExpensesByDateMonth in ExpencesOperations
        let expensesPerMonth = getExpensesByDateMonth(validExpenses)
        
        for monthlyExpenses in expensesPerMonth {
            var monthlyTotal = 0.0
            // calcualte the total of the day
            for singleAmount in monthlyExpenses.expense {
                if let singleAmount = singleAmount["amount"]{
                    monthlyTotal += (singleAmount as! NSString).doubleValue
                }
            }
            expensesStructForReturn.period.append(monthlyExpenses.month)
            expensesStructForReturn.amountExpenses.append(monthlyTotal)
        }
        
        return expensesStructForReturn
    }
    
    // This function return me the range of the days i have to filter the result (-1 week, -1 month, -1 year)
    // RECHECK (take out strings)
    func getDateRange(period: String) -> NSDate {
        
        // Get one "period" ago date
        var dateBefore = NSDate()
        
        if(period == "Week"){
            dateBefore = NSCalendar.currentCalendar().dateByAddingUnit(.WeekOfYear, value: -1, toDate: NSDate(), options: NSCalendarOptions())!
        } else if (period == "Month") {
            dateBefore = NSCalendar.currentCalendar().dateByAddingUnit(.Month, value: -1, toDate: NSDate(), options: NSCalendarOptions())!
        } else if (period == "Year"){
            dateBefore = NSCalendar.currentCalendar().dateByAddingUnit(.Year, value: -1, toDate: NSDate(), options: NSCalendarOptions())!
        }
        
        return dateBefore
    }
    
    func filterByCategory(expenses: [PFObject], categories: [String]) -> [ExpensesPerCategory] {
        
        // create the expensesPerCategory array with an element for each category
        var expensesPerCategory = [ExpensesPerCategory]()
        for category in categories {
            let expensesPerCategoryToAppend = ExpensesPerCategory(category: category, amount: 0.0)
            expensesPerCategory.append(expensesPerCategoryToAppend)
        }
        
        // fetch all the expenses and add them to the right category
        for expense in expenses {
            let specificCategory = expense["category"]
            
            for i in 0..<expensesPerCategory.count {
                if expensesPerCategory[i].category == specificCategory as! String {
                    expensesPerCategory[i].amount += (expense["amount"] as! NSString).doubleValue
                }
            }
        }
        
        return expensesPerCategory
    }
    
    func getExpesesAfterDate(startPeriod: NSDate, expenses: [PFObject]) -> [PFObject] {
        var validExpenses = [PFObject]()
        // select all the expenses after the startPeriod
        for expense in expenses {
            let expenseDate = expense.createdAt! as NSDate
            
            if expenseDate.earlierDate(startPeriod) == startPeriod { // if the earlier is our start period, let's add this result
                validExpenses.append(expense)
            }
        }
        
        return validExpenses
    }
    
    func getExpensesByDate(expenses: [PFObject]) ->  [ExpensesByDate] {
        
        // prepare the array to return
        var expensesByDateArray = [ExpensesByDate]()
        
        var currentDay = ""
        var expensesOfTheDay = [PFObject]()
        
        for expense in expenses {
            
            let date = expense.createdAt! as NSDate
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            
            let dateString = dateFormatter.stringFromDate(date)
            
            
            if currentDay != dateString {
                // First element of the day, let's save the old datas
                if currentDay != "" {
                    expensesByDateArray.append(ExpensesByDate(day: currentDay, expense: expensesOfTheDay))
                }
                
                currentDay = dateString
                expensesOfTheDay.removeAll()
                expensesOfTheDay.append(expense)
                
            } else {
                expensesOfTheDay.append(expense)
            }
        }
        
        // Save last day
        if currentDay != "" {
            expensesByDateArray.append(ExpensesByDate(day: currentDay, expense: expensesOfTheDay))
        }
        
        return expensesByDateArray
    }
    
    func getExpensesByDateMonth(expenses: [PFObject]) -> [ExpensesByDateMonth] {
        var expensesOfTheMonthArray = [ExpensesByDateMonth]()
        
        var currentMonth = ""
        var expensesOfTheMonth = [PFObject]()
        
        for expense in expenses {
            let date = expense.createdAt! as NSDate
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "MM/yyyy"
            
            let dateString = dateFormatter.stringFromDate(date)
            
            
            if currentMonth != dateString {
                // first element of the month, let's save the old datas
                if currentMonth != "" {
                    expensesOfTheMonthArray.append(ExpensesByDateMonth(month: currentMonth, expense: expensesOfTheMonth))
                }
                
                currentMonth = dateString
                expensesOfTheMonth.removeAll()
                expensesOfTheMonth.append(expense)
            } else {
                expensesOfTheMonth.append(expense)
            }
        }
        
        if currentMonth != "" {
            expensesOfTheMonthArray.append(ExpensesByDateMonth(month: currentMonth, expense: expensesOfTheMonth))
        }
        
        return expensesOfTheMonthArray
    }
}