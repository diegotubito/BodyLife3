//
//  ExpenseModel.swift
//  OSX-Version
//
//  Created by David Diego Gomez on 08/03/2020.
//  Copyright © 2020 David Diego Gomez. All rights reserved.
//

import Foundation

struct ExpenseModel : Decodable {
    var childIDBaseType : String
    var childIDSecondaryType : String
    var childID : String
    var createdAt : Double
    var isEnabled : Bool
    var operationCategory : String
    var displayName : String
    var displayTypeName : String
    var amount : Double
    var queryByY : String
    var queryByMY : String
    var queryByDMY : String
    var optionalDescription : String?
}
