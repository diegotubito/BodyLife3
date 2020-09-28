//
//  doubleExtension.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 12/11/2019.
//  Copyright © 2019 David Diego Gomez. All rights reserved.
//

import Foundation

extension Double {
    var toDate : Date? {
        return Date(timeInterval: self, since: DateReference)
    }
    
    var toDate1970 : Date {
        return Date(timeIntervalSince1970: self)
    }
}

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

extension Double {
    func formatoPorciento(decimales: Int, modulo: Bool) -> String {
        var porcentaje = Double((1-self) * 100).rounded(toPlaces: decimales)
        if porcentaje < 0 && modulo {
            porcentaje = porcentaje * (-1)
        }
        
        return String(porcentaje).replacingOccurrences(of: ".", with: ",") + " %"
    }
}

extension Double {
    func currencyFormat(decimal: Int, symbol: (String)? = nil) -> String {
        let numberFormatter = NumberFormatter()
        // numberFormatter.locale = NSLocale.current
        if symbol != nil {
            numberFormatter.currencySymbol = symbol
        }
        //  numberFormatter.currencyCode = codigoMoneda
        numberFormatter.numberStyle = NumberFormatter.Style.currency
        let formatoFinal = numberFormatter.string(from: NSNumber(value: self))!
        
        return String(formatoFinal)
        
    }
}
