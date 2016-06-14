//
//  DateUtils.swift
//  MarketNote
//
//  Created by Riccardo Sibani on 09/06/16.
//  Copyright © 2016 Polleg. All rights reserved.
//

import Foundation

class DateUtils {
    
    func getStringCurrentMonth() -> String {
        let currentDate = NSDate()
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMMM, yy"
        return dateFormatter.stringFromDate(currentDate).capitalizedString
    }
    
    func getStartOfMonthDate() -> NSDate {
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Year, .Month], fromDate: date)
        return calendar.dateFromComponents(components)!
    }
}