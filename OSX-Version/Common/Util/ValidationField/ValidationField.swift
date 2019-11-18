//
//  ValidationField.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 17/11/2019.
//  Copyright © 2019 David Diego Gomez. All rights reserved.
//

import Foundation

class ValidationField {
    static let Shared = ValidationField()
    
    enum ValidationType: CaseIterable {
        case Numeric
        case AlphaNumeric
        case Alpha
        case Email
        case None
    }

    
    static func IsValid(text: String, type: ValidationType = .None, minChar: Int = 0, maxChar: Int = 10) -> Bool {
        var result = true
        var charset : Range<String.Index>!
        
        switch type {
        case .Numeric:
            let characterset = CharacterSet(charactersIn: "0123456789")
            charset = text.rangeOfCharacter(from: characterset.inverted)
            break
        case .AlphaNumeric:
            let characterset = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ éáíóúñÑ,.0123456789")
            charset = text.rangeOfCharacter(from: characterset.inverted)
            break
            
        case .Alpha:
            let characterset = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ éáíóúñÑ")
            charset = text.rangeOfCharacter(from: characterset.inverted)
            break
        case .Email:
            let characterset = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ!#$%&'*+-/=?^_`{|}~@.")
            charset = text.rangeOfCharacter(from: characterset.inverted)
            break
        case .None:
            break
        }
        
        if charset != nil || text.count > maxChar || text.count < minChar {
            result = false
        }
        
        return result
    }
    
    
}
