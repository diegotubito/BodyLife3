//
//  ExpenseModel.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 08/03/2020.
//  Copyright © 2020 David Diego Gomez. All rights reserved.
//

import Foundation

struct ExpenseModel {
    struct Populated: Codable {
        var _id: String
        var description: String
        var isEnabled: Bool
        var total: Double
        var timestamp: Double
        var expense_date: Double
        var expense_category: ExpenseCategoryModel.Register
    }
    
    struct Register: Codable {
        var _id: String
        var description: String
        var isEnabled: Bool
        var total: Double
        var timestamp: Double
        var expense_date: Double
        var expense_category: String
    }
}


struct ExpenseCategoryModel {
    struct Register: Codable {
        var _id: String
        var isEnabled: Bool
        var timestamp: Double
        var description: String
    }
}
