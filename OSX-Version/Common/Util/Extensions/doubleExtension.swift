//
//  doubleExtension.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 12/11/2019.
//  Copyright © 2019 David Diego Gomez. All rights reserved.
//

import Foundation

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
    func formatoMoneda(decimales: Int, codigoMoneda: String) -> String {
        let numberFormatter = NumberFormatter()
        // numberFormatter.locale = NSLocale.current
        numberFormatter.currencySymbol = "$"
        numberFormatter.currencyCode = codigoMoneda
        numberFormatter.numberStyle = NumberFormatter.Style.currency
        let formatoFinal = numberFormatter.string(from: NSNumber(value: self))!
        
        return String(formatoFinal)
        
    }
    
    func formatoMoneda(decimales: Int, simbolo: String) -> String {
        let numberFormatter = NumberFormatter()
        // numberFormatter.locale = NSLocale.current
        numberFormatter.currencySymbol = simbolo
        //  numberFormatter.currencyCode = codigoMoneda
        numberFormatter.numberStyle = NumberFormatter.Style.currency
        let formatoFinal = numberFormatter.string(from: NSNumber(value: self))!
        
        return String(formatoFinal)
        
    }
    
    func formatoMoneda(decimales: Int) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = NSLocale.current
        //  numberFormatter.currencySymbol = "$"
        numberFormatter.numberStyle = NumberFormatter.Style.currencyAccounting
        let formatoFinal = numberFormatter.string(from: NSNumber(value: self))!
        
        return String(formatoFinal)
        
    }
    
    func formatoMonedaTF(decimales: Int) -> String {
        let numero = self.rounded(toPlaces: decimales)
        let separador = ","
        var str = String(numero)
        str = str.replacingOccurrences(of: ".", with: separador)
        
        return "$ " + str
        
    }
}
