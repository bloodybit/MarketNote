//
//  currencyUtils.swift
//  MarketNote
//
//  Created by Riccardo Sibani on 10/06/16.
//  Copyright © 2016 Polleg. All rights reserved.
//

import Foundation

class CurrencyUtils {
    
    
    func formatCurrency(stringAmount: String) -> (String?){
        let formatter = NSNumberFormatter()
        formatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
        formatter.locale = NSLocale(localeIdentifier: "it_IT") // it_IT
        let numberFromField = (NSString(string: stringAmount).doubleValue)/100
        let finalString = formatter.stringFromNumber(numberFromField)
        
        return finalString
    }
    
    func fromStringToNumber(amount: String) -> String {
        return "\((NSString(string: amount).doubleValue)/100)"
    }

    func setPriceInTable(amount: String) -> String {
        let splittedNumeber = amount.characters.split{$0 == "."}.map(String.init)
        var decimalString = ""
        
        if splittedNumeber.count > 1 {
            decimalString = splittedNumeber[1]
            while decimalString.characters.count != 2 {
                decimalString += "0"
            }
        }
        
        
        return splittedNumeber[0] + decimalString
    }
}