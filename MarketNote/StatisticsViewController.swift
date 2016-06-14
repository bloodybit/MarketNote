//
//  StatisticsViewController.swift
//  MarketNote
//
//  Created by Riccardo Sibani on 09/06/16.
//  Copyright © 2016 Polleg. All rights reserved.
//

import UIKit
import Parse
import Charts


class StatisticsViewController: UIViewController, ChartViewDelegate {

    // MARK: - Imports
    private var expenseUtils = Expense()
    private var categoryUtils = Category()
    
    // MARK: - Components
   
    @IBOutlet weak var periodBarChartView: BarChartView!
    @IBOutlet weak var averageExpenseLabel: UILabel!
    @IBOutlet weak var totalExpenseLabel: UILabel!
    @IBOutlet weak var pieChartView: PieChartView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    
    // MARK: - Properties
    private var segmentSelected = "Week"
    private var expenses = [PFObject]()
    private var categories = [String]()
    var chartData = ExpensesPerPeriod(period: [], amountExpenses: [])
    
    override func viewDidLoad() {
        super.viewDidLoad()

        periodBarChartView.delegate = self
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        expenseUtils.fetchExpenses(){ (expenses, error) -> Void in
            
            if let expenses = expenses where error == nil {
                
                self.expenses = expenses
                
                
                // set BarData
                self.chartData = self.expenseUtils.filterBy(expenses, period: self.segmentSelected)
                self.setChart(self.chartData.period, values: self.chartData.amountExpenses)
                
                // set Label
                self.updateLabelStatistics()
                
                
                // set PieChart
                self.categoryUtils.getCategories(){ (categories) -> Void in
                    self.categories.removeAll()
                    for category in categories {
                        self.categories.append(category)
                    }
                    let expenses = self.expenseUtils.filterByCategory(expenses, categories: self.categories)
                    self.setPieChart(expenses)
                }
            }
        }
    }

    @IBAction func segmentedControl(sender: AnyObject) {
        if sender.selectedSegmentIndex == 0 {
            // Week
            print("Week")
            segmentSelected = "Week"
            
            //reload chart with week data
            self.chartData = self.expenseUtils.filterBy(expenses, period: self.segmentSelected)
            self.setChart(self.chartData.period, values: self.chartData.amountExpenses)
            
            //update labels
            updateLabelStatistics()
            
            // set PieChart
            self.categoryUtils.getCategories(){ (categories) -> Void in
                self.categories.removeAll()
                for category in categories {
                    self.categories.append(category)
                }
                let expensesToShow = self.expenseUtils.filterByCategory(self.expenses, categories: self.categories)
                self.setPieChart(expensesToShow)
            }
            
        } else if sender.selectedSegmentIndex == 1 {
            // Month
            print("Month")
            segmentSelected = "Month"
            
            //reload Chart with Data
            self.chartData = self.expenseUtils.filterBy(expenses, period: self.segmentSelected)
            self.setChart(self.chartData.period, values: self.chartData.amountExpenses)
            
            //update labels
            updateLabelStatistics()
            
            // set PieChart
            self.categoryUtils.getCategories(){ (categories) -> Void in
                self.categories.removeAll()
                for category in categories {
                    self.categories.append(category)
                }
                let expensesToShow = self.expenseUtils.filterByCategory(self.expenses, categories: self.categories)
                self.setPieChart(expensesToShow)
            }
        } else if sender.selectedSegmentIndex == 2 {
            // Year
            print("Year")
            segmentSelected = "Year"
            self.chartData = self.expenseUtils.filterByMonths(expenses, period: self.segmentSelected)
            self.setChart(self.chartData.period, values: self.chartData.amountExpenses)
            
            //update labels
            updateLabelStatistics()
            
            // set PieChart
            self.categoryUtils.getCategories(){ (categories) -> Void in
                self.categories.removeAll()
                for category in categories {
                    self.categories.append(category)
                }
                let expensesToShow = self.expenseUtils.filterByCategory(self.expenses, categories: self.categories)
                self.setPieChart(expensesToShow
                )
            }
        }
    }
    
    func updateLabelStatistics(){
        averageExpenseLabel.text = String (round( 100*chartData.amountExpenses.reduce(0, combine: +) / Double(chartData.amountExpenses.count))/100) + " €"
        totalExpenseLabel.text = String (chartData.amountExpenses.reduce(0, combine: +)) + " €"
    }
    
    // MARK: - Set Chart Methods
    
    func setChart(dataPoints: [String], values: [Double]) {
        var dataEntries: [BarChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = BarChartDataEntry(value: values[i], xIndex: i)
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = BarChartDataSet(yVals: dataEntries, label: "Units Sold")
        let chartDataToDisplay = BarChartData(xVals: chartData.period, dataSet: chartDataSet)
        
        chartDataSet.colors = ChartColorTemplates.joyful()
        
        periodBarChartView.data = chartDataToDisplay
    }
    
    func setPieChart(expensesPerCategory: [ExpensesPerCategory]) {
        var dataEntries = [ChartDataEntry]()
        
        // get array with categories and array with numbers
        var categoryName = [String]()
        var amountValue = [Double]()
        
        for expensesPerCategory in expensesPerCategory {
            categoryName.append(expensesPerCategory.category)
            amountValue.append(expensesPerCategory.amount)
        }
        
        //set dataEntries
        for i in 0..<categoryName.count {
            let dataEntry = ChartDataEntry(value: amountValue[i], xIndex: i)
            dataEntries.append(dataEntry)
        }
        
        let pieChartDataSet = PieChartDataSet(yVals: dataEntries, label: "")
        let pieChartData = PieChartData(xVals: categoryName, dataSet: pieChartDataSet)
        
        pieChartDataSet.colors = ChartColorTemplates.joyful()
        
        pieChartView.data = pieChartData
        
    }
    
    

}
