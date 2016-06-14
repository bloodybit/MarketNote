//
//  ManageExpenseViewController.swift
//  MarketNote
//
//  Created by Riccardo Sibani on 09/06/16.
//  Copyright © 2016 Polleg. All rights reserved.
//

import UIKit
import Parse

class ManageExpenseViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    
    // MARK: - Imports
    private var categoryUtils = Category()
    private var currencyUtils = CurrencyUtils()
    
    
    // MARK: - Components
    
    @IBOutlet weak var expenseTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextView!
    @IBOutlet weak var categoryPicker: UIPickerView!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var performRequestButton: UIButton!
    @IBOutlet weak var myScroll: UIScrollView!
    
    
    // MARK: - Properties
    var selectedExpense : PFObject? = nil // not private because it will be set in prepareForSegue from another View
    private var selectedCategory = ""
    private var currentString = ""
    private var categories = [String]()
    private var amount: Double = 0.0
    // 3D Touch
    weak var expensesListViewController : ExpensesListTableViewController?
    
    struct Storyboard {
        static let updateButton = "Update"
        static let addButton = "Add"
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Create 3D touch icon
        let firstIcon = UIApplicationShortcutIcon(type: UIApplicationShortcutIconType.Add)
        let firstItem = UIApplicationShortcutItem(type: "Add", localizedTitle: "Add Expense", localizedSubtitle: "Add a single expense", icon: firstIcon, userInfo: nil)
        UIApplication.sharedApplication().shortcutItems = [firstItem]
        
        // Hide Keyboard
        self.hideKeyboardWhenTappedAround()
        
        // Category Picker Delegate
        self.categoryPicker.delegate = self
        self.categoryPicker.dataSource = self
        
        // amountTextField delegate (I will in charge of create the string to put inside)
        self.amountTextField.delegate = self
        
        // descriptionTextField Border painted in black (so the user can see it easily)
        descriptionTextField.layer.cornerRadius = 8.0
        descriptionTextField.layer.masksToBounds = true
        descriptionTextField.layer.borderColor = UIColor( red: 255/255, green: 0/255, blue:0/255, alpha: 1.0 ).CGColor
        descriptionTextField.layer.borderWidth = 2.0

        // change button UPDATE or ADD
        if selectedExpense != nil {
            self.performRequestButton.setTitle(Storyboard.updateButton, forState: .Normal)
        } else {
            self.performRequestButton.setTitle(Storyboard.addButton, forState: .Normal)
        }
        
        // Set the Category Picker
        categoryUtils.getCategories(){ (categories) -> Void in
            for category in categories {
                self.categories.append(category)
             
            }
            
            // display the first category as default category
            self.selectedCategory = self.categories[0]
            
            self.categoryPicker.reloadAllComponents()
            
            // if we are modifying an existing expense, let's populate it
            if self.selectedExpense != nil {
                self.populate()
            }
        }
    }

    @IBAction func AddUpdateAction(sender: AnyObject) {
        
        if performRequestButton.titleLabel?.text == Storyboard.addButton {
            // new Record
            if self.expenseTextField.text != "" && self.selectedCategory != "" && self.amountTextField.text != "" {
                //get the input
                let expense = getInput()
                //if selectedExpense == nil {
                expense!.saveInBackgroundWithBlock({ (success, error) -> Void in
                    if error == nil {
                        print("expense correctly saved")
                        self.cancel()
                    } else {
                        print(error)
                        let alert = UIAlertView(title: "Oops!", message: error?.localizedDescription, delegate: self, cancelButtonTitle: "OK")
                        alert.show()
                    }
                })
            }
        } else {
            // update Record
            
            // update Record
            updateSelectedExpense()
            
            print(selectedExpense!["amount"])
            selectedExpense?.saveInBackgroundWithBlock({ (success, error) -> Void in
                if error == nil {
                    print("expense correctly updated")
                    self.myScroll.scrollRectToVisible(CGRectMake(0, 0, 1, 1), animated: true)
                } else {
                    print(error)
                    let alert = UIAlertView(title: "Oops!", message: error?.localizedDescription, delegate: self, cancelButtonTitle: "OK")
                    alert.show()
                }
            })
        }
    }
    
    
    // MARK: - Standard Operations
    // Methods to set and get the element's view (part of the controller)
    
    func cancel() {
        print("cancel")
        self.expenseTextField.text = ""
        self.descriptionTextField.text = ""
        self.amountTextField.text = ""
        self.currentString = ""
        
        
        myScroll.scrollRectToVisible(CGRectMake(0, 0, 1, 1), animated: true)
    }
    
    func populate() {
        self.expenseTextField.text = selectedExpense!["title"] as? String
        self.descriptionTextField.text = selectedExpense!["description"] as? String
        if let numberCategory = self.categories.indexOf(selectedExpense!["category"] as! (String)){
            self.selectedCategory = categories[numberCategory]
            self.categoryPicker.selectRow(numberCategory, inComponent: 0, animated: true)
        }
        
        print(selectedExpense!["amount"])
        var expensePrice = selectedExpense!["amount"] as! String
        
        
        // currentString must be a string without any other character if not number
        expensePrice = currencyUtils.setPriceInTable(expensePrice)
        print("PRICE \(expensePrice)")
        self.currentString = expensePrice
        let textLabel = currencyUtils.formatCurrency(currentString)
        self.amountTextField.text = textLabel

    }
    
    func getInput() -> PFObject? {
        let newExpense = PFObject(className: "Expense")
        newExpense["title"] = self.expenseTextField.text
        newExpense["description"] = self.descriptionTextField.text
        newExpense["userId"] = PFUser.currentUser()?.objectId!
        newExpense["category"] = self.selectedCategory
        newExpense["amount"] = currencyUtils.fromStringToNumber(currentString)
        return newExpense
    }
    
    func updateSelectedExpense() {
        selectedExpense!["title"] = self.expenseTextField.text
        selectedExpense!["description"] = self.descriptionTextField.text
        selectedExpense!["userId"] = PFUser.currentUser()?.objectId!
        selectedExpense!["category"] = self.selectedCategory
        print("current String \(currentString)")
        let amountToSave = currencyUtils.fromStringToNumber(currentString)
        print("Amount to Save \(amountToSave)")
        selectedExpense!["amount"] = amountToSave
    }
    
    // MARK: - PickerView
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count // how many elements
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categories[row] // return element per each row
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedCategory = categories[row]
    }
    
    
    // MARK: - UITextField
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool { // if I return false, it doesn't change text
        
        switch string {
        case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9":
            currentString += string
            print(currentString)
            if let finalString = currencyUtils.formatCurrency(currentString) {
                print(finalString)
                amountTextField.text = finalString
            } else {
                amountTextField.text = currentString
            }
        case "":
            // back button pressed
            if currentString.characters.count > 0 {
                currentString = currentString.substringToIndex(currentString.endIndex.predecessor())
                
                if let finalString = currencyUtils.formatCurrency(currentString) {
                    amountTextField.text = finalString
                    print(" current String \(currentString)")
                    print(" final String \(finalString)")
                } else {
                    amountTextField.text = currentString
                }
            }
        default:
            // if there is something, remove the character we don't want
            let array = Array(arrayLiteral: string)
            var currentStringArray = Array(arrayLiteral: currentString)
            if array.count == 0 && currentStringArray.count != 0 {
                currentStringArray.removeLast()
                currentString = ""
                for character in currentStringArray {
                    currentString += String(character)
                }
                if let finalString = currencyUtils.formatCurrency(currentString) {
                    amountTextField.text = finalString
                } else {
                    amountTextField.text = currentString
                }
            }
        }
        return false
    }
    
    
    // MARK: - 3D Touch
    override func previewActionItems() -> [UIPreviewActionItem] {
        
        let deleteAction = UIPreviewAction(title: "Delete", style: .Default, handler: { (previewAction, viewController) in
            if let expensesListTVC = self.expensesListViewController, let expense = self.selectedExpense {
                print("Hello")
                // cancello
                expense.deleteInBackgroundWithBlock({ (success, error) -> Void in
                    if error == nil {
                        print("Deleted")
                    } else {
                        print("Not deleted")
                    }
                })
                // reload tableView in HomeTableViewController
                expensesListTVC.fetchAllExpenses()
            }
            
        })
        
        return [deleteAction]
    }
}
