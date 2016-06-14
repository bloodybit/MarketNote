//
//  Category.swift
//  MarketNote
//
//  Created by Riccardo Sibani on 09/06/16.
//  Copyright © 2016 Polleg. All rights reserved.
//

import Foundation
import Parse

class Category {
    
    var categories = [String]()
    
    func getCategories( completion: (categories: [String]) -> Void) {
        let categoryQuery = PFQuery(className: "Category")
        categoryQuery.orderByAscending("name")
        categoryQuery.findObjectsInBackgroundWithBlock({ (categories, error) -> Void in
            if error == nil {
                self.categories.removeAll()
                for category in categories! {
                    self.categories.append(category["name"] as! (String))
                }
            } else {
                self.categories = ["Shop", "Health", "Food"]
            }
            completion(categories: self.categories)
        })
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
    
}